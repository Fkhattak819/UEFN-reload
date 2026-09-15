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

freeze_power := class<concrete>(power_base):
    

    @editable
    IceGranter : item_granter_device = item_granter_device{}

    @editable
    IceItemChecker : conditional_button_device = conditional_button_device{}

    @editable
    IceSFX : audio_player_device = audio_player_device{}

    @editable
    VFX : visual_effect_powerup_device = visual_effect_powerup_device{}

    @editable
    ClearVFX : visual_effect_powerup_device = visual_effect_powerup_device{}

    @editable
    AbilityCooldown : float = 10.0
        
    ActivateAbility(Agent : agent, TargetFort : fort_character, TargetAgent : agent)<suspends>:void=
        VFX.Pickup(TargetAgent)
        IceSFX.Play(TargetAgent)
        TargetFort.PutInStasis(stasis_args{})
        TargetFort.SetVulnerability(false)
        Sleep(4.0)
        TargetFort.SetVulnerability(true)
        TargetFort.ReleaseFromStasis()
        ClearVFX.Pickup(TargetAgent) 
        TargetFort.Show()