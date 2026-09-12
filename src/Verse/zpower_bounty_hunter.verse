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

bounty_hunter_power := class<concrete>(power_base):

    @editable ItemGranter : item_granter_device = item_granter_device{}
    @editable BeaconDevice : beacon_device  = beacon_device{}
    @editable AudioPlayer : audio_player_device = audio_player_device{}
    @editable AudioPlayer2 : audio_player_device = audio_player_device{}
    @editable BeaconUpdateDelay : float = 0.1
    var ESPPosition : vector3 = vector3{X:=0.0,Y:=0.0,Z:=220.0}
    StopEvent<private>: event() = event(){}
    
    @editable UISearching : string = "Searching for Bounty"
    @editable UIFound : string = "Eliminate Bounty"
    @editable UIEliminated : string = "Bounty Eliminated"
    @editable UIPoached : string = "Bounty Poached"
    @editable BountySearchingTime : float = 5.0
    @editable ShowBountyEliminatedOrPoachedTime : float = 3.0
    var HealingDone : float = 0.0
    var MaybeTimerUI : ?Timer = false

    #var PlayersMap : [agent]CustomPlayer = map{}
    # Start Powerup
    Init<public>(ThisCP:CustomPlayer,AllCPMap:[agent]CustomPlayer,TimerUI:Timer)<suspends>:void=

        set HealingDone = 0.0 # UI STUFF
        set MaybeTimerUI = option{TimerUI} # UI STUFF
        TimerUI.ShowTimer() # UI STUFF
        TimerUI.Update("")  # UI STUFF

        spawn{ActivatePowerup(ThisCP,AllCPMap)}

    # Stop Powerup
    Delete<public>():void=
        StopEvent.Signal()
        ItemGranter.Disable()
        BeaconDevice.RemoveAllFromShowList()
        BeaconDevice.Disable()
        Print("Bounty Delete Got Called")

    # Powerup
    ActivatePowerup<private>(ThisCP:CustomPlayer,AllCPMap:[agent]CustomPlayer)<suspends>:void=
        ThisAgent := ThisCP.MyAgentObj
        if(TimerUI := MaybeTimerUI?): # UI STUFF
            race:
                StopEvent.Await()
                loop:
                    TimerUI.Update(UISearching) # UI STUFF
                    Sleep(BountySearchingTime)  # UI STUFF
                    Print("Searching for next bounty")
                    MaybeChosenAgent := FindRandomActiveAgent(AllCPMap)
                    if(ChosenAgent := MaybeChosenAgent?, ChosenAgent <> ThisAgent, ChosenFort := ChosenAgent.GetFortCharacter[]):
                        Print("Found new bounty")
                        AudioPlayer.Play(ThisAgent)
                        TimerUI.Update(UIFound) # UI STUFF
                        BeaconDevice.Enable()
                        BeaconDevice.AddToShowList(ThisAgent)
                        race:
                            loop:
                                Sleep(0.1)
                                ElimResult := ChosenFort.EliminatedEvent().Await()
                                if:
                                    Eliminating := ElimResult.EliminatingCharacter?
                                    EliminatingAgent := Eliminating.GetAgent[]
                                    EliminatingAgent = ThisAgent
                                then:
                                    AudioPlayer2.Play(ThisAgent)
                                    ItemGranter.Enable()
                                    ItemGranter.GrantItem(ThisAgent)
                                    ItemGranter.Disable()
                                    Print("Bounty eliminated by bounty hunter")
                                    TimerUI.Update(UIEliminated) # UI STUFF
                                else:
                                    #AudioPlayer.Play(ThisAgent)
                                    Print("Bounty poached")
                                    TimerUI.Update(UIPoached) # UI STUFF
                                BeaconDevice.RemoveFromShowList(ThisAgent)
                                BeaconDevice.Disable()
                                break
                            loop:
                                Sleep(BeaconUpdateDelay)
                                if(BeaconDevice.TeleportTo[ChosenFort.GetTransform().Translation - ESPPosition, rotation{}]){}

            Print("Loop Canceled")
                        Sleep(ShowBountyEliminatedOrPoachedTime) # UI STUFF

    GetActiveAgentsArray<private>(AllCPMap:[agent]CustomPlayer):[]agent=
        var AgentArray : []agent = array{}
        for(Key -> Value : AllCPMap):
            IsInLobby := Value.GetIsInLobby()
            # if player is not in lobby = player active?
            if(not IsInLobby?):
                set AgentArray += array{Key}
        return AgentArray

    FindRandomActiveAgent<private>(AllCPMap:[agent]CustomPlayer):?agent=
        var RandomAgent : ?agent = false
        ActiveAgentsArray := GetActiveAgentsArray(AllCPMap)
        if(RandomActiveAgent := ActiveAgentsArray[GetRandomInt(0, ActiveAgentsArray.Length - 1)]):
            set RandomAgent = option{RandomActiveAgent}
        return RandomAgent