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

power_manager := class<concrete>():
    
    @editable PullPower : pull_power = pull_power{}

    @editable OneShotPower : one_shot_power = one_shot_power{}

    @editable TPBehindPower : tp_behind_power = tp_behind_power{}

    @editable FreezePower : freeze_power = freeze_power{}

    @editable FloodPower : flood_power = flood_power{}

    @editable AuraPower : aura_power = aura_power{}

    @editable InvisPower : invis_power = invis_power{}

    @editable TimeTravelPower : time_travel_power = time_travel_power{}

    @editable RewindPower : rewind_power = rewind_power{}

    @editable BullPower : bull_power = bull_power{}

    @editable BackstabPower : backstab_power = backstab_power{}

    @editable LifeStealPower : lifesteal_power = lifesteal_power{}

    @editable AstronautPower : astronaut_power = astronaut_power{}

    @editable KnockbackPower : knockback_power = knockback_power{}

    @editable CircleBombsPower : circle_bombs_power = circle_bombs_power{}

    @editable XrayPower : xray_power = xray_power{}

    @editable AgilityPower : agility_power = agility_power{}

    @editable DancePower : dance_support_power = dance_support_power{}

    @editable SuperchargedPower : supercharged_power = supercharged_power{}

    @editable SelfRevivePower : revive_power = revive_power{}

    @editable ImmunePower : immune_power = immune_power{}

    @editable MoreSpeedFromDamagePower : damage_to_speed_power = damage_to_speed_power{}

    @editable SnapPower : kill_everyone_power = kill_everyone_power{}

    # @editable OneShotPickaxePower : one_shot_pickaxe = one_shot_pickaxe{}

    @editable BushPower : bush_power = bush_power{}

    @editable AimbotPower : aimbot_power = aimbot_power{}

    @editable FlyPower : fly_power = fly_power{}

    # @editable MobilityPower : mobility_power = mobility_power{}

    @editable AntPower : ant_power = ant_power{}

    @editable ElectricPower : electric_power = electric_power{}

    @editable VolleyBombsPower : volley_bombs_power = volley_bombs_power{}

    # @editable PhoenixPower : phoenix_power = phoenix_power{}

    @editable SpideyPower : spidey_power = spidey_power{}

    # @editable BountyHunterPower : bounty_hunter_power = bounty_hunter_power{}

    @editable TurnIntoCharPower : turn_into_char_power = turn_into_char_power{}

    @editable ChairPullPower : chair_pull_power = chair_pull_power{}
    
    @editable LotsOfHealthPower : lots_of_health_power = lots_of_health_power{}

    @editable Teleport3PeoplePower : teleport_3_player_power = teleport_3_player_power{}

    @editable TurnIntoCharPower2 : turn_into_char_power = turn_into_char_power{}

    

    # ---------------------------------------------------------------------------------------
    <#
        Make two new animation files, animation_power_both, animation_power_target
        Make animation_power_base
    #>
    # TODO: IMPLEMENT THESE POWERUPS
    @editable MissilePower : missile_power = missile_power{} #Remote with no player tracking
    @editable EnglishOrSpanishPower : english_or_spanish_power = english_or_spanish_power{} #Remote with no player tracking
    @editable CreeperPower : creeper_power = creeper_power{} #Remote with no player tracking
    @editable TransformPower : transform_power = transform_power{} #On player damage
    @editable JumpscarePower : jumpscare_power = jumpscare_power{} #Remote with player tracking
    @editable BlindPower : perspective_power = perspective_power{} #On player damage
    @editable PhoneCallMulPower : shoot_prop_in_front_phone_call_mul_power = shoot_prop_in_front_phone_call_mul_power{} #On player damage
    @editable PropFollowPower : prop_follow_power = prop_follow_power{}
    @editable ForceDancePower : dance_power = dance_power{}
    # @editable ShootPropPower : shoot_prop_power = shoot_prop_power{}
    @editable SalsaAnimationPower : animation_power_target = animation_power_target{}
    @editable WinterArcAnimationPower : animation_power_both = animation_power_both{}
    # @editable SlapCompAnimationPower : animation_power_both = animation_power_both{}
    @editable MustardAnimationPower : animation_power_target = animation_power_target{}
    @editable SixSevenAnimationPower : animation_power_target = animation_power_target{}
    # @editable SuiAnimationPower : animation_power_self = animation_power_self{}
    # @editable KidOnBoatAnimationPower : animation_power_target = animation_power_target{}
    # @editable OnePoundFishAnimationPower : animation_power_target = animation_power_target{}
 
    <#Add From Bank
    #>


    # ---------------------------------------------------------------------------------------
    # THE BANK
    # @editable PhoneCallPower2 : shoot_prop_in_front_phone_call = shoot_prop_in_front_phone_call{}
    # @editable SleepRegenPower : sleep_regen_power = sleep_regen_power{}
    # @editable ThrowablePower : throwable_power = throwable_power{}
    # @editable CrafterPower : crafter_power = crafter_power{}
    # @editable BomberPower : bomber_power = bomber_power{}
    # @editable RunawayPower : runaway_power = runaway_power{}
    # @editable JayomaPower : jayoma_power = jayoma_power{}
    # @editable ShootIntoPropPower : shoot_into_prop = shoot_into_prop{}
    # @editable ShootToDropWeaponsPower : drop_weapons_power = drop_weapons_power{}
    # @editable RizzmasCarolPower : power_rizzmas_carol_power = power_rizzmas_carol_power{}
    # @editable SlapContestPower : animation_power = animation_power{}
    # @editable UnemployedFriendPower : shoot_into_prop = shoot_into_prop{}
    # @editable NinjaEditPower : unexpected_edit_power = unexpected_edit_power{}
    # @editable StinkPower : stink_power = stink_power{}
