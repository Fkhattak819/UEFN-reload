using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /Verse.org/Colors }
using { /Verse.org/Assets }
 

# Timer class with seconds and tenths, color logic integrated
Timer := class:
    var TimeText : text_block = text_block{
        DefaultTextColor := NamedColors.White,
        DefaultShadowColor := NamedColors.Black,
        DefaultShadowOffset := option{vector2{X := 2.75, Y := 2.75}},
        DefaultShadowOpacity := 0.65
    }
    
    var TimerCanvas : canvas = canvas{}
    var PlayerUI : ?player_ui = false

    var RemainingTime<internal> : float = 0.0
    var IsActive<public> : logic = false

    # For active/superpower countdown mode: tenths-based fields
    var TimeInSeconds<internal> : float = 0.0
    var TimeInMiliseconds<internal> : float = 0.0 # always tenths (0..9)
    TickPeriod<internal> : float = 0.1 # for tenths update logic

    # Widget controls
    InitUI<public>(InPlayerUI : player_ui) : void =
        set PlayerUI = option{InPlayerUI}
        set TimerCanvas = canvas{
            Slots := array{
                canvas_slot{
                    Anchors := anchors:
                        Minimum := vector2{X := 0.5, Y := 1.0}
                        Maximum := vector2{X := 0.5, Y := 1.0}
                    Alignment := vector2{X := 0.0, Y := 0.0 }
                    Offsets := margin{Top := -170.0, Left := -115.0, Bottom := 0.0, Right := 0.0}
                    SizeToContent := true
                    Widget := TimeText 
                }
            }
        }
        InPlayerUI.AddWidget(TimerCanvas)
        SetReadyText()

    HideTimer<public>() : void =
        TimeText.SetVisibility(widget_visibility.Hidden)

    ShowTimer<public>() : void =
        SetReadyText()
        TimeText.SetVisibility(widget_visibility.Visible)

    ReInit<public>() : void =
        if (UI := PlayerUI?):
            UI.RemoveWidget(TimerCanvas)
            set TimerCanvas = canvas{
                Slots := array{
                    canvas_slot{
                        Anchors := anchors:
                            Minimum := vector2{X := 0.5, Y := 1.0}
                            Maximum := vector2{X := 0.5, Y := 1.0}
                        Alignment := vector2{X := 0.0, Y := 0.0 }
                        Offsets := margin{Top := -150.0, Left := -115.0, Bottom := 0.0, Right := 0.0}
                        SizeToContent := true
                        Widget := TimeText 
                    }
                }
            }
            UI.AddWidget(TimerCanvas)
            SetReadyText()

    SetReadyText<private>() : void =
        TimeText.SetText(S2M("POWER READY"))
        TimeText.SetTextColor(NamedColors.White)

    # --- Standard countdown with "AVAILABLE IN : S.T", text turns red when started ---
    StartCountdown<public>(Seconds : float) : void =
        set IsActive = false
        TimeText.SetTextColor(NamedColors.Red)
        set RemainingTime = Seconds
        set IsActive = true
        spawn{ RunCountdown() }

    Stop<public>() : void =
        set IsActive = false
        set TimeInSeconds = 0.0
        set TimeInMiliseconds = 0.0
        
    RunCountdown<private>()<suspends> : void =
        loop:
            if (IsActive = false):
                break
            if (RemainingTime <= 0.0):
                SetReadyText()
                set IsActive = false
                break
            UpdateCountdownDisplay()
            Sleep(0.1)
            set RemainingTime -= 0.1

    UpdateCountdownDisplay<private>() : void =
        if (TotalSeconds := Int[RemainingTime]):
            if (TenthsRaw := Int[RemainingTime * 10.0]):
                if (Tenths := Mod[TenthsRaw, 10]):
                    TimeText.SetText(S2M("COOLDOWN : {TotalSeconds}.{Tenths}"))

    # --- Superpower/active countdown with "RESPAWNING IN S.T", text turns red when started ---
    NewStartActiveCountdown(Seconds : float)<suspends>:void=
        TimeText.SetTextColor(NamedColors.Red)
        set TimeInSeconds = Seconds
        set TimeInMiliseconds = 0.0
        UpdateActiveUI()
        RunActiveCountdown()

    RunActiveCountdown<private>()<suspends> : void =
        loop:
            Sleep(TickPeriod)
            UpdateActiveUI()
            if (TimeInSeconds <= 0.0 and IsActive?):
                TimeText.SetTextColor(NamedColors.White)
                SetReadyText()
                set IsActive = false
                break
 
    UpdateActiveUI<private>() : void =
        if(SSeconds := Int[TimeInSeconds], MMilliseconds := Int[TimeInMiliseconds]):
            Time : string = "RESPAWNING IN {SSeconds}.{MMilliseconds}"
            TimeText.SetText(S2M(Time))
            if(TimeInMiliseconds >= 1.0):
                set TimeInMiliseconds -= 1.0
            else:
                if(TimeInSeconds > 0.0):
                    set TimeInSeconds -= 1.0
                    set TimeInMiliseconds = 9.0

    # Utility functions
    Update<public>(S:string):void = TimeText.SetText(S2M(S))
    ResetText():void= SetReadyText()