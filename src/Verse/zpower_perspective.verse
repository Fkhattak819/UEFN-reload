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

perspective_power := class<concrete>(power_base):
    
    @editable PerspectiveOrbitCamera : gameplay_camera_orbit_device = gameplay_camera_orbit_device {}
    @editable WeaponGranter : item_granter_device = item_granter_device{}
    @editable WeaponHolder : conditional_button_device = conditional_button_device{}

    @editable CardboardHud : hud_message_device = hud_message_device{}
    @editable AudioPlayer : audio_player_device = audio_player_device{}
    @editable VFX : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable ResetVFX : visual_effect_powerup_device = visual_effect_powerup_device{}

    @editable AbilityActiveDuration : float = 10.0
    @editable AbilityCooldown : float = 30.0
    StopEvent<private>: event() = event(){}

    # Stop Powerup
    Delete<public>():void=
        StopEvent.Signal()
        Print("Perspective Deleted")

    ActivateAbility<public>(Instigator : agent, Target : agent)<suspends>:void=
        Print("Blind Before Condditional")
        if(WeaponHolder.IsHoldingItem[Instigator]):
            Print("Blind After Condditional")
            PerspectiveOrbitCamera.Enable()
            PerspectiveOrbitCamera.AddTo(Target)
            VFX.Pickup(Target)
            Sleep(0.1)
            CardboardHud.Show(Target)

            # Waiting for ability or game to be over
            race:
                StopEvent.Await()
                Sleep(AbilityActiveDuration)

            # Removing FPS
            ResetVFX.Pickup(Target)
            PerspectiveOrbitCamera.RemoveFrom(Target)
            PerspectiveOrbitCamera.Disable()