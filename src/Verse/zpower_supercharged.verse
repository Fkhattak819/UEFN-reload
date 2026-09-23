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

supercharged_power := class<concrete>(power_base):
    
    var ChargedDamage : float = 0.0
    @editable ChargeDamagePercentage : float = 1.0
    @editable AudioPlayer : audio_player_device = audio_player_device{}

    @editable UIText : string = "Charged Damage: "
    var MaybeTimerUI : ?Timer = false

    Init<public>(TimerUI:Timer):void=
        set ChargedDamage = 0.0
        set MaybeTimerUI = option{TimerUI}
        TimerUI.ShowTimer()
        UpdateUI()

    UpdateUI<private>():void=
        if(RoundedNumber := Round[ChargedDamage], TimerUI := MaybeTimerUI?):
            TimerUI.Update(UIText + "{RoundedNumber}") 

    # Using Powerup
    DidDamageEvent<public>(DidDamageFort:fort_character,TookDamageFort:fort_character,Amount:float)<suspends>:void=
        if(ChargedDamage > 0.0):
            Sleep(0.0)
            if(source := game_action_causer[DidDamageFort]):
                Damage : damage_args = damage_args{Amount := ChargedDamage, Source := option {custom_game_action_causer{} }, Instigator := option{DidDamageFort}}
                TookDamageFort.Damage(Damage)
                Print("Supercharged did {ChargedDamage} extra damage")
                set ChargedDamage = 0.0
                if(Agent := DidDamageFort.GetAgent[]):
                UpdateUI()

    # Charging 
    TookDamageEvent<public>(TookDamageFort:fort_character, Amount:float)<suspends>:void=
        if(Amount < 200.0):
            Sleep(0.0)
            set ChargedDamage += Amount * ChargeDamagePercentage
            if(Agent := TookDamageFort.GetAgent[]):
            UpdateUI()
            Print("Supercharged to {ChargedDamage}")

    ElimEvent<public>(KillerAgent : agent):void=
        AudioPlayer.Play(KillerAgent)