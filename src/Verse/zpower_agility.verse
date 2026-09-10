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

agility_power := class<concrete>(power_base):

    @editable NomalHealth : float = 100.0
    @editable CrouchingHealth : float = 50.0
    @editable DamageAmp : damage_amplifier_powerup_device  = damage_amplifier_powerup_device {}
    @editable DisableDamageAmpDevice : trigger_device = trigger_device{}
    @editable AudioPlayer : audio_player_device = audio_player_device{}


    StopEvent<private>: event() = event(){}

    @editable UITextActive : string = "Active"
    @editable UITextInactive : string = "Inactive"
    var MaybeTimerUI : ?Timer = false

    # Start Powerup
    Init<public>(InAgent:agent,TimerUI:Timer):void=

        set MaybeTimerUI = option{TimerUI}
        TimerUI.ShowTimer()
        TimerUI.Update(UITextInactive) 

        if(Fort:=InAgent.GetFortCharacter[]):
            spawn{ActivatePowerup(InAgent,Fort)}

    # Stop Powerup
    Delete<public>():void=
        StopEvent.Signal()
        DamageAmp.Despawn()
        AudioPlayer.Stop()
        # DisableDamageAmpDevice.Disable()
        Print("Agility Deleted")

    # Powerup
    ActivatePowerup<private>(Agent:agent,Fort:fort_character)<suspends>:void=
        if(TimerUI := MaybeTimerUI?):
            race:
                StopEvent.Await()
                loop:
                    Sleep(0.1)
                    Result := Fort.CrouchedEvent().Await()
                    if(Result(1) = true):
                        Print("Player Crouched")
                        Fort.SetMaxHealth(CrouchingHealth)
                        Fort.SetMaxShield(CrouchingHealth)
                        DamageAmp.Spawn()
                        DamageAmp.SetMagnitude(2.0)
                        DamageAmp.Pickup(Agent)
                        TimerUI.Update(UITextActive)
                        AudioPlayer.Play(Agent)
                    else:
                        Print("Player Uncrouched")
                        # DisableDamageAmpDevice.Trigger(Agent)
                        DamageAmp.Spawn()
                        DamageAmp.SetMagnitude(1.0)
                        DamageAmp.Pickup(Agent)
                        Fort.SetMaxHealth(NomalHealth)
                        Fort.SetMaxShield(NomalHealth)
                        TimerUI.Update(UITextInactive)
                        AudioPlayer.Stop()


            Print("Loop Canceled")

                    
        # Does the damageamp device still work for this player once it gets enabled in the next round?
        Print("broke out of racebroke out of racebroke out of racebroke out of racebroke out of racebroke out of racebroke out of racebroke out of racebroke out of racebroke out of racebroke out of racebroke out of racebroke out of racebroke out of race")
        # DisableDamageAmpDevice.Trigger(Agent)
        spawn. Reset(Fort, Agent)
        
    Reset(Fort : fort_character, Agent : agent)<suspends>:void=
        DamageAmp.Spawn()
        DamageAmp.SetMagnitude(1.0)
        DamageAmp.Pickup(Agent)
        Fort.SetMaxHealth(NomalHealth)
        Fort.SetMaxShield(NomalHealth)