using { /Fortnite.com/UI }
using { /Fortnite.com/Devices }
using { /Verse.org/Colors }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/Diagnostics }


TT_Stats<localizes> : message = "Stats will appear on the table, in the order they're defined."
TT_StatIndexOrdering<localizes> : message = "Determines which one of the stats will be used for ordering on the stat table."

StringToMessage<localizes>(String : string) : message = "{String}"
PlayerToMessage<localizes>(Player : player) : message = "{Player}"

stat_data := class<concrete>:
    @editable
    StatName : string = ""

    @editable
    ColumnWidth : float = 0.0

    @editable
    DigitsToDisplayAfterTheDecimal : int = 0

    @editable
    HeaderTextColor : color = NamedColors.White
    @editable
    ValueTextColor : color = NamedColors.White

stat_table_device := class(creative_device):

    @editable{ ToolTip := TT_Stats }
    Stats : []stat_data = array{}

    @editable{ ToolTip := TT_StatIndexOrdering }
    StatIndexForOrdering : int = 0

    @editable
    GoldChecker : conditional_button_device = conditional_button_device{}

    @editable
    StatTableAnchor : vector2 = vector2{ X := 1.0, Y := 0.0 }
    @editable
    StatTableAlignment : vector2 = vector2{ X := 1.0, Y := 0.0 }
    @editable
    StatTableOffsets : vector2 = vector2{ X := -32.0, Y := 128.0 }

    @editable
    FontSize : float = 22.0

    @editable
    ValueRowCount : int = 5

    @editable
    HeaderRowHeight : float = 40.0
    @editable
    ValueRowHeight : float = 40.0

    @editable
    OrderColumnWidth : float = 20.0
    @editable
    PlayerNameColumnWidth : float = 60.0

    @editable
    BGColor : color = NamedColors.Black
    @editable
    BGOpacity : type {_X:float where 0.000000 <= _X, _X <= 1.000000} = 0.35

    @editable
    LineThickness : float = 4.0
    @editable
    LineColor : color = NamedColors.White

    @editable
    OrderColumnValueTextColor : color = NamedColors.White

    @editable
    PlayerNameColumnHeaderTextColor : color = NamedColors.White
    @editable
    PlayerNameColumnValueTextColor : color = NamedColors.White

    var ValueTextsSlotStartIndex : int = 0
    var StatCount : int = 0

    OnBegin<override>()<suspends>:void=
        Print("OnBegin")
        set StatCount = Stats.Length

    UpdateStatTableCanvas(AgentMap : [agent]agent_data):void=
        Print("UpdateStatTableCanvas")

        StatNameToOrder := if (String := Stats[StatIndexForOrdering].StatName)
        then String
        else ""

        Players := GetPlayspace().GetPlayers()
        var PlayerStatValues : []float = for (Index -> Player : Players, Agent := agent[Player], AgentData := AgentMap[Player],
        StatValue := AgentData.StatValues[StatNameToOrder]):
            StatValue

        var OrderedPlayerIndexes : []int = array{}
        for (I := 1 .. ValueRowCount):
            MaxIndex := FindMaxIndex(PlayerStatValues)

            if (MaxValue := PlayerStatValues[MaxIndex], MaxValue >= 0.0):
                set OrderedPlayerIndexes += array{ MaxIndex }

            if (set PlayerStatValues[MaxIndex] = -1.0){}

        for (Player : Players, Agent := agent[Player], AgentData := AgentMap[Player], StatTableCanvas := AgentData.MaybeStatTableCanvas?,
        StatTableInnerCanvas := canvas[StatTableCanvas.Slots[0].Widget]):

            var CurrentSlotIndex : int = ValueTextsSlotStartIndex
            ColumnCount := StatCount + 2

            for (I := 0 .. ValueRowCount-1):

                #Fill the messages to display for this row.
                var Messages : []message = array{}
                if (OrderedPlayerIndex := OrderedPlayerIndexes[I], OrderedPlayer := Players[OrderedPlayerIndex],
                OrderedAgentData := AgentMap[OrderedPlayer]):
                    set Messages += array{ StringToMessage("#{I+1}"), PlayerToMessage(OrderedPlayer) }
                    set Messages += for (Stat : Stats, StatValue := OrderedAgentData.StatValues[Stat.StatName]):
                        StringToMessage("{AbbreviateNumberText(StatValue, Stat.DigitsToDisplayAfterTheDecimal)}")

                for (ColumnIndex := 0 .. ColumnCount-1, TextBlock := text_block[StatTableInnerCanvas.Slots[CurrentSlotIndex].Widget]):
                    MessageToSet := if (Msg := Messages[ColumnIndex])
                    then Msg
                    else StringToMessage("")

                    TextBlock.SetText(MessageToSet)
                    set CurrentSlotIndex += 1

    CreateStatTableCanvas():canvas=
        return canvas:
            Slots := array:
                canvas_slot:
                    Anchors := anchors{ Minimum := StatTableAnchor, Maximum := StatTableAnchor }
                    Offsets := margin{ Top := StatTableOffsets.Y, Left := StatTableOffsets.X, Right := 0.0, Bottom := 0.0 }
                    Alignment := StatTableAlignment
                    SizeToContent := true
                    ZOrder := 0
                    Widget := CreateStatTableCanvasInner()

    CreateStatTableCanvasInner():canvas=
        BGHeight := HeaderRowHeight + ValueRowCount*ValueRowHeight

        var BGWidth : float = OrderColumnWidth + PlayerNameColumnWidth
        for (Stat : Stats):
            set BGWidth += Stat.ColumnWidth

        var CanvasSlots : []canvas_slot = array
        {
            CanvasSlot0 := canvas_slot:
                Anchors := anchors{ Minimum := vector2{X := 0.0, Y := 0.0}, Maximum := vector2{X := 0.0, Y := 0.0} }
                Offsets := margin{ Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                Alignment := vector2{X := 0.0, Y := 0.0}
                ZOrder := 0
                Widget := color_block{ DefaultColor := BGColor, DefaultOpacity := BGOpacity,
                DefaultDesiredSize := vector2{X := BGWidth, Y := BGHeight} }
        }

        # Horizontal Line.
        HorizontalLineLength := BGWidth
        set CanvasSlots += array
        {
            CanvasSlot1 := canvas_slot:
                Anchors := anchors{ Minimum := vector2{X := 0.0, Y := 0.0}, Maximum := vector2{X := 0.0, Y := 0.0} }
                Offsets := margin{ Top := HeaderRowHeight, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                Alignment := vector2{X := 0.0, Y := 0.0}
                ZOrder := 1
                Widget := color_block{ DefaultColor := LineColor, DefaultDesiredSize := vector2{X := HorizontalLineLength, Y := LineThickness} }
        }

        #Vertical Lines.
        var TotalLeftOffset : float = 0.0
        var ColumnWidths : []float = array{ OrderColumnWidth, PlayerNameColumnWidth }
        
        set ColumnWidths += for (Stat : Stats):
            Stat.ColumnWidth

        LineHeight := BGHeight
        for (I := 0 .. StatCount, ColumnWidth := ColumnWidths[I]):
            set TotalLeftOffset += ColumnWidth
            Print("Vertical Line {I}, Offset: {TotalLeftOffset}, Width: {ColumnWidth}")

            set CanvasSlots += array
            {
                CanvasSlot2 := canvas_slot:
                    Anchors := anchors{ Minimum := vector2{X := 0.0, Y := 0.0}, Maximum := vector2{X := 0.0, Y := 0.0} }
                    Offsets := margin{ Top := 0.0, Left := TotalLeftOffset, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{X := 0.5, Y := 0.0}
                    ZOrder := 1
                    Widget := color_block{ DefaultColor := LineColor, DefaultDesiredSize := vector2{X := LineThickness, Y := LineHeight} }
            }

        # Header Texts.
        set TotalLeftOffset = OrderColumnWidth
        var HeaderStrings : []string = array{ "Player Name" }
        var HeaderStringColors : []color = array{ PlayerNameColumnHeaderTextColor }

        set HeaderStrings += for (Stat : Stats):
            Stat.StatName

        set HeaderStringColors += for (Stat : Stats):
            Stat.HeaderTextColor            

        for (I := 0 .. StatCount, HeaderString := HeaderStrings[I], HeaderStringColor := HeaderStringColors[I],
        ColumnWidth := ColumnWidths[I+1]):
            LeftOffset := TotalLeftOffset + ColumnWidth*0.5
            Print("Header String {I}: {HeaderString}, Offset: {LeftOffset}, Width: {ColumnWidth}")

            set CanvasSlots += array
            {
                CanvasSlot3 := canvas_slot:
                    Anchors := anchors{ Minimum := vector2{X := 0.0, Y := 0.0}, Maximum := vector2{X := 0.0, Y := 0.0} }
                    Offsets := margin{ Top := HeaderRowHeight*0.5, Left := LeftOffset, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    ZOrder := 1
                    Widget := text_block{ DefaultText := StringToMessage(HeaderString), DefaultTextColor := HeaderStringColor, DefaultTextSize := FontSize}
                    
            }

            set TotalLeftOffset += ColumnWidth

        set ValueTextsSlotStartIndex = CanvasSlots.Length

        # Value TextBlocks.
        var ValueStringColors : []color = array{ OrderColumnValueTextColor, PlayerNameColumnValueTextColor }
        set ValueStringColors += for (Stat : Stats):
            Stat.ValueTextColor

        for (I := 0 .. ValueRowCount-1):
            VerticalOffset := HeaderRowHeight + (ValueRowHeight*I) + ValueRowHeight*0.5
            set TotalLeftOffset = 0.0
            for (Index -> ColumnWidth : ColumnWidths, ValueStringColor := ValueStringColors[Index]):
                LeftOffset := TotalLeftOffset + ColumnWidth*0.5

                set CanvasSlots += array
                {
                    CanvasSlot4 := canvas_slot:
                        Anchors := anchors{ Minimum := vector2{X := 0.0, Y := 0.0}, Maximum := vector2{X := 0.0, Y := 0.0} }
                        Offsets := margin{ Top := VerticalOffset, Left := LeftOffset, Right := 0.0, Bottom := 0.0 }
                        Alignment := vector2{X := 0.5, Y := 0.5}
                        ZOrder := 1
                        Widget := text_block{ DefaultText := StringToMessage(""), DefaultTextColor := ValueStringColor, DefaultTextSize := FontSize }
                }

                set TotalLeftOffset += ColumnWidth

        return canvas:
            Slots := CanvasSlots

FloatToString(Num : float, DigitsAfterTheDecimal : int)<transacts>:string=
    var String : string = "NaN"

    if (NumInt := Int[Num]):
        set String = "{NumInt}"

        if (DigitsAfterTheDecimal > 0):
            set String += "."

            for (I := 1 .. DigitsAfterTheDecimal):
                Pow10 := Pow(10.0, I*1.0)

                NumIntPow10 := NumInt*Pow10
                NumPow10 := Num*Pow10

                if (NumIntPow10Int := Int[NumIntPow10], NumPow10Int := Int[NumPow10],
                Diff := NumPow10Int - NumIntPow10Int, Digit := Mod[Diff, 10]):
                    set String += "{Digit}"

    return String

AbbreviateNumberText<public>(Number : float, DigitsAfterDecimalPoint : int):string=
    var ResultText : string = ToString(Number)

    Abbreviations : []tuple(float,string) = array
    {
        (1000.0, "K"),
        (1000000.0, "M"),
        (1000000000.0, "B"),
        (1000000000000.0, "T"),
        (1000000000000000.0, "Qa"),
        (1000000000000000000.0, "Qi")
    }

    AbbreviationCount : int = Abbreviations.Length-1
    var CurrBackIndex : int = AbbreviationCount
    for(i:=0..AbbreviationCount):
        #Print("Check tuple for loop")
        if(CurrTuple := Abbreviations[CurrBackIndex]):
            #Print("Curr Tuple Found")
            if(Abs(Number) >= CurrTuple(0)):
                #Print("Bigger Than: {CurrTuple(0)}")
                RoundedNumber : float = Number / CurrTuple(0)
                #Print("Rounded Number Is: {RoundedNumber}")
                set ResultText = FloatToString(RoundedNumber, DigitsAfterDecimalPoint) + CurrTuple(1)
                return ResultText
        set CurrBackIndex -= 1

    if(CeiledValue := Ceil[Number]):
        set ResultText = ToString(CeiledValue)

    return ResultText

FindMaxIndex<public>(Arr : []float):int=
    var MaxIndex : int = -1

    if (FirstValue := Arr[0]):
        var MaxValue : float = FirstValue
        set MaxIndex = 0

        var I : int = 1
        loop:
            if (Value := Arr[I]):
                if (MaxValue < Value):
                    set MaxValue = Value
                    set MaxIndex = I
            else:
                break

            set I += 1

    return MaxIndex