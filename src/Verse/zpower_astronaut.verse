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

astronaut_power := class<concrete>(power_base):

    @editable ExtraDamagePercentage : float = 0.5
    @editable AstronautClassSelector  : class_and_team_selector_device  = class_and_team_selector_device {}

    @editable UIText : string = "Extra Damage Dealt: "
    var DamageDealt : float = 0.0
    var MaybeTimerUI : ?Timer = false

    # Start Powerup
    Init<public>(InAgent:agent,TimerUI:Timer):void=
        AstronautClassSelector.Enable()
        AstronautClassSelector.ChangeClass(InAgent)
        AstronautClassSelector.Disable()

        set DamageDealt = 0.0
        set MaybeTimerUI = option{TimerUI}
        TimerUI.ShowTimer()
        UpdateUI()

    # No need for delete since we are reseting it already on Init
    # Need to hide and reset text on death for every power that will use this feature
    # Can be easly done in game manager
    Delete<public>():void=
        {}

    # Using Powerup
    DamagedEvent<public>(ThisFort:fort_character,EnemyFort:fort_character,Amount:float)<suspends>:void=
        Sleep(0.0)
        if(ThisFort.IsInAir[], source := game_action_causer[ThisFort]):
            DamageCalc : float = Amount * ExtraDamagePercentage
            Print("Astronaut event occured - Player dealt {Amount} damage, dealt {DamageCalc} extra damage")
            Damage : damage_args = damage_args{Amount := DamageCalc, Instigator := option{ThisFort}, Source := option {custom_game_action_causer{} } }
            EnemyFort.Damage(Damage)
            set DamageDealt += DamageCalc 
            UpdateUI()

    UpdateUI<private>():void=
        if(RoundedNumber := Round[DamageDealt], TimerUI := MaybeTimerUI?):
            TimerUI.Update(UIText + "{RoundedNumber}") 