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

flood_power := class<concrete>(remote_power_base):

    var MaybePlayspace : ?fort_playspace = false

    @editable
    WaterExplosive : explosive_device = explosive_device{}
    
    @editable
    WaterExplosive2 : explosive_device = explosive_device{}

    @editable
    WaterVolume :  water_device = water_device{}

    @editable
    WaterMover : creative_prop = creative_prop{}

    @editable
    WaterBarrier : barrier_device = barrier_device{}

    @editable
    FloodSFX : audio_player_device = audio_player_device{}

    @editable
    AbilityCooldown : float = 15.0

    Delete<public>():void=
        BreakPlayerViewLoop()
    
    EmptyWaterVolume()<suspends>:void=
        Sleep(5.0)
        WaterVolume.BeginVerticalEmptying()
        WaterBarrier.Disable()
        Sleep(2.0)
        WaterMover.MoveTo(TeleAwayPos, rotation{}, 0.01)

    ExplodeWater(Agent : agent)<suspends>:void=
        WaterExplosive.Explode(Agent) 
        WaterExplosive2.Explode(Agent) 
        Sleep(1.0)
        WaterExplosive.Reset()
        WaterExplosive2.Reset() 

    ActivateAbilty(CP : CustomPlayer, CPMap : [agent]CustomPlayer)<suspends>:void=
        MaybePlayerInView := GetPlayerInView()
        var MaybeOtherAgent : ?agent = false
        if:
            MaybePlayerInView?
            set MaybeOtherAgent = option. agent[MaybePlayerInView?]
        else:
            set MaybeOtherAgent = FindClosestMaybeAgent(CP, CPMap)
        if (TargetAgent := MaybeOtherAgent?, Agent := CP.MyAgentObj):
            if:
                FortChar : fort_character = TargetAgent.GetFortCharacter[]
                Location := FortChar.GetTransform()
                TargetLocation := FortChar.GetTransform()
                WaterMover.TeleportTo[TargetLocation]
            then:
                # set PowerIsActive = true
                spawn:
                    ExplodeWater(Agent)
                WaterBarrier.Enable()
                FloodSFX.Play(TargetAgent)
                WaterVolume.BeginVerticalFilling()
                spawn:
                    EmptyWaterVolume()