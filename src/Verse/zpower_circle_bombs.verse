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

circle_bombs_power := class<concrete>(power_base):


    @editable AbilityCooldown : float = 30.0
    @editable AbilityActive : float = 5.0
    @editable Radius : float = 2000.0
    @editable Slices : int = 50
    Degrees : float = 360.0
    @editable CheckingDamageDelay : float = 0.5
    @editable DamageDistance : float = 200.0
    @editable DamageAmount : float = 25.0
    @editable MoveToDuration : float = 5.0
    @editable VFXDespawnDelay : float = 2.0
    @editable Prop_BP : creative_prop_asset = DefaultCreativePropAsset
    @editable VFX_BP : creative_prop_asset = DefaultCreativePropAsset
    @editable AudioPlayer : audio_player_device = audio_player_device{}
    StopEvent<private>: event() = event(){}

    var DamageDealt : float = 0.0
    @editable UIText : string = "Damage Dealt: "
    var MaybeTimerUI : ?Timer = false
    @editable RemoveUIAfterAbilityDelay : float = 3.0

    Init<public>(TimerUI:Timer):void=
        set MaybeTimerUI = option{TimerUI}

    UpdateUI<private>():void=
        if(RoundedExtra := Round[DamageDealt], TimerUI := MaybeTimerUI?):
            TimerUI.Update(UIText + "{DamageDealt}") 

    # Stop Powerup
    Delete<public>():void=
        StopEvent.Signal()
        Print("Surround Attack Deleted")

    RemoveUIDelay<private>()<suspends>:void=
        race:
            StopEvent.Await()
            block:
                Sleep(AbilityActive + RemoveUIAfterAbilityDelay)
                if(TimerUI := MaybeTimerUI?):
                    TimerUI.HideTimer()

    # Activate Powerup
    ActivatePowerup<public>(ThisCP:CustomPlayer,AllCPMap:[agent]CustomPlayer)<suspends>:void=
        if(TimerUI := MaybeTimerUI?):
            set DamageDealt = 0.0
            TimerUI.ShowTimer()
            UpdateUI()
            # spawn{RemoveUIDelay()}
        ThisAgent:=ThisCP.MyAgentObj
        if(ThisFort:=ThisAgent.GetFortCharacter[]):
            MoveToLocations := GetMoveToLocationsArray(ThisFort)
            ActiveAgents := GetActiveAgentsArray(ThisAgent,AllCPMap)
            for(MoveToLoc : MoveToLocations):
                MaybeProp := SpawnProp(Prop_BP,ThisFort.GetTransform().Translation,rotation{})(0)
                if(Prop := MaybeProp?):
                    spawn . HandlePropLogic(ThisCP, Prop, MoveToLoc, ActiveAgents)
                AudioPlayer.Play(ThisAgent)

    HandlePropLogic<private>(CP:CustomPlayer, Prop:creative_prop, MoveToLoc:vector3, ActiveAgents:[]agent)<suspends>:void=
        race:
            StopEvent.Await()
            loop:
                Sleep(CheckingDamageDelay)
                PropPos := Prop.GetTransform().Translation
                for(A:ActiveAgents,F:=A.GetFortCharacter[]):
                    FortPos:=F.GetTransform().Translation
                    if(Distance(FortPos,PropPos) <= DamageDistance):
                        if (ThisAgent := CP.MyAgentObj, ThisFort := ThisAgent.GetFortCharacter[]):
                            F.Damage(damage_args{Amount := DamageAmount, Instigator := option {ThisFort}, Source := option {custom_game_action_causer{} }})
                            set DamageDealt += DamageAmount
                            UpdateUI()
                            MaybeVFX := SpawnProp(VFX_BP,PropPos,rotation{})(0)
                            if(VFX := MaybeVFX?):
                                spawn . DespawnVFX(VFX)
            block:
                MoveToResult := Prop.MoveTo(MoveToLoc,rotation{},MoveToDuration)
                if(MoveToResult = move_to_result.DestinationReached):

        Print("Loop Canceled")
        Prop.Dispose()

    DespawnVFX<private>(Prop:creative_prop)<suspends>:void=
        Sleep(VFXDespawnDelay)
        Prop.Dispose()

    GetMoveToLocationsArray<public>(F:fort_character):[]vector3=
        var CirclePoints : []vector3 = array{}
        FortPos:=F.GetTransform().Translation
        NewRadians := 2*PiFloat/(Slices * 1.0)
        for(I:=0 .. Slices - 1):
            X := FortPos.X + Radius * Cos(NewRadians*(I * 1.0))
            Y := FortPos.Y + Radius * Sin(NewRadians*(I * 1.0))
            set CirclePoints += array{vector3{X:=X,Y:=Y,Z:=FortPos.Z}}
        return CirclePoints

    GetActiveAgentsArray<private>(ThisAgent:agent,AllCPMap:[agent]CustomPlayer):[]agent=
        var AgentArray : []agent = array{}
        for(Key -> Value : AllCPMap, Key <> ThisAgent):
            IsInLobby := Value.GetIsInLobby()
            # if player is not in lobby = player active?
            if(not IsInLobby?):
                set AgentArray += array{Key}
        return AgentArray
