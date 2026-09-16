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

immune_power := class<concrete>(power_base):

    @editable
    IMMUNEPOWERTimer : timer_device = timer_device{}

    @editable
    ImmuneSFX : audio_player_device = audio_player_device{}

    @editable
    ImmuneVFX : visual_effect_powerup_device = visual_effect_powerup_device{}

    StopEvent<private>: event() = event(){}  

    var Happening : logic = false

    @editable
    AbilityCooldown : float = 20.0

    Delete<public>():void=
        StopEvent.Signal()
        set Happening = false

    
    ActivateAbilty(Agent : agent)<suspends>:void=
        if(FortChar := Agent.GetFortCharacter[]):
            if(not Happening?):
                set Happening = true
                ImmuneVFX.Pickup(Agent)
                IMMUNEPOWERTimer.Start(Agent)
                ImmuneSFX.Play(Agent)
                FortChar.SetVulnerability(false)
                race:
                    StopEvent.Await()
                    IMMUNEPOWERTimer.SuccessEvent.Await()
                    Sleep(5.0)
                FortChar.SetVulnerability(true)
                ImmuneSFX.Stop(Agent)
        set Happening = false

