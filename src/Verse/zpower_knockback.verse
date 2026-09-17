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

knockback_power := class<concrete>(power_base):

    @editable 
    GrindDevice:grind_powerup_device = grind_powerup_device{}
    @editable 
    AudioPlayer : audio_player_device = audio_player_device{}
    @editable
    Modulator : movement_modulator_device = movement_modulator_device{}
    @editable
    Direction: ForceMode = ForceMode.Push

    # Coroutine that performs the push / pull
    ApplyImpulse(InstAgent:agent, TargetAgent:agent)<suspends>:void=
        if:
            InstFC := InstAgent.GetFortCharacter[]
            TargetFC := TargetAgent.GetFortCharacter[]
        then:
            AttackerRot := InstFC.GetViewRotation()
            DeviceLoc   := Modulator.GetTransform().Translation
            AudioPlayer.Play(TargetAgent)
            if (Direction = ForceMode.Push):
                if (Modulator.TeleportTo[DeviceLoc, AttackerRot]){}
                Modulator.Activate(TargetAgent)
                GrindDevice.Pickup(TargetAgent)
            else:
                OppRot := AttackerRot.ApplyYaw(3.14159)  # 180°
                if (Modulator.TeleportTo[DeviceLoc, OppRot]){}
                Modulator.Activate(TargetAgent)
                GrindDevice.Pickup(TargetAgent)