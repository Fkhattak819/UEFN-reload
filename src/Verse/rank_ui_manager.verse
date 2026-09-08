using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Assets }
using { /Verse.org/Colors }
using { /Fortnite.com/Game }
using { /Fortnite.com/Characters }

Default_Rank_Value<public> := class<concrete>{
    @editable Value1 : int = 25
    @editable Value2 : int = 75
    @editable Value3 : int = 175
    @editable Value4 : int = 250
    @editable Value5 : int = 450 
    @editable Value6 : int = 650
    @editable Value7 : int = 750
    @editable Value8 : int = 900
    @editable Value9 : int = 1200
    @editable Value10: int = 1400
    @editable Value11: int = 1750
    @editable Value12: int = 2000
    @editable Value13: int = 2200
    @editable Value14: int = 2500
    @editable Value15: int = 3000
    @editable Value16: int = 3400
    @editable Value17: int = 4000
    @editable Value18: int = 5000
    @editable Value19: int = 7000
}
General<public> := struct<concrete>{ 
    @editable EloGainPerKill<public>  : int = 5
    @editable EloLossPerDeath<public>  : int = 2
    @editable RankGoals<public>  : ?Default_Rank_Value = false
    @editable PromotedSound<public>  : audio_player_device = audio_player_device{}
    @editable DemotedSound<public>  : audio_player_device = audio_player_device{}
    @editable RankUpXp<public>  : accolades_device = accolades_device{}
    @editable Version : int = 1
}  

Debug := struct<concrete>{
    @editable IncrementButton<public>  : button_device = button_device{}
    @editable DecrementButton<public>  : button_device = button_device{}
}

DisplayStats:= struct<concrete><public>{ 
    @editable StatWidgetDisplayTime: float = 5.0
    @editable StatsBillboard : billboard_device = billboard_device{}
    @editable DisplayPlayerStatsButton : button_device = button_device{}
    @editable StatsXP : accolades_device = accolades_device{}   
    @editable PlayerReference : player_reference_device = player_reference_device{}
    @editable DisplayRankProp : creative_prop = creative_prop{}
} 

# A Verse-authored creative device that can be placed in a level
RankSystem := class(creative_device):
    var EloDenominators : []int = array{ 25, 75, 175, 250, 450, 650, 750, 900, 1200, 1400, 1750 , 2000, 2200, 2500, 3000, 3400, 4000, 5000, 7000}
    S2Ms<localizes>(value:string)<computes> : message = "{value}" 
    @editable Spawners : []player_spawner_device = array{}
    @editable DebugButtons : Debug = Debug{}
    @editable GeneralSettings : General = General{}
    @editable Display_Stats : DisplayStats = DisplayStats{}
    ATM<localizes>(value:agent)<computes> : message = "{value}"

    # you store a custom_player class for each player in the game here
    var Custom_Player_Map: [player]Ranked_Player = map{}
    # Verse Persistence Stats Manager
    var PlayerStatsManager : player_stats_manager = player_stats_manager{}

  
    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        # When a Player Leaves we need to remove there Custom_Player_UI from the map to free up memory  
        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerLeft)
        # This Button Increments The Player Ui
        DebugButtons.IncrementButton.InteractedWithEvent.Subscribe(OnEliminationButton)
        # This Button Decrements The Player Ui]
        DebugButtons.DecrementButton.InteractedWithEvent.Subscribe(OnEliminatedButton)
        # Initialize the spawners (For Join in progress)
        InitSpawners() 
        # Add a Custom Player UI to all players in the game
        InitPlayers()
        # Initialize the Values from the external editables
        InitValues()

    #Function to update the UI of a player
    OnEliminated(ER:elimination_result):void=
        if(EliminatedPlayer := player[ER.EliminatedCharacter.GetAgent[]] , EliminatingPlayer := player[ER.EliminatingCharacter?.GetAgent[]]):
            if(EliminatedPlayer <> EliminatingPlayer):
                if(EliminatingCustomPlayer := Custom_Player_Map[EliminatingPlayer]):
                    UpdateKillProgress(EliminatingCustomPlayer,EliminatingPlayer)
                if(EliminatedCustomPlayer := Custom_Player_Map[EliminatedPlayer]):
                    UpdateDeathProgress(EliminatedCustomPlayer,EliminatedPlayer)
            else: 
                Print("Eliminated Player is the same as Eliminating Player")       
            spawn. ShowStatsWidget(EliminatedPlayer, EliminatingPlayer)

    ShowStatsWidget(EliminatedPlayer:player,EliminatingPlayer:player)<suspends>:void=
        if(CustomPlayer2 := Custom_Player_Map[EliminatedPlayer],EnmyCustomPlayer := Custom_Player_Map[EliminatingPlayer],EliminatingPlayer.IsActive[],CurrentPlayerStats := PlayerStatsManager.GetPlayerStats[EliminatingPlayer]):
                Canvas := CustomPlayer2.DeathStatWidget()
                if(Texture :=RankIconsArray[EnmyCustomPlayer.CurrentRank]):
                    CustomPlayer2.StatTextureBlock.SetImage(Texture)
                    if(PowerTexture := PowerIconsArray[CurrentPlayerStats.PowerStat.CurrentValue - 1]):
                        CustomPlayer2.PowerImageTexture.SetImage(PowerTexture)  
                    else:
                        CustomPlayer2.PowerImageTexture.SetImage(CustomAssets.Transparent)  
                        
                CustomPlayer2.PlayerNameRank.SetText(ATM(EliminatingPlayer))
                if(CurrentPlayerStats.Kills.CurrentValue > 0 and CurrentPlayerStats.Deaths.CurrentValue = 0):
                    CustomPlayer2.PlayerStats.SetText(S2M("    Kills: {CurrentPlayerStats.Kills.CurrentValue}\n    Deaths: {CurrentPlayerStats.Deaths.CurrentValue}\n    KD:{CurrentPlayerStats.Kills.CurrentValue}.00 \n    PLAYER POWER"))
                else:
                    CustomPlayer2.PlayerStats.SetText(S2M("    Kills: {CurrentPlayerStats.Kills.CurrentValue}\n    Deaths: {CurrentPlayerStats.Deaths.CurrentValue}\n    KD:{FloorFloat2Decimals(RoundFloat((CurrentPlayerStats.Kills.CurrentValue *1.0) / (CurrentPlayerStats.Deaths.CurrentValue*1.0),2))}\n    PLAYER POWER"))
            if(PlayerUI := GetPlayerUI[EliminatedPlayer]):
                PlayerUI.AddWidget(Canvas)
                Sleep(Display_Stats.StatWidgetDisplayTime)
                PlayerUI.RemoveWidget(Canvas)

    #Function for Debuging         
    OnEliminationButton(Agent:agent):void=
       if(Player := player[Agent]):  
        if(EliminatingCustomPlayer := Custom_Player_Map[Player]):
            UpdateKillProgress(EliminatingCustomPlayer,Player)
    
    OnEliminatedButton(Agent:agent):void=
       if(Player := player[Agent]):  
        if(EliminatedCustomPlayer := Custom_Player_Map[Player]):
            UpdateDeathProgress(EliminatedCustomPlayer,Player)

    # initialize the spawners and subscribe to the PlayerJoined event
    InitSpawners():void=
        for(Spawner:Spawners):
            Spawner.SpawnedEvent.Subscribe(OnPlayerJoined)
    
    UpdateKillProgress(CustomPlayers:Ranked_Player, Player:player):void=
       if: 
        CurrentPlayerStats := PlayerStatsManager.GetPlayerStats[Player]
        CurrentElo := CurrentPlayerStats.Elo.CurrentValue
        CurrentKills := CurrentPlayerStats.Kills.CurrentValue
        CurrentGoal := EloDenominators[CustomPlayers.CurrentRank]
        EloGain := GeneralSettings.EloGainPerKill
        var NewElo : int = CurrentElo + EloGain
       then:
            if (NewElo >= CurrentGoal):
                Print("Player Promoted")
                PlayerStatsManager.RecordPlayerStat(Player, DataType.Elo, ?Value := NewElo)
                PlayerStatsManager.RecordPlayerStat(Player, DataType.Kills, ?Value := CurrentKills + 1)
                set CustomPlayers.CurrentRank = DetermineRank(NewElo)
                set CustomPlayers.Elo = NewElo
                GeneralSettings.RankUpXp.Award(Player)
                GeneralSettings.PromotedSound.Play()
                InitUi(Player)
            else:
                PlayerStatsManager.RecordPlayerStat(Player, DataType.Elo, ?Value := NewElo)
                PlayerStatsManager.RecordPlayerStat(Player, DataType.Kills, ?Value := CurrentKills + 1)
                set CustomPlayers.Elo = NewElo
                if( CustomPlayers.CurrentRank = EloDenominators.Length -1):
                    UpdateMaxRank(CustomPlayers)
                else:     
                    UpdateProgressBar(CustomPlayers,CurrentGoal)
       else:
                #Print("Failed to Update Progress Bar")     
        

    UpdateDeathProgress(CustomPlayers:Ranked_Player,Player:player):void=
        if: 
         CurrentPlayerStats := PlayerStatsManager.GetPlayerStats[Player]
         CurrentElo := CurrentPlayerStats.Elo.CurrentValue
         CurrentDeaths := CurrentPlayerStats.Deaths.CurrentValue
         EloLoss := GeneralSettings.EloLossPerDeath
         var NewElo : int = CurrentElo - EloLoss
         var CurrentRank : int = CustomPlayers.CurrentRank -1
        then:
         # Prevent ELO from going negative
         if. NewElo < 0 then. set NewElo = 0
         if. CurrentRank < 0 then. set CurrentRank = 0
        #Print("Current Rank: {CurrentRank}")   
            if(PreviousGoal := EloDenominators[CurrentRank], CurrentGoal := EloDenominators[CurrentRank + 1]):
                if (NewElo < PreviousGoal):
                    Print("Player Demoted")
                    PlayerStatsManager.RecordPlayerStat(Player, DataType.Elo, ?Value := NewElo)
                    PlayerStatsManager.RecordPlayerStat(Player, DataType.Deaths, ?Value := CurrentDeaths + 1)
                    set CustomPlayers.CurrentRank = DetermineRank(NewElo)
                    set CustomPlayers.Elo = NewElo
                    GeneralSettings.DemotedSound.Play(Player)
                    InitUi(Player)
                else:
                    PlayerStatsManager.RecordPlayerStat(Player, DataType.Elo, ?Value := NewElo)
                    PlayerStatsManager.RecordPlayerStat(Player, DataType.Deaths, ?Value := CurrentDeaths + 1)
                    set CustomPlayers.Elo = NewElo
                    if( CustomPlayers.CurrentRank = EloDenominators.Length - 1):
                        UpdateMaxRank(CustomPlayers)
                    else:     
                       UpdateProgressBar(CustomPlayers,CurrentGoal)
        else: 
            Print("Failed to Update Progress Bar")

    UpdateProgressBar(CustomPlayers:Ranked_Player,EloDenominator:int):void=
        CustomPlayers.TopColorBlock.SetDesiredSize(vector2{X:=CaculateProgressBarWidthForRank(CustomPlayers.CurrentRank, 225.0, CustomPlayers.Elo,EloDenominator),Y:=10.0})
        CustomPlayers.Percentage.SetText(S2Ms(FormatEloFraction(CustomPlayers.Elo, EloDenominator)))
        # CustomPlayers.Percentage.SetText(S2Ms(ConvertToPercentage(CustomPlayers.Elo, EloDenominator,CustomPlayers.CurrentRank)))

    UpdateMaxRank(CustomPlayers:Ranked_Player):void=
        CustomPlayers.TopColorBlock.SetDesiredSize(vector2{X:=225.0,Y:=10.0})
        CustomPlayers.Percentage.SetText(S2Ms("ELO: {CustomPlayers.Elo}"))
      
    # Function to Initialize the UI of a Player
    InitUi(Player:player):void=
         Print("Init UI")
       if(CustomPlayers := Custom_Player_Map[Player]):
            if: 
                Texture := RankIconsArray[CustomPlayers.CurrentRank] 
                EloDenominator := EloDenominators[CustomPlayers.CurrentRank]
                RankNameText :string= RankNamesArray[CustomPlayers.CurrentRank]
            then:  
                CustomPlayers.RankTextureBlock.SetImage(Texture)
                if( CustomPlayers.CurrentRank = EloDenominators.Length -1):
                    UpdateMaxRank(CustomPlayers)
                else:     
                   UpdateProgressBar(CustomPlayers,EloDenominator)
                CustomPlayers.RankName.SetText(S2Ms(RankNameText))
                Print(RankNameText)
            else:
                Print("Failed to Initialize UI")

    # Function to Create a Custom_Player_UI and assign to a player
    OnPlayerJoined(Agent :agent):void=   
        # Cast Agent to Player 
        if(Player := player[Agent]):
            # Check if Player already has a Custom_Player_UI
            if(PlayerExists := Custom_Player_Map[Player]):
                #Player already has a Custom_Player_UI so do nothing
            else:
              # Initialize the Player Stats
              PlayerStatsManager.InitializePlayer(Player)  
              #Get the Current Player Stats
              if(CurrentPlayerStats := PlayerStatsManager.GetPlayerStats[Player]):       
                # Subscribe to the Eliminated Event
                if. FC := Player.GetFortCharacter[] then. FC.EliminatedEvent().Subscribe(OnEliminated) 
                #Create a new Custom_Player_UI for the Player
                CustomPlayers := Ranked_Player{Player := Player}
                # Assign the CustomPlayer to the Player
                option. set  Custom_Player_Map[Player] = CustomPlayers
                # Set the Elo Value of the CustomPlayer to the Elo Value stored in previous games
                set CustomPlayers.Elo = CurrentPlayerStats.Elo.CurrentValue
                # Get the Current Rank of the Player
                set CustomPlayers.CurrentRank = DetermineRank(CurrentPlayerStats.Elo.CurrentValue)
                # Add the UI to the Player
                CustomPlayers.AddUiToPlayer()
                # Update the UI of the Player
                InitUi(Player)

    #Clean up Data from leaving player to free up memory            
    OnPlayerLeft(PlayerLeaving : agent):void=
        var NewMap : [player]Ranked_Player = map{}
        if(Player := player[PlayerLeaving]):
        for(Key -> Value : Custom_Player_Map, Key <> PlayerLeaving):
            set NewMap = ConcatenateMaps(NewMap, map{Key => Value})
        set Custom_Player_Map = NewMap     
        Print("Player Removed")

    # Function to Create a Custom_Player_UI for all players in the game
    InitPlayers():void=
        # PlayerStatsManager.InitializeAllPlayers(GetPlayspace().GetPlayers())
        for(Player: GetPlayspace().GetPlayers()):
            OnPlayerJoined(Player)    

    # Initialize the Values from the external editables        
    InitValues():void=
        if(RankGoals := GeneralSettings.RankGoals?):
         set EloDenominators = array{RankGoals.Value1, RankGoals.Value2, RankGoals.Value3, RankGoals.Value4, RankGoals.Value5, RankGoals.Value6, RankGoals.Value7, RankGoals.Value8, RankGoals.Value9, RankGoals.Value10, RankGoals.Value11, RankGoals.Value12, RankGoals.Value13, RankGoals.Value14, RankGoals.Value15, RankGoals.Value16, RankGoals.Value17}
        else:
            Print("No rank goals to set using default values")

    # Helper Function to Determine Progress Bar Width
    CaculateProgressBarWidthForRank(EloRank:int, total_width:float, numerator:int, denominator:int):float=
        # Ensure the current rank is within the bounds of the array
        if (EloRank < 0 or EloRank >= EloDenominators.Length):
            return 0.0  # Return 0 width if the rank is invalid
        # Calculate the progress within the current rank
        previous_threshold  : int = if. Temp := EloDenominators[EloRank - 1] then.  Temp else.  0
        RealNumerator := (numerator - previous_threshold) * 1.0 
        RealDenominator := (denominator - previous_threshold)  * 1.0
        progress_within_rank :=  ( RealNumerator   / RealDenominator) 
        # Calculate the width of the progress bar
        width_image1 :=total_width *  progress_within_rank 
        # Print("Width: {width_image1}")
        # Print("{numerator} / {denominator}")
        return width_image1

    #Helper function to perform binary search
    DetermineRank(Elo:int):int=
        RankIndex :=BinarySearch(EloDenominators, Elo, 0, EloDenominators.Length - 1)
        if(RankIndex = EloDenominators.Length):
            return EloDenominators.Length - 1
        else: 
            return RankIndex
        
    BinarySearch(arr: []int, target: int, left: int, right: int):int=
        if (left > right) {
            return left
        }
        var Mid:int=0
        if(mid : int = Floor((left + right) / 2)):
            set Mid = mid
        if (target < arr[Mid]):
            return BinarySearch(arr, target, left, Mid - 1)
        else:
            return BinarySearch(arr, target, Mid + 1, right)  

    # Helper Function to Convert a Numerator and Denominator to a Percentage
    ConvertToPercentage(numerator: int, denominator: int,EloRank:int): string =
        previous_threshold  : int = if. Temp := EloDenominators[EloRank - 1] then.  Temp else.  0
        RealNumerator := (numerator - previous_threshold) * 1.0 
        RealDenominator := (denominator - previous_threshold)  * 1.0
        decimal_value := (RealNumerator * 1.0) / (RealDenominator * 1.0)
        percentage := decimal_value * 100.0
        return "{RemoveExtraNumbers(percentage)}%"

    FormatEloFraction(PlayerElo:int, RankEloDenominator:int):string =
        return "{PlayerElo}/{RankEloDenominator}"
     
    # Helper Function to Get the First Five Characters of a String
    RemoveExtraNumbers(input_float: float): string =
        input_string := "{input_float}"
        if(input_float < 10.0):
         return if. First5 := input_string.Slice[0, 3] then. First5 else. input_string
        else if(input_float < 100.0):
           return if. First5 := input_string.Slice[0, 5] then. First5 else. input_string
        else:   
           return if. First5 := input_string.Slice[0, 6] then. First5 else. input_string

    FloorFloat2Decimals(Value:float):string=
        floatString := ToString(Value)
        var stringToReturn:string=""
        for(Char:floatString):
            if(stringToReturn.Length < 4):
                set stringToReturn += "{Char}"
        return stringToReturn

    RoundFloat(Value:float, DecimalPlaces:int):float =
        Multiplier := Pow(10.0, DecimalPlaces * 1.0)
        var RoundedValues : float = 0.0
        if(RoundedValuess := Round[Value * Multiplier] * 1.0):
                set RoundedValues  = RoundedValuess
        return RoundedValues / Multiplier

       
      
################# CUSTOM PLAYER CLASS ####################
# This class is used to store the player's UI and data
Ranked_Player := class<unique>:       
  # The Agent that the Custom_Player is associated with
  Player : agent
  # string to message to be able to use in UI Widgets
  S2Ms<localizes>(value:string)<computes> : message = "{value}"
  # Player Data
  var Elo : int = 0
  var CurrentRank : int = 0
  # Dynamic UI Elements
  var StatTextureBlock : texture_block = texture_block{DefaultImage := RankIcons.Bronze_Rank_1, DefaultDesiredSize := vector2{X:= 45.0,Y:=40.0}}
  var PlayerNameRank : text_block = text_block{DefaultTextColor:=color{R:=1.0,G:=1.0,B:=1.0}, DefaultShadowOffset:= option. vector2{X:= 2.0,Y:= 2.0}, DefaultShadowColor:= color{R:= 0.0,G:= 0.0,B:= 0.0},DefaultShadowOpacity:=1.0}    
  var PlayerStats : text_block = text_block{DefaultTextColor:=color{R:=1.0,G:=1.0,B:=1.0}, DefaultShadowOffset:= option. vector2{X:= 2.0,Y:= 2.0}, DefaultShadowColor:= color{R:= 0.0,G:= 0.0,B:= 0.0},DefaultShadowOpacity:=1.0}   
  var Percentage : text_block = text_block{DefaultTextColor:=color{R:=1.0,G:=1.0,B:=1.0},DefaultTextSize := 26.0, DefaultTextOpacity := 0.95}
  var RankName : text_block = text_block{DefaultTextColor:=color{R:=1.0,G:=1.0,B:=1.0}, DefaultTextSize := 26.0, DefaultTextOpacity := 0.95}
  var RankTextureBlock : texture_block = texture_block{DefaultImage := RankIcons.unknown, DefaultDesiredSize := vector2{X:= 55.0,Y:=52.0}}
  var PowerImageTexture : texture_block = texture_block{DefaultImage := CustomAssets.Transparent, DefaultDesiredSize := vector2{X:= 100.0,Y:=400.0}}
  var TopColorBlock : color_block = color_block{DefaultColor := color{R := 1.0, G := 0.5, B := 0.1},DefaultDesiredSize := vector2{Y:=6.0}}
  var BottomColorBlock : color_block = color_block{DefaultColor := color{R:=0.0,G:=0.025645,B:=0.0625},DefaultDesiredSize := vector2{X:= 225.0,Y:=8.0} }

  # Adds the UI to the player
  AddUiToPlayer():void=
    if(PlayerUI := GetPlayerUI[player[Player]]):
        Canvas := CreateCanvas() 
        PlayerUI.AddWidget(Canvas)

  # Creates a canvas for a player to display the UI
  CreateCanvas():canvas=

    ProgressBar := overlay:
        Slots:=array:
            overlay_slot:
                Widget :=TopColorBlock
                HorizontalAlignment:=horizontal_alignment.Fill
                VerticalAlignment:=vertical_alignment.Center
            overlay_slot:
                Widget := color_block{DefaultColor := color{R:=1.0,G:=1.0,B:=1.0},DefaultDesiredSize := vector2{X:= 6.0, Y:= 10.0}, DefaultOpacity:=0.8}
                HorizontalAlignment:=horizontal_alignment.Right
                VerticalAlignment:=vertical_alignment.Center
               
    ProgressBarOverlay := overlay:
        Slots:=array:
            overlay_slot:
                Widget := texture_block{DefaultImage:= CustomAssets.Transparent, DefaultDesiredSize:= vector2{X:=220.0}}
                HorizontalAlignment:=horizontal_alignment.Fill
                VerticalAlignment:=vertical_alignment.Fill
            overlay_slot:
                Widget := BottomColorBlock
                HorizontalAlignment:=horizontal_alignment.Fill
                VerticalAlignment:=vertical_alignment.Center
                Padding := margin{Left := 10.0, Right := 10.0}
            overlay_slot:
                Widget := ProgressBar
                HorizontalAlignment:=horizontal_alignment.Left
                VerticalAlignment:=vertical_alignment.Fill
                Padding := margin{Left := 10.0, Right := 10.0}
            overlay_slot:
                Widget := Percentage
                HorizontalAlignment:=horizontal_alignment.Center
                VerticalAlignment:=vertical_alignment.Center

    RankStackBox:= stack_box:
        Orientation := orientation.Horizontal
        Slots:=array:
            stack_box_slot:
                Widget := RankTextureBlock
                HorizontalAlignment:=horizontal_alignment.Left
                VerticalAlignment:=vertical_alignment.Bottom
                Padding:= margin{Left := 15.0, Top := 45.0, Right := 4.0, Bottom := 0.0}
            stack_box_slot:
                Widget := RankName
                HorizontalAlignment:=horizontal_alignment.Left
                VerticalAlignment:=vertical_alignment.Center
                Padding:= margin{Left := 10.0, Right := 0.0, Top := 25.0} # Remove extra space if present

    RankOverlay := overlay:
        Slots:=array:
           overlay_slot:
                Widget := texture_block{DefaultImage := CustomAssets.Transparent}
                HorizontalAlignment:=horizontal_alignment.Fill 
                VerticalAlignment:=vertical_alignment.Fill
           overlay_slot:
                Widget := RankStackBox
                HorizontalAlignment:=horizontal_alignment.Fill 
                VerticalAlignment:=vertical_alignment.Fill    

    StackBox:= stack_box:
        Orientation := orientation.Vertical
        Slots:=array:
            stack_box_slot:
                Widget := RankOverlay
                HorizontalAlignment:=horizontal_alignment.Fill 
                VerticalAlignment:=vertical_alignment.Fill
            stack_box_slot:
                Widget := ProgressBarOverlay
                HorizontalAlignment:=horizontal_alignment.Left
                VerticalAlignment:=vertical_alignment.Bottom

    var Canvas : canvas = canvas:
        Slots := array:
            canvas_slot:
                Widget := StackBox
                Anchors := anchors{Minimum := vector2{X := 0.5, Y := 1.0}, Maximum := vector2{X := 0.5, Y := 1.0}}
                Alignment := vector2{X := 0.5, Y := 1.0}
                Offsets := margin{Top := -8.0}
                SizeToContent := true
    return Canvas    

  DeathStatWidget():canvas=
        ChildStackBox := stack_box:
            Orientation := orientation.Horizontal
            Slots:=array:
                stack_box_slot: 
                    Widget := StatTextureBlock
                    HorizontalAlignment:=horizontal_alignment.Center
                    VerticalAlignment:=vertical_alignment.Fill
                stack_box_slot: 
                    Widget := PlayerNameRank
                    HorizontalAlignment:=horizontal_alignment.Center
                    VerticalAlignment:=vertical_alignment.Center
                    Padding := margin{Left := 5.0}

        MainStackBox : stack_box = stack_box:
            Orientation := orientation.Vertical
            Slots:=array:
                stack_box_slot: 
                    Widget := text_block{DefaultText := S2M("ELIMINATED BY"),DefaultTextColor:=color{R:=1.0,G:=0.0,B:=0.0}, DefaultShadowColor := NamedColors.White, DefaultShadowOffset := option{vector2{X := 2.0, Y := 2.0}}, DefaultShadowOpacity:=1.0}
                    HorizontalAlignment:=horizontal_alignment.Center
                    VerticalAlignment:=vertical_alignment.Fill
                stack_box_slot:
                    Widget := ChildStackBox
                    HorizontalAlignment:=horizontal_alignment.Left
                    VerticalAlignment:=vertical_alignment.Bottom
                    Padding := margin{Top := 10.0, Bottom := 10.0}
                stack_box_slot:
                    Widget := PlayerStats
                    HorizontalAlignment:=horizontal_alignment.Center
                    VerticalAlignment:=vertical_alignment.Center
                stack_box_slot:
                    Widget := PowerImageTexture
                    HorizontalAlignment:=horizontal_alignment.Fill
                    VerticalAlignment:=vertical_alignment.Fill
                    Padding := margin{Top := 10.0}

        var Canvas : canvas = canvas:
            Slots:=array:
                canvas_slot: 
                    Widget := MainStackBox
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X:= 0.5, Y := 0.5}}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := true  
                    
RankNamesArray :[]string = array:
    "UNKNOWN"
    "BRONZE l"
    "BRONZE ll"
    "BRONZE lll"
    "SILVER l"
    "SILVER ll"
    "SILVER lll"
    "GOLD l"
    "GOLD ll"
    "GOLD lll"
    "PLATINUM l"
    "PLATINUM ll"
    "PLATINUM lll"
    "DIAMOND l"
    "DIAMOND ll"
    "DIAMOND lll"
    "ELITE"
    "CHAMPION"
    "UNREAL"

                
RankIconsArray : []texture = array:
    RankIcons.unknown
    RankIcons.Bronze_Rank_1
    RankIcons.Bronze_Rank_2
    RankIcons.Bronze_Rank_3
    RankIcons.Silver_Rank_1
    RankIcons.Silver_Rank_2
    RankIcons.Silver_Rank_3
    RankIcons.Gold_Rank_1
    RankIcons.Gold_Rank_2
    RankIcons.Gold_Rank_3
    RankIcons.Platinum_Rank_1
    RankIcons.Platinum_Rank_2
    RankIcons.Platinum_Rank_3
    RankIcons.Diamond_Rank_1
    RankIcons.Diamond_Rank_2
    RankIcons.Diamond_Rank_3
    RankIcons.Elite_Rank
    RankIcons.Champion_Rank
    RankIcons.Unreal_Rank

PowerIconsArray : []texture = array:
    PowerIcons.RizzlerMemeIcons
    PowerIcons.TunTunSahurIcon
    PowerIcons.TimCheeseIcon
    PowerIcons.LosTralaleritoesIcon
    PowerIcons.OrcaleroOrcalalaIcon
    PowerIcons.GokuIcon
    PowerIcons.GraipussMedussiIcon
    PowerIcons.DogeIcon
    PowerIcons.BonnecaAmbalubuIcon
    PowerIcons.LaVacaSaturnoIcon
    PowerIcons.MinionIcon
    PowerIcons.GangsterFooteraIcon
    PowerIcons.MordekaiIcon
    PowerIcons.BallerinaCappuccinoIcon
    PowerIcons.GegeNuggetIcon
    PowerIcons.AnonymousIcon
    PowerIcons.PipiPotatoeIcon
    PowerIcons.BallerinaCappuccinoIcon
    PowerIcons.LiriliLarilaIcon
    PowerIcons.MassiveIcon
    PowerIcons.OdinOdinIcon
    PowerIcons.SonicIcon
    PowerIcons.GaramaMadundungIcon
    PowerIcons.BrrBrrPatapimIcon
    PowerIcons.ChadPepeIcon
    PowerIcons.FluriFluraIcon
    PowerIcons.AmongUsIcon
    PowerIcons.MangoIcon
    PowerIcons.SiviniaBombondinoIcon
    PowerIcons.SpideyIcon
    PowerIcons.PowerImageTest
    PowerIcons.SkibidiIcon
    PowerIcons.FishiniBossiniIcon
    PowerIcons.GorillioWatermellodrilloIcon
    PowerIcons.BrainrotGodIcon
    PowerIcons.BombadinoCrocadiloIcon
    PowerIcons.EnglishOrSpanishIcon
    PowerIcons.PowerImageTest
    PowerIcons.ChimpanziniBananiniIcon
    PowerIcons.FreddyIcon
    PowerIcons.BagHeadIcon
    PowerIcons.DawgIcon
    PowerIcons.JobIcon
    PowerIcons.PowerImageTest
    PowerIcons.RatDanceIcon
    PowerIcons.SalsaIcon
    PowerIcons.WinterArcIcon
    PowerIcons.PowerImageTest
    PowerIcons.MustardIcon
    PowerIcons.SixSevenIcon
    PowerIcons.PowerImageTest
    PowerIcons.PowerImageTest
    PowerIcons.PowerImageTest
    PowerIcons.TralaleroTralalaIcon


MaterialsRank : []material =array:
    RankIcons.unknown_Mat
    RankIcons.Bronze_Rank_1_Mat
    RankIcons.Bronze_Rank_2_Mat
    RankIcons.Bronze_Rank_3_Mat
    RankIcons.Silver_Rank_1_Mat
    RankIcons.Silver_Rank_2_Mat
    RankIcons.Silver_Rank_3_Mat
    RankIcons.Gold_Rank_1_Mat
    RankIcons.Gold_Rank_2_Mat
    RankIcons.Gold_Rank_3_Mat
    RankIcons.Platinum_Rank_1_Mat
    RankIcons.Platinum_Rank_2_Mat
    RankIcons.Platinum_Rank_3_Mat
    RankIcons.Diamond_Rank_1_Mat
    RankIcons.Diamond_Rank_2_Mat
    RankIcons.Diamond_Rank_3_Mat
    RankIcons.Elite_Rank_Mat
    RankIcons.Champion_Rank_Mat
    RankIcons.Unreal_Rank_Mat
#-----------------------------------------