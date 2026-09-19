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

one_shot_power := class<concrete>(power_base):
    
    @editable
    OneShotItemGranter : item_granter_device = item_granter_device{}

    @editable
    OneShotConditional : conditional_button_device = conditional_button_device{}

    @editable
    OneShotSFX : audio_player_device = audio_player_device{}
    @editable
    OneShotVFX : visual_effect_powerup_device = visual_effect_powerup_device{}

    @editable
    ResetVFX : visual_effect_powerup_device = visual_effect_powerup_device{}

    StopEvent<private>: event() = event(){}

    RemovePlayerFromMap(Map:[agent]logic, ToRemove:agent):[agent]logic=
        var TempMap:[agent]logic = map{}
        for (Key -> Value : Map):
            if (Key <> ToRemove):
                set TempMap = ConcatenateMaps(TempMap, map{Key => Value})
        return TempMap

    # top-level variable to track if the agent already triggered VFX
    var HasVFX : [agent]logic = map{}

    OneShotTarget(Target : fort_character, FortDidDamage : fort_character)<suspends>:void=
        Sleep(0.0)
        Target.Damage(damage_args{Instigator := option{FortDidDamage}, Amount := 500.0, Source := option {custom_game_action_causer{} }})

    Delete(Agent : agent):void=
        StopEvent.Signal()
        set HasVFX = RemovePlayerFromMap(HasVFX, Agent)

    AttachVFX(Agent : agent)<suspends>:void=
        race:
            StopEvent.Await()
            loop:
                Sleep(0.1)
                if (OneShotConditional.IsHoldingItem[Agent]):
                    # only trigger if they just picked it up
                    if (not HasVFX[Agent]):
                        OneShotVFX.Pickup(Agent)
                        if. set HasVFX[Agent] = true
                else:
                    # reset the flag once they’re not holding anymore
                    if (HasVFX[Agent]):
                        ResetVFX.Pickup(Agent)
                        if. set HasVFX[Agent] = false

