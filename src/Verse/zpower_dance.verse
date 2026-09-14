using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Assets }
using { /Verse.org/Random }
using { /Verse.org/Colors/NamedColors }
using { /Fortnite.com/Characters }
using { /Verse.org/Colors }
using { /Fortnite.com/Game }
using { /Fortnite.com/FortPlayerUtilities }

# ──────────────────────────────────────────────────────────────────────────────
dance_support_power := class<concrete>(power_base):

    @editable HealAmount        : float = 2.5
    @editable HealTickDelay     : float = 0.5

    var StoredDamage            : float = 0.0
    @editable MaxDamage         : float = 50.0
    @editable ChargeAmount      : float = 2.5
    @editable ChargeTickDelay   : float = 0.5
    @editable DecayTickDelay    : float = 0.5
    @editable DecayAmount       : float = 2.5

    @editable DancerZone        : mutator_zone_device = mutator_zone_device{}
    @editable AudioPlayer       : audio_player_device   = audio_player_device{}

    var HealingDone             : float = 0.0
    @editable UIText            : string = "Extra Damage: "
    @editable UIHealText        : string = "\nHealing Done: "

    StopEvent<private> : event() = event(){}
    var MaybeTimerUI   : ?Timer = false

    Init<public>(InAgent:agent, TimerUI:Timer):void=
        set StoredDamage = 0.0
        set HealingDone  = 0.0
        set MaybeTimerUI = option{TimerUI}
        TimerUI.ShowTimer()
        UpdateUI()
        if(Fort := InAgent.GetFortCharacter[]):
            spawn{ActivatePowerup(InAgent, Fort)}

    UpdateUI<private>():void=
        if(Dmg := Round[StoredDamage],
           Heal := Round[HealingDone],
           TimerUI := MaybeTimerUI?):
            TimerUI.Update(UIText + "{Dmg}" + UIHealText + "{Heal}")

    Delete<public>():void=
        StopEvent.Signal()
        AudioPlayer.Stop()
        Print("Dance Support Power deleted")

    ActivatePowerup<private>(Agent:agent, Fort:fort_character)<suspends>:void=
        Print("Dance Support Power started")
        var IsDancing : logic = false

        race:
            # (1) Global cancel
            StopEvent.Await()

            # (2) Passive decay while NOT dancing
            loop:
                Sleep(DecayTickDelay)
                if(not IsDancing?):
                    if((StoredDamage - DecayAmount) >= 0.0):
                        set StoredDamage -= DecayAmount
                        UpdateUI()

            # (3) Handle start/stop dancing and per-tick effects
            loop:
                BeginsAgent := DancerZone.AgentBeginsEmotingEvent.Await()
                if(BeginsAgent = Agent):
                    set IsDancing = true
                    AudioPlayer.Play(Agent)

                    # While dancing, run three things in parallel:
                    race:
                        # 3a – wait for dance to end
                        loop:
                            Sleep(0.1)
                            EndsAgent := DancerZone.AgentEndsEmotingEvent.Await()
                            if(EndsAgent = Agent):
                                set IsDancing = false
                                AudioPlayer.Stop()
                                break

                        # 3b – healing ticks
                        loop:
                            Sleep(HealTickDelay)
                            Fort.SetHealth (Fort.GetHealth  () + HealAmount)
                            Fort.SetShield (Fort.GetShield  () + HealAmount)
                            set HealingDone += HealAmount * 2.0
                            UpdateUI()

                        # 3c – damage-charge ticks
                        loop:
                            Sleep(ChargeTickDelay)
                            if(StoredDamage < MaxDamage):
                                set StoredDamage += ChargeAmount
                                UpdateUI()
        Print("Coroutine exited")

    DamagedEvent<public>(FortDidDamage:fort_character, DamagedFort:fort_character):void=
        if(StoredDamage > 0.0):
            DamagedFort.Damage(damage_args{Amount := StoredDamage, Instigator := option{FortDidDamage}, Source := option {custom_game_action_causer{} }})
            set StoredDamage = 0.0
            UpdateUI()
