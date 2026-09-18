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

lifesteal_power := class<concrete>(power_base):
    
    @editable LifestealPercentage : float = 0.50
    @editable MinHealth : float = 50.0
    @editable MaxHealth : float = 150.0
    @editable MaxShield : float = 100.0
    @editable TickDelay : float = 1.0
    @editable HealthLostPerTick : float = 0.1
    @editable DefaultHealthShield : float = 100.0

    @editable UIText : string = "Healing Done: "
    var HealingDone : float = 0.0
    var MaybeTimerUI : ?Timer = false

    StopEvent<private>: event() = event(){}
    # StartEvent<private>: event() = event(){}

    # Start Powerup
    Init<public>(CP:CustomPlayer,TimerUI:Timer)<suspends>:void=

        set HealingDone = 0.0
        set MaybeTimerUI = option{TimerUI}
        TimerUI.ShowTimer()
        UpdateUI()

        Agent := CP.MyAgentObj
        if(Fort:=Agent.GetFortCharacter[]):
            # StartEvent.Await()
            spawn{ActivatePowerup(Fort)}

    UpdateUI<private>():void=
        if(RoundedNumber := Round[HealingDone], TimerUI := MaybeTimerUI?):
            TimerUI.Update(UIText + "{RoundedNumber}")
        
    # Stop Powerup
    Delete<public>():void=
        StopEvent.Signal()
        set HealingDone = 0.0
        Print("Vamp Deleted")

    # Powerup
    ActivatePowerup<private>(Fort:fort_character)<suspends>:void=
        Fort.SetMaxHealth(MaxHealth)
        Fort.SetMaxShield(MaxShield)
        race:
            StopEvent.Await()
            loop:
                Sleep(TickDelay)
                CurrentHealth := Fort.GetHealth()
                if(CurrentHealth > MinHealth):
                    Fort.SetHealth(CurrentHealth - HealthLostPerTick)
        Fort.SetMaxHealth(DefaultHealthShield)
        Fort.SetMaxShield(DefaultHealthShield)

    # Using Powerup
    DamagedEvent<public>(ThisFort:fort_character,Amount:float):void=
        HealingAmount := Amount * LifestealPercentage
        set HealingDone += HealingAmount
        ThisFort.SetHealth(ThisFort.GetHealth() + HealingAmount)
        Print("Lifesteal event occured - Player Healing for {HealingAmount} which is {LifestealPercentage * 100.0}% of {Amount}")
        UpdateUI()