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

sleep_regen_power := class<concrete>(power_base):

    @editable
    SleepAudio : audio_player_device = audio_player_device{}

    @editable
    SleepBP : creative_prop = creative_prop{}

    @editable
    SleepHealthStopTrigger : trigger_device = trigger_device{}

    @editable
    SleepHealthRegen : health_powerup_device = health_powerup_device{}

    @editable
    SleepPopUp : popup_dialog_device = popup_dialog_device{}
    
    @editable
    SleepInvincibleDurationTimer : timer_device = timer_device{}
    
    SleepRegenSpawner(Agent : agent)<suspends>:void=
        if:
            FortChar := Agent.GetFortCharacter[]
            Location := FortChar.GetTransform()

        then:
            SleepAudio.Play(Agent)
            FortChar.PutInStasis(stasis_args{})
            # SleepPlayerReference.Register(Agent)
            MovePropToSelf(Agent, SleepBP)
            FortChar.Hide()
            FortChar.SetVulnerability(false)
            SleepHealthRegen.Pickup(Agent)
            SleepInvincibleDurationTimer.Start(Agent)
            SleepPopUp.Show(Agent)
            race:
                SleepPopUp.RespondingButtonEvent.Await()
                SleepInvincibleDurationTimer.SuccessEvent.Await()
            SleepBP.MoveTo(TeleAwayPos, rotation{}, 0.01)
            Print("Finshed the animation")
            SleepAudio.Stop()
            SleepInvincibleDurationTimer.Complete(Agent)
            SleepHealthStopTrigger.Trigger(Agent)
            SleepPopUp.Hide(Agent)
            FortChar.SetVulnerability(true)
            FortChar.Show()
            FortChar.ReleaseFromStasis()
            SleepBP.MoveTo(TeleAwayPos, rotation{}, 0.01)

