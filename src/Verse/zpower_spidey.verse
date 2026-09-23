using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Assets }
using { /Verse.org/Random }
using { /Verse.org/Colors/NamedColors }
using { /Fortnite.com/Characters }
using { /Verse.org/Colors }
using { /Fortnite.com/Game }
using { /Fortnite.com/FortPlayerUtilities }

spidey_power := class<concrete>(power_base):

    @editable
    InputTriggerDevice : input_trigger_device = input_trigger_device{}

    @editable
    MovementModulator : movement_modulator_device = movement_modulator_device{}

    @editable
    MaxJumpWindow : float = 0.5  # seconds allowed between the two taps

    var JumpEventCount  : int   = 0
    ResetTimerEvent : event() = event(){}
    StopEvent       : event() = event(){}

    # Hold the agent so we can unregister in Delete()
    var Owner : ?agent = false

    Init<public>(InAgent : agent):void=
        set Owner = option{InAgent}

        # Register / enable the devices for this player
        InputTriggerDevice.Register(InAgent)
        InputTriggerDevice.Enable()
        MovementModulator.Enable()

        if(Fort := InAgent.GetFortCharacter[]):
            spawn. ListenForJump(InAgent)

    Delete<public>():void=
        StopEvent.Signal()

        if(Agent := Owner?):
            InputTriggerDevice.Unregister(Agent)

        InputTriggerDevice.Disable()
        MovementModulator.Disable()

    ListenForJump<private>(Agent : agent)<suspends>:void=
        race:
            StopEvent.Await()

            loop:
                # Wait for *this* player to press the configured jump input
                PressedAgent := InputTriggerDevice.PressedEvent.Await()
                if(PressedAgent = Agent):
                    HandleJumpTap(Agent)

    HandleJumpTap<private>(Agent:agent):void=
        set JumpEventCount += 1

        # If this is the *first* tap, start (or restart) the reset timer
        if(JumpEventCount = 1):
            ResetTimerEvent.Signal()       # cancel any existing timer
            spawn { ResetJumpCounter() }   # start a fresh one

        # Second tap within the window triggers the boost
        if(JumpEventCount >= 2):
            set JumpEventCount = 0
            DoDoubleJumpBoost(Agent)

    ResetJumpCounter<private>()<suspends>:void=
        var LocalResetEvent : event() = ResetTimerEvent  # capture reference
        race:
            # Allow another coroutine to cancel us instantly by signalling again
            LocalResetEvent.Await()
            Sleep(MaxJumpWindow)
            
        set JumpEventCount = 0     # window expired -> fresh count

    DoDoubleJumpBoost<private>(Agent:agent):void=
        MovementModulator.Activate(Agent)