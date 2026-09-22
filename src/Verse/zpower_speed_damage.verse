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

damage_to_speed_power := class<concrete>(power_base):
   
    var StoredLvl : int = 0
    var StoredDamage : float = 0.0
    
    @editable MovementMods : []movement_modulator_device = array{}
    @editable DefaultMod : movement_modulator_device = movement_modulator_device{}
    @editable AudioPlayer : audio_player_device = audio_player_device{}
    @editable AudioPlayer2 : audio_player_device = audio_player_device{}

    @editable UseTestValues : logic = false
    StopEvent<private>: event() = event(){}

    @editable UIText : string = "Speed Lvl: "
    var MaybeTimerUI : ?Timer = false

    var NewLevel<internal>: int = 0

    # Start Powerup
    Init<public>(TimerUI:Timer)<suspends>:void=
        set StoredDamage = 0.0
        set StoredLvl = 0
        set NewLevel = 0
        set MaybeTimerUI = option{TimerUI}
        TimerUI.ShowTimer()
        UpdateUI()

    UpdateUI<private>():void=
        if(TimerUI := MaybeTimerUI?):
            TimerUI.Update(UIText + "{StoredLvl}") 

    # Stop Powerup
    Delete<public>(Agent : agent):void=
        DefaultMod.Activate(Agent)
        StopEvent.Signal()
        
    # Using Powerup
    DamageEvent<public>(InAgent : fort_character, Amount : float)<suspends>:void=
        Sleep(0.0)
        set StoredDamage += Amount
        Print("StoredDamage {StoredDamage}")
        set NewLevel = StoredLvl
        Print("StoredLvl {StoredLvl + 1}")

        if(UseTestValues?):
            if(StoredDamage >= 0.0):
                if(StoredDamage >= 30.0):
                    set StoredLvl = 1
                if(StoredDamage >= 60.0):
                    set StoredLvl = 2
                if(StoredDamage >= 90.0):
                    set StoredLvl = 3
                if(StoredDamage >= 120.0):
                    set StoredLvl = 4
        else:
            if(StoredDamage >= 0.0):
                if(StoredDamage >= 75.0):
                    set StoredLvl = 1
                if(StoredDamage >= 200.0):
                    set StoredLvl = 2
                if(StoredDamage >= 350.0):
                    set StoredLvl = 3
                if(StoredDamage >= 450.0):
                    set StoredLvl = 4

        if (NewLevel <> StoredLvl, Agent := InAgent.GetAgent[]):
            AudioPlayer.Play(Agent)  # Replace with actual audio identifier
            if(Modulator := MovementMods[StoredLvl]):
                Print("Activated Speed Lvl {StoredLvl}")
                Modulator.Activate(Agent) 
        else:
            Print("Lvls Are the Same")
        UpdateUI()

    ElimEvent(Agent : agent):void=
        AudioPlayer2.Play(Agent)

