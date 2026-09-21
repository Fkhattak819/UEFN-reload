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


ForceMode := enum:
    Push
    Pull

pull_power := class<concrete>(power_base):

    @editable
    WeaponDetector : conditional_button_device = conditional_button_device{}
    @editable
    PullGranter : item_granter_device = item_granter_device{}
    @editable
    Modulator : movement_modulator_device = movement_modulator_device{}
    @editable
    Direction: ForceMode = ForceMode.Push
    @editable
    PullSFX : audio_player_device = audio_player_device{}

    # Coroutine that performs the push / pull
    ApplyImpulse(InstAgent:agent, TargetAgent:agent)<suspends>:void=
        if:
            InstFC := InstAgent.GetFortCharacter[]
            TargetFC := TargetAgent.GetFortCharacter[]
            WeaponDetector.IsHoldingItem[InstAgent]
        then:
            AttackerRot := InstFC.GetViewRotation()
            DeviceLoc   := Modulator.GetTransform().Translation
            PullSFX.Play(TargetAgent)
            if (Direction = ForceMode.Push):
                if (Modulator.TeleportTo[DeviceLoc, AttackerRot]){}
                Modulator.Activate(TargetAgent)
            else:
                OppRot := AttackerRot.ApplyYaw(3.14159)  # 180°
                if (Modulator.TeleportTo[DeviceLoc, OppRot]){}
                Modulator.Activate(TargetAgent)
