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

invis_power := class<concrete>(power_base):

    @editable
    INVISPOWERConditional : conditional_button_device = conditional_button_device{}

    @editable
    INVISPOWERGranter : item_granter_device = item_granter_device{}

    @editable
    InvisClassSelector : class_and_team_selector_device = class_and_team_selector_device{}

    @editable 
    UpdateInvisDelay : float = 0.1

    @editable 
    MaxTime : float = 100.0

    @editable 
    UIText : string = "Time Invisible: "

    var Time : float = 0.0
    var MaybeTimerUI : ?Timer = false

    StopEvent<private>: event() = event(){}

    Init<public>(A:agent,TimerUI:Timer, DefaultClass : class_and_team_selector_device)<suspends>:void=

        InvisClassSelector.ChangeClass(A)

        set Time = 0.0
        TimerUI.ShowTimer()
        set MaybeTimerUI = option{TimerUI}
        UpdateUI()

        if(F:=A.GetFortCharacter[]):
            race:
                StopEvent.Await() # waiting for game to end or player eliminated
                loop:
                    Sleep(UpdateInvisDelay)
                    if(F.IsActive[]):
                        if(INVISPOWERConditional.IsHoldingItem[A] and Time <= MaxTime):
                            F.Hide()
                            set Time += UpdateInvisDelay
                            UpdateUI()
                        else:
                            F.Show() 

            # Making sure player is visible
            spawn. MakeSureShowing(F)
            
        DefaultClass.ChangeClass(A)

    MakeSureShowing(F : fort_character)<suspends>:void=
        F.Show() 
        Sleep(3.0)
        F.Show() 
        
    Delete<public>():void= 
        StopEvent.Signal()

    UpdateUI<private>():void=
        if(RoundedTime := Round[Time], TimerUI := MaybeTimerUI?, TotalTime := Int[MaxTime]):
            TimerUI.Update(UIText + "{RoundedTime}/{TotalTime}") 



