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

aimbot_power := class<concrete>(power_base):

    @editable AbilityDuration : float = 30.0
    @editable AbilityCooldown : float = 30.0
    @editable CrouchesToActivateDeactivate : int = 2
    @editable RemoveCrouchDelay : float = 1.0
    @editable AimerDevice : gameplay_controls_third_person_device = gameplay_controls_third_person_device {}
    @editable MutatorDevice : mutator_zone_device = mutator_zone_device{}
    StopEvent<private>: event() = event(){}

    @editable 
    UITextActivate : string = "Spam Crouch to Activate"

    @editable 
    UITextDeactivate : string = "Emote to Deactivate"

    var MaybeTimerUI : ?Timer = false

    # Start Powerup
    Init<public>(A:agent,TimerUI:Timer):void=

        TimerUI.ShowTimer()
        set MaybeTimerUI = option{TimerUI}

        if(F:=A.GetFortCharacter[],P:=player[A]):
            spawn{ActivatePowerup(F,A,P)}

    # Stop Powerup
    Delete<public>():void=
        StopEvent.Signal()
        Print("Aimer Deleted")

    # Sends `tuple` payload:
    #  - 0: the `fort_character` that changed crouch states.
    #  - 1: `true` if the character is crouching. `false` if the character is not crouching.

    # Powerup
    ActivatePowerup<private>(F:fort_character,A:agent,P:player)<suspends>:void=
        var CrouchCounter : int = 0
        if(TimerUI := MaybeTimerUI?):
            race:
                StopEvent.Await()
                loop:
                    Sleep(0.0)
                    Print("Aimer info print, Current Crouches:{CrouchCounter}\nCrouchesToActivateDeactivate:{CrouchesToActivateDeactivate}")
                    Sleep(RemoveCrouchDelay)
                    if(CrouchCounter >= 1):
                        set CrouchCounter -= 1
                loop:
                    Sleep(0.0)
                    TimerUI.Update(UITextActivate)
                    ActivateResult := F.CrouchedEvent().Await()
                    if(ActivateResult(1)?):
                        set CrouchCounter += 1
                        Print("Aimer: Adding crouch to ACTIVATE")
                    if(CrouchCounter >= CrouchesToActivateDeactivate):
                        Print("Aimer: Ability Active")
                        set CrouchCounter = 0
                        TimerUI.Update(UITextDeactivate)
                        AimerDevice.Enable()
                        AimerDevice.AddTo(P)
                        race:
                            Sleep(AbilityDuration)
                            loop:
                                Sleep(0.0)
                                Result := MutatorDevice.AgentBeginsEmotingEvent.Await()
                                if(Result = A):
                                    Print("Aimer: Disabling ability")
                                    break
                        #Sleep(AbilityCooldown)
                        AimerDevice.RemoveFrom(P)
                        AimerDevice.Disable()
                        TimerUI.StartCountdown(AbilityCooldown)

            Print("Loop Canceled")

        AimerDevice.RemoveFrom(P)
        AimerDevice.Disable()
