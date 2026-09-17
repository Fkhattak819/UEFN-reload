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

jumpscare_power := class<concrete>(remote_power_base):

    var MaybePlayspace : ?fort_playspace = false

    @editable
    JumpScareBomb : explosive_device = explosive_device{}

    @editable
    JumpScareMover : creative_prop = creative_prop{}

    @editable
    JumpScareSFX : audio_player_device = audio_player_device{}

    @editable
    JumpScareCamera : gameplay_camera_fixed_point_device = gameplay_camera_fixed_point_device{}

    @editable
    ImmunityVFX : immunity_manager = immunity_manager{}

    @editable
    AbilityCooldown: float = 20.0

    @editable
    PlayTime : float = 4.0

    StopEvent<private>: event() = event(){}  

    Delete<public>():void=
        StopEvent.Signal()
        BreakPlayerViewLoop()

    FreddyFreezePlayer(FortCharacter : fort_character, FreddyProp : creative_prop)<suspends>:void=
        if(Agent := FortCharacter.GetAgent[]):
            race:
                StopEvent.Await()
                block:
                    Sleep(0.0)
                    # FortCharacter.Hide()
                    FortCharacter.PutInStasis(stasis_args{})
                    FortCharacter.SetVulnerability(false)
                    JumpScareBomb.Explode(Agent)
                    Sleep(PlayTime)
                    JumpScareSFX.Stop()
                    JumpScareCamera.RemoveFrom(Agent)
                    FortCharacter.Show()
                    JumpScareBomb.Reset()
                    FortCharacter.ReleaseFromStasis()
                    FortCharacter.SetVulnerability(true)

            #sending prop back
            if (FreddyProp.TeleportTo[TeleAwayPos, FortCharacter.GetTransform().Rotation]) {}
            JumpScareCamera.RemoveFrom(Agent)
            spawn. ImmunityVFX.Apply(Agent)

    ActivateAbility(CP : CustomPlayer, CPMap: [agent]CustomPlayer)<suspends>:void=
        MaybePlayerInView := GetPlayerInView()
        var MaybeOtherAgent : ?agent = false
        if:
            MaybePlayerInView?
            set MaybeOtherAgent = option. agent[MaybePlayerInView?]
        else:
            set MaybeOtherAgent = FindClosestMaybeAgent(CP, CPMap)
        if (TargetAgent := MaybeOtherAgent?):
            if(FC : fort_character = TargetAgent.GetFortCharacter[]):
                Pos : vector3 = FC.GetTransform().Translation
                Rotation : rotation = FC.GetViewRotation()
                Offset : vector3 = Rotation.RotateVector(vector3{X:=0.0, Y:=0.0, Z:=0.0})
                Destination : vector3 = Pos + Offset
                if (JumpScareMover.TeleportTo[Destination, Rotation]):
                    JumpScareSFX.Play(TargetAgent)
                    JumpScareCamera.AddTo(TargetAgent)
                    spawn:
                        FreddyFreezePlayer(FC, JumpScareMover)