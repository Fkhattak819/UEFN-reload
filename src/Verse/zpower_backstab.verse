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

backstab_power := class<concrete>(power_base):

    @editable BackStabDegrees : float = 50.0
    @editable ExtraDamagePercentage : float = 0.5 # 0.5 -> 50%
    @editable ExtraHealingPercentage : float = 0.5 
    @editable AudioPlayer : audio_player_device = audio_player_device{}

    @editable UITextExtra : string = "Damage Extra: "
    @editable UITextBlocked : string = "Damage Blocked: "
    var DamageExtra : float = 0.0
    var DamageBlocked : float = 0.0
    var MaybeTimerUI : ?Timer = false

    Init<public>(Agent : agent, TimerUI:Timer):void=
        set DamageExtra = 0.0
        set DamageBlocked = 0.0
        set MaybeTimerUI = option{TimerUI}       
        TimerUI.ShowTimer()
        UpdateUI()

    UpdateUI<private>():void=
        if(RoundedExtra := Round[DamageExtra],RoundedBlocked := Round[DamageBlocked], TimerUI := MaybeTimerUI?):
            TimerUI.Update(UITextExtra + "{RoundedExtra}\n" + UITextBlocked + "{RoundedBlocked}") 

    # IncomingFort is the one who was damaged or did damage to our backstab player
    # Amount is the amount of damage that occured
    # Logic true = backstab did damage, Logic false = backstab did damage
    # Need to reduce damage if backstab player took damage (healing)
    # Need to deal more damage if backstab player did damage
    
    BackstabEvent<public>(ThisFort : fort_character, EnemyFort : fort_character, Amount : float, Logic : logic)<suspends>:void=
        Sleep(0.0)
        if(Amount <= 200.0):
            IncomingFortRot := EnemyFort.GetTransform().Rotation
            FortRot := ThisFort.GetTransform().Rotation
            Value := RadiansToDegrees(AngularDistance(IncomingFortRot,FortRot))
            Print("Incoming player rotation:{IncomingFortRot}")
            Print("This player rotation:{FortRot}")
            if(Value <= BackStabDegrees):
                Print("Counted as a backstab")
                if(Logic = true, source := game_action_causer[ThisFort]):
                    Print("Backstab player is the damager")
                    BackstabAmount := Amount * ExtraDamagePercentage
                    Damage : damage_args = damage_args{Amount := BackstabAmount, Instigator := option {ThisFort}, Source := option {custom_game_action_causer{} }}
                    Print("Backstab player did {BackstabAmount} extra damage")
                    EnemyFort.Damage(Damage)
                    set DamageExtra += BackstabAmount
                else:
                    Print("Backstab player got damaged")
                    BackstabAmount := Amount * ExtraHealingPercentage
                    AddHPOrShield(ThisFort, Amount * ExtraHealingPercentage)
                    set DamageBlocked += BackstabAmount
                    if(ThisAgent := ThisFort.GetAgent[]):
                        AudioPlayer.Play(ThisAgent)
                UpdateUI()
            else:
                Print("Did not count as a backstab:{Value} is not smaller or equal {BackStabDegrees}")