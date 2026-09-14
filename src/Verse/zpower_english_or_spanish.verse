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

#english or spanish
english_or_spanish_power := class<concrete>(power_base):

    @editable MutatorZoneDevice : mutator_zone_device = mutator_zone_device{}
    @editable AudioPlayerDevice : audio_player_device = audio_player_device{}
    @editable ExplosiveDevice : explosive_device = explosive_device{}
    @editable WarningHUD : hud_message_device = hud_message_device{}
    @editable AbilityDuration : float = 4.0
    @editable AbilityCooldown : float = 30.0
    @editable MovementCheckDelay : float = 0.3
    @editable MaxMoveDistance : float = 50.0
    @editable MaxRotateDegrees : float = 50.0
    @editable InitalDelay : float = 2.0
    @editable TimerDevice : timer_device = timer_device{}
    StopEvent<private>: event() = event(){}
    EliminatedEvent<private>: event() = event(){}

    # Stop Powerup
    Delete<public>():void=
        StopEvent.Signal()
        AudioPlayerDevice.Disable()
        Print("EnglishSpanish Deleted")

    # Powerup
    ActivateAbility<public>(CPMap:[agent]CustomPlayer, Agent : agent)<suspends>:void=
        AudioPlayerDevice.Enable()
        TimerDevice.Enable()
        ActiveAgents := GetActiveAgentsArray(CPMap) 
        if(A:=ActiveAgents[0]):
            ExplosiveDevice.Explode(A) 
            spawn { Reset() }
        for(A : ActiveAgents, F:= A.GetFortCharacter[]):
            spawn{NoMoving(A,F, Agent)}

    NoMoving<private>(A:agent,F:fort_character, ActivatorAgent : agent )<suspends>:void=
        F.PutInStasis(stasis_args{AllowEmotes := true, AllowFalling := true, AllowTurning := true})
        TimerDevice.Start(A)
        WarningHUD.Show(A)
        AudioPlayerDevice.Play(A)
        #TimerDevice.SuccessEvent.Await()
        Sleep(TimerDevice.GetMaxDuration())
        F.ReleaseFromStasis()
        Print("Timer is over")
        StartingTransform := F.GetTransform()
        InitalDegrees := Abs(RadiansToDegrees(StartingTransform.Rotation.GetAngle()))
        race:
            StopEvent.Await() # Checking if agent dies, game over
            EliminatedEvent.Await()
            Sleep(AbilityDuration)
            loop: # Checking for movement
                Sleep(MovementCheckDelay)
                if(DistanceSquared(StartingTransform.Translation,F.GetTransform().Translation) >= MaxMoveDistance): 
                    Print("English or Spanish: Agent died due to moving too much")
                    if(FC := ActivatorAgent.GetFortCharacter[]):
                        F.Damage(damage_args{Amount := 1000.0, Instigator := option{FC}, Source := option {custom_game_action_causer{} }})
                    EliminatedEvent.Signal()
                    break
            loop:
                Sleep(MovementCheckDelay) # Checking for rotation
                # 180 - 190 = 10
                # 180 - 140 = 40
                # 180 - 250 = 70
                if(Abs(RadiansToDegrees(F.GetTransform().Rotation.GetAngle()) - InitalDegrees) >= MaxRotateDegrees):
                    Print("{Abs(RadiansToDegrees(F.GetTransform().Rotation.GetAngle()) - InitalDegrees)} >= {MaxRotateDegrees}")
                    Print("English or Spanish: Agent died to rotating too much")
                    if(FC := ActivatorAgent.GetFortCharacter[]):
                        F.Damage(damage_args{Amount := 1000.0, Instigator := option{FC}, Source := option {custom_game_action_causer{} } })

                    EliminatedEvent.Signal()
                    break
        Print("Loop Canceled")

        AudioPlayerDevice.Stop(A)
        WarningHUD.Hide(A)
        TimerDevice.ResetForAll()

    GetActiveAgentsArray<private>(AllCPMap:[agent]CustomPlayer):[]agent=
        var AgentArray : []agent = array{}
        for(Key -> Value : AllCPMap):
            IsInLobby := Value.GetIsInLobby()
            # if player is not in lobby = player active?
            if(not IsInLobby?):
                set AgentArray += array{Key}
        return AgentArray

    Reset<private>()<suspends>:void=
        Sleep(2.0)
        ExplosiveDevice.Reset()
    
