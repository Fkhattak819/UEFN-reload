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

one_shot_pickaxe := class<concrete>(remote_power_base):

    @editable
    ConditionalButton1 : conditional_button_device = conditional_button_device{}

    @editable
    ConditionalButton2 : conditional_button_device = conditional_button_device{}

    @editable
    ConditionalButton3 : conditional_button_device = conditional_button_device{}

    @editable
    ConditionalButton4 : conditional_button_device = conditional_button_device{}

    @editable
    ConditionalButton5 : conditional_button_device = conditional_button_device{}

    @editable
    ConditionalButton6 : conditional_button_device = conditional_button_device{}

    @editable
    ConditionalButton7 : conditional_button_device = conditional_button_device{}

    @editable
    ConditionalButton8 : conditional_button_device = conditional_button_device{}

    @editable
    ConditionalButton9 : conditional_button_device = conditional_button_device{}

    @editable
    ConditionalButton10 : conditional_button_device = conditional_button_device{}

    @editable
    ConditionalButton11 : conditional_button_device = conditional_button_device{}

    @editable
    ConditionalButton12 : conditional_button_device = conditional_button_device{}

    @editable
    ConditionalButton13 : conditional_button_device = conditional_button_device{}

    @editable
    ConditionalButton14 : conditional_button_device = conditional_button_device{}



    @editable
    AudioSFX : audio_player_device = audio_player_device{}

    KillPlayer(Instigator : agent, Victim : fort_character)<suspends>:void=
        if(not ConditionalButton1.IsHoldingItem[Instigator],
        not ConditionalButton2.IsHoldingItem[Instigator],
        not ConditionalButton3.IsHoldingItem[Instigator],
        not ConditionalButton4.IsHoldingItem[Instigator],
        not ConditionalButton5.IsHoldingItem[Instigator],
        not ConditionalButton6.IsHoldingItem[Instigator],
        not ConditionalButton7.IsHoldingItem[Instigator],
        not ConditionalButton8.IsHoldingItem[Instigator],
        not ConditionalButton9.IsHoldingItem[Instigator],
        not ConditionalButton10.IsHoldingItem[Instigator],
        not ConditionalButton11.IsHoldingItem[Instigator],
        not ConditionalButton12.IsHoldingItem[Instigator],
        not ConditionalButton13.IsHoldingItem[Instigator],
        not ConditionalButton14.IsHoldingItem[Instigator]):
            Sleep(0.0)
            InstaKill : float = 999.0
            Victim.Damage(damage_args{Instigator := option{Instigator.GetFortCharacter[]}, Amount := InstaKill, Source := option {custom_game_action_causer{} }})
            AudioSFX.Play(Instigator)