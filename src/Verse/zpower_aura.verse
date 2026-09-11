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

aura_power := class<concrete>(power_base):

    @editable
    AuraMutatorZone : mutator_zone_device = mutator_zone_device{}
    
    @editable
    AuraClassSelector : class_and_team_selector_device = class_and_team_selector_device{}

    @editable
    ResetVFX : visual_effect_powerup_device = visual_effect_powerup_device{}
    
    @editable
    AuraVFX : visual_effect_powerup_device = visual_effect_powerup_device{}

    @editable
    AuraSFX : audio_player_device = audio_player_device{}

    var IsSleeping:[agent]logic = map{}

    StopEvent<private>: event() = event(){}

    Delete():void=
        StopEvent.Signal()
        ResetVFX.Pickup()
        AuraMutatorZone.Disable()

    Init(Agent : agent):void=
        AuraClassSelector.ChangeClass(Agent)
        AuraMutatorZone.Enable()
        AuraVFX.Pickup(Agent)
        spawn. ActivateSleepAround(Agent)

    ActivateSleepAround(Agent : agent)<suspends>: void=
        Sleep(1.0)
        Print("Starting The Aura Loop")
        race:
            StopEvent.Await()
            loop:
                Sleep(0.1)
                if:
                    FortChar := Agent.GetFortCharacter[]
                    Location := FortChar.GetTransform()
                    AuraMutatorZone.TeleportTo[Location]
                else:
                    Print("CANCELING THE SHOT")
                    AuraMutatorZone.MoveTo(TeleAwayPos, rotation{}, 0.01)
                    AuraMutatorZone.Disable()
                    AuraSFX.Stop()
                    break
        if(AuraMutatorZone.TeleportTo[TeleAwayPos, rotation{}]){}