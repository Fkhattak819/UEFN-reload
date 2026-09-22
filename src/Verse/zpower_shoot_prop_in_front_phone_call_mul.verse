using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Assets }
using { /Verse.org/Random }
using {/Verse.org/Colors/NamedColors }
using { /Fortnite.com/Characters }
using { /Verse.org/Colors }
using { /Fortnite.com/Game }
using { /Fortnite.com/FortPlayerUtilities }
using { /Fortnite.com/Playspaces }

shoot_prop_in_front_phone_call_mul_power := class<concrete>(remote_power_base):

    var MaybePlayspace : ?fort_playspace = false

    @editable
    PhoneCallSFX : audio_player_device = audio_player_device{}

    @editable
    PhoneCallPlane : creative_prop_asset = DefaultCreativePropAsset 

    @editable PlayTime : float = 7.0

    @editable AbilityCooldown : float = 20.0

    StopEvent<private>: event() = event(){}  

    Delete<public>():void=
        StopEvent.Signal()
        BreakPlayerViewLoop()
        
    PhoneCallSpawner(CP : CustomPlayer, CPMap : [agent]CustomPlayer)<suspends>:void=
        MaybePlayerInView := GetPlayerInView()
        var MaybeOtherAgent : ?agent = false
        if:
            Print("GOT PLAYER IN VIEW")
            MaybePlayerInView?
            set MaybeOtherAgent = option. agent[MaybePlayerInView?]
        else:
            Print("GOT CLOSEST PLAYER")
            set MaybeOtherAgent = FindClosestMaybeAgent(CP, CPMap)
        if (TargetAgent := MaybeOtherAgent?):
            if(FC : fort_character = TargetAgent.GetFortCharacter[], NearestPlayer := player[TargetAgent]):
                PhoneCallSFX.Play(TargetAgent)
                Sleep(0.1)
                FollowInFrontOfPlayer(TargetAgent, PhoneCallPlane, 50.0, PiFloat*0.5)


    FollowInFrontOfPlayer(Agent:agent, PropAsset:creative_prop_asset, DistanceInFront:float, PitchRadians:float)<suspends>:void=
        if (FC := Agent.GetFortCharacter[], Prop := SpawnProp(PropAsset, FC.GetTransform().Translation - vector3{Z:=1000.0}, IdentityRotation())(0)? ):
            race:
                StopEvent.Await()
                loop:
                    if(Prop.IsValid[]):
                        Transform := FC.GetTransform()
                        Translation := Transform.Translation
                        Rotation := Transform.Rotation
                        LocationForwardLocation := Rotation.GetLocalForward()
                        LocalForward := Rotation.GetLocalForward()
                        Forward := Translation + (LocalForward * DistanceInFront)
                        Prop.MoveTo(Forward, Rotation.ApplyYaw(PiFloat).ApplyPitch(PitchRadians), 0.1)
                    else:
                        Prop.Dispose()
                        break
                Sleep(PlayTime)
            Prop.Dispose()
            Print("Loop Canceled")