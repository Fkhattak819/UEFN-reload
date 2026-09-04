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


FindClosestMaybeAgent(CP:CustomPlayer,CPMap:[agent]CustomPlayer):?agent=
    Print("FindClosestAgent Called")
    var ClosestAgent : ?agent = false
    var ClosestDistance : float = 100000000.0
    ThisAgent := CP.MyAgentObj
    if(ThisFort := ThisAgent.GetFortCharacter[]):
        FortT := ThisFort.GetTransform().Translation
        for(CurrentAgent -> CurrentCP : CPMap, CurrentAgent <> ThisAgent):
            if(not CurrentCP.IsInLobby?):
                Print("Current agent is not in lobby")
                if(CurrentFort := CurrentAgent.GetFortCharacter[]):
                    CurrentDistance := Distance(CurrentFort.GetTransform().Translation,FortT)
                    if(CurrentDistance <= ClosestDistance):
                        Print("Setting new closest agent")
                        set ClosestDistance = CurrentDistance
                        set ClosestAgent = option{CurrentAgent}
            else{Print("Current agent is in lobby")}
    return ClosestAgent

FindClosestPlayer(Agent : agent, Playspace : fort_playspace)<transacts>:?agent=
    AllPlayers : []player = Playspace.GetPlayers()
    PlayerCount : int = AllPlayers.Length

    var ClosestPlayer : ?agent = false
    var DistanceToMe : float = 100000000.0
    var FoundPlayer : logic = false
    for (Player : AllPlayers):
        if(Player <> Agent):
            if (MyFC : fort_character = Agent.GetFortCharacter[]):
                if (OtherFC : fort_character = Player.GetFortCharacter[]):
                    MyPos : vector3 = MyFC.GetTransform().Translation
                    OtherPos : vector3 = OtherFC.GetTransform().Translation
                    TotalDistance : float = Distance(MyPos, OtherPos) / 100.0
                    if (TotalDistance < DistanceToMe):
                        set FoundPlayer = true
                        set DistanceToMe = TotalDistance
                        set ClosestPlayer = option{Player}
                        
    if (FoundPlayer = true):
        return ClosestPlayer
    return false

ApplyVFX(TargetAgent : agent, EffectDevice : visual_effect_powerup_device, ResetDevice : trigger_device)<suspends>:void=
    var PulseNumber : int = 0
    loop:
        EffectDevice.Pickup(TargetAgent)
        set PulseNumber += 1
        if(PulseNumber = 3):
            Print("VFX sequence active")
            break
        Sleep(0.1)
        ResetDevice.Trigger(TargetAgent)
        Print("VFX reset applied")
        Sleep(0.1)

MovePropToSelf(Agent : agent, CreativeProp : creative_prop):void=
    if:
        FortChar := Agent.GetFortCharacter[]
        CurrentTransform := FortChar.GetTransform()
        CreativeProp.TeleportTo[CurrentTransform]

power_base := class<concrete>():
    @editable PowerUI : hud_message_device = hud_message_device{}
    var TeleAwayPos : vector3 = vector3{X := 0.0, Y := 0.0, Z := -2000.0}

remote_power_base_general := class<concrete>():
    @editable AngleThreshold : int = 14
    @editable RemoteChecker : conditional_button_device = conditional_button_device{}
    # @editable TestProps : []creative_prop = array{}
    @editable XrayBeacon : beacon_device = beacon_device{}

remote_power_base := class<concrete>(power_base):
    @editable RemoteRemover<public>: item_remover_device = item_remover_device{}
    @editable RemoteGeneral<public>: remote_power_base_general = remote_power_base_general{}
    var LastSeenPlayer<public>: ?player = false
    BreakEvent<private>: event() = event(){}  

    BreakPlayerViewLoop<public>():void=
        Print("Broke Race and Loop")
        BreakEvent.Signal()
        RemoteGeneral.XrayBeacon.Disable()
      
    IsPlayerLookingAtEnemy<private>(Agent : agent, PlayersMap : [agent]CustomPlayer):tuple(logic, ?player, vector3)=
        for (oAgent-> CP : PlayersMap):
            if(oPlayer := player[oAgent], oFC := oAgent.GetFortCharacter[], Agent <> oAgent, MyFC := Agent.GetFortCharacter[], oFC.IsActive[]):
                OtherFCLocation := oFC.GetTransform().Translation
                MyFCLocation := MyFC.GetTransform().Translation
                CurrentDistance := Distance(MyFCLocation,oFC.GetTransform().Translation)
                if(CurrentDistance <= 15000.0 and RemoteGeneral.RemoteChecker.IsHoldingItem[Agent]):
                    if(FCLookDirection := (OtherFCLocation - MyFCLocation).MakeUnitVector[], FCForward := MyFC.GetViewRotation().GetLocalForward().MakeUnitVector[]):
                        Dot := DotProduct(FCLookDirection, FCForward)
                            if(Angle := Floor[ArcCos(Dot)*(180.0 / 3.141592653589793)], FinalAngle := Abs(Angle)):
                                if(FinalAngle <= RemoteGeneral.AngleThreshold):
                                    return (true, option{oPlayer}, OtherFCLocation)

        return (false, false, vector3{})

    PickTarget(CP : CustomPlayer, CPMap : [agent]CustomPlayer):?agent =
        var Chosen : ?agent = false
        if (MaybePlayerInView := GetPlayerInView()?):
            set Chosen = option. agent[MaybePlayerInView]
        else:
            set Chosen = FindClosestMaybeAgent(CP, CPMap)
        
        return Chosen

    # REVISIT FOR BUG FIXES WITH REMOTE POWERS
    PlayerInViewAsync<public>(CP : CustomPlayer, PlayersMap : [agent]CustomPlayer, CTimer : Timer)<suspends>:void=
        RemoteGeneral.XrayBeacon.Enable()
        Agent := CP.MyAgentObj
        if(FC := Agent.GetFortCharacter[]):
            Print("Start Beacon Race")
            race:
                BreakEvent.Await()
                block:
                    loop:
                        Sleep(0.0)
                        if(RemoteGeneral.RemoteChecker.IsHoldingItem[Agent]):
                            Tuple := IsPlayerLookingAtEnemy(Agent, PlayersMap)
                            FoundPlayer := Tuple(0)
                            Enemy := Tuple(1)
                            Location := Tuple(2)
                            TeleDelay := 0.1
                            if(FoundPlayer? and not CTimer.IsActive?): 
                                RemoteGeneral.XrayBeacon.AddToShowList(Agent)
                                RemoteGeneral.XrayBeacon.MoveTo(vector3{X := Location.X, Y := Location.Y, Z := Location.Z - 240.0}, rotation{}, TeleDelay)
                                SetPlayerInView(Enemy)
                                Print("Moving Beacon")
                            else:
                                Sleep(0.0)
                                RemoteGeneral.XrayBeacon.RemoveAllFromShowList()
                        else:
                            Sleep(0.1)
                            RemoteGeneral.XrayBeacon.RemoveAllFromShowList()

        set LastSeenPlayer = false
        RemoteGeneral.XrayBeacon.Disable()

    SetPlayerInView<private>(Player :?player):void=
        set LastSeenPlayer = Player
        if (Agent := agent[LastSeenPlayer?]):
            Print(P2M(Agent))
            
    GetPlayerInView<public>()<transacts>:?player=
        if(LastSeenPlayer?):
            return LastSeenPlayer
        return false


# Adds HP or Shield or both if neccesary
AddHPOrShield(Fort : fort_character, IncomingHealing : float):void=
    MaxHP := Fort.GetMaxHealth()
    MaxShield := Fort.GetMaxShield()
    var CurrentHP : float = Fort.GetHealth()
    var CurrentShield : float = Fort.GetShield()
    var HealingDone : float = 0.0
    var HealingNumber : float = IncomingHealing
    var HealthCalculation : float = MaxHP - CurrentHP # How much HP does player need
    var ShieldCalculation : float = MaxShield - CurrentShield # How much Shield does player need
    if(CurrentHP = MaxHP and CurrentShield = MaxShield) { }
    #Print("Incoming Current HP: {CurrentHP} = { Fort.GetHealth()}")
    #Print("Incoming Current Shield: {CurrentShield} = { Fort.GetShield()}")
    if(HealthCalculation <> 0.0): # 1.If player is not max HP
        #Print("Player Needs HP")
        if(HealthCalculation >= HealingNumber): # 2.Does he need all of the healing for HP
            #Print("Player needs MAX HP healing")
            Fort.Heal(HealingNumber)
            set CurrentHP += HealingNumber
            set HealingNumber = 0.0
        else: # 3.If player needs less HP than incoming healing
            #Print("Player needs PARTIAL HP healing")
            #Print("Played Healed from {CurrentHP}to {HealthCalculation + CurrentHP}")
            Fort.Heal(HealthCalculation)
            set CurrentHP += HealthCalculation
            set HealingNumber -= HealthCalculation
    if(ShieldCalculation <> 0.0 and HealingNumber <> 0.0): #1.If Player needs Shield and Healing was not all used up already
        #Print("Healing for shield has not been used and player needs shield")
        if(ShieldCalculation >= HealingNumber): # 2.Does he need all of the healing for Shield
            #Print("Player needs MAX Shield healing")
            Fort.SetShield(CurrentShield + HealingNumber)
            set CurrentShield += HealingNumber
            set HealingNumber = 0.0  
        else:
            #Print("Player needs PARTIAL Shield healing")
            #Print("Played Healed from {CurrentShield}to {ShieldCalculation + CurrentShield}")
            Fort.SetShield(CurrentShield + ShieldCalculation) # 3.If player needs less Shield than incoming healing
            set CurrentShield += ShieldCalculation
            set HealingNumber -= ShieldCalculation
