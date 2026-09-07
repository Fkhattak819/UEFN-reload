using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /Verse.org/Colors }
using { /Verse.org/Assets }
using { /Verse.org }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }

secret_weapon_power := class<concrete>:
    # Name shown in logs/hud/etc.
    GetName():string = "Unnamed"

    # Core hook every power must implement.
    # The weapon instance is passed in so behaviors can use weapon devices (CinematicSeq, ExplosiveDevice, etc.).
    Activate(CPInstigator : CustomPlayer, CPTarget : CustomPlayer, Weapon : secret_weapon)<suspends>:void=
        if(InstigatorFC := CPInstigator.MyAgentObj.GetFortCharacter[], TargetFC := CPTarget.MyAgentObj.GetFortCharacter[]):
            TargetFCTransform := TargetFC.GetTransform()
            InstigatorFCTransform := InstigatorFC.GetTransform()

            # Reuse the weapon’s shared bits
            Weapon.Holder.MoveTo(TargetFCTransform.Translation, InstigatorFCTransform.Rotation, 0.1)
            Weapon.CinematicSeq.Play()
            Sleep(Weapon.PowerDuration)
            TargetFC.Damage(damage_args{
                Amount := Weapon.Damage,
                Instigator := option{InstigatorFC},
                Source := option{custom_game_action_causer{}}
            })

            Weapon.Holder.MoveTo(vector3{X := 0.0, Y := 0.0, Z := -1000.0}, rotation{}, 0.1)

banana_power := class<concrete>(secret_weapon_power):
    GetName<override>():string = "Banana"

croc_power := class<concrete>(secret_weapon_power):
    GetName<override>():string = "Croc"

deer_power := class<concrete>(secret_weapon_power):
    GetName<override>():string = "Deer"

elephant_power := class<concrete>(secret_weapon_power):
    GetName<override>():string = "Elephant"

shark_power := class<concrete>(secret_weapon_power):
    GetName<override>():string = "Shark"

bicycle_power := class<concrete>(secret_weapon_power):
    @editable
    BehindTeleporter : teleporter_device = teleporter_device{}

    GetName<override>():string = "Croc"

    Activate<override>(CPInstigator : CustomPlayer, CPTarget : CustomPlayer, Weapon : secret_weapon)<suspends>:void=
        if(InstigatorFC := CPInstigator.MyAgentObj.GetFortCharacter[], TargetFC := CPTarget.MyAgentObj.GetFortCharacter[]):
            TargetFCTransform := TargetFC.GetTransform()
            InstigatorFCTransform := InstigatorFC.GetTransform()

            # Reuse the weapon’s shared bits
            Weapon.Holder.MoveTo(TargetFCTransform.Translation, InstigatorFCTransform.Rotation, 0.1)
            spawn. TeleportBehind(CPInstigator, CPTarget)
            Weapon.CinematicSeq.Play()

            Sleep(Weapon.PowerDuration)

            TargetFC.Damage(damage_args{
                Amount := Weapon.Damage,
                Instigator := option{InstigatorFC},
                Source := option{custom_game_action_causer{}}
            })

            Weapon.Holder.MoveTo(vector3{X := 0.0, Y := 0.0, Z := -1000.0}, rotation{}, 0.1)

    TeleportBehind(CPInstigator : CustomPlayer, CPTarget : CustomPlayer)<suspends>:void=
        if(FC := CPTarget.MyAgentObj.GetFortCharacter[]):
            Print("Teleporting Behind Enemy")
            Pos : vector3 = FC.GetTransform().Translation
            Rotation : rotation = FC.GetTransform().Rotation
            Offset : vector3 = Rotation.RotateVector(vector3{X:=-100.0, Y:=0.0, Z:=10.0})
            Destination : vector3 = Pos + Offset
            PlayerRefDestination : vector3 = Pos
            
            if (BehindTeleporter.TeleportTo[PlayerRefDestination, Rotation]):
                Print("Teleported Behind Enemy")
                BehindTeleporter.Teleport(CPInstigator.MyAgentObj)

orca_power := class<concrete>(secret_weapon_power):
    @editable Explosive : explosive_device = explosive_device{}
    @editable ZOffset : float = -25.0

    GetName<override>():string = "Orca"

    Activate<override>(CPInstigator : CustomPlayer, CPTarget : CustomPlayer, Weapon : secret_weapon)<suspends>:void=
        if(InstigatorFC := CPInstigator.MyAgentObj.GetFortCharacter[], TargetFC := CPTarget.MyAgentObj.GetFortCharacter[]):
            var T : transform = TargetFC.GetTransform()
            R := InstigatorFC.GetTransform().Rotation

            Weapon.Holder.MoveTo(T.Translation, R, 0.1)
            Weapon.CinematicSeq.Play()

            Sleep(Weapon.PowerDuration)

            set T = TargetFC.GetTransform()
            Explosive.MoveTo(vector3{X:=T.Translation.X, Y:=T.Translation.Y, Z:=T.Translation.Z + ZOffset}, R, 0.1)
            Explosive.Explode(CPInstigator.MyAgentObj)
            Explosive.Reset()

            TargetFC.Damage(damage_args{
                Amount := Weapon.Damage,
                Instigator := option{InstigatorFC},
                Source := option{custom_game_action_causer{}}
            })

            Weapon.Holder.MoveTo(vector3{X := 0.0, Y := 0.0, Z := -1000.0}, rotation{}, 0.1)

secret_weapon := class<concrete>:
    @editable Index      : int = 0                                   # matches your GameManager/PinPad index
    @editable Checker    : conditional_button_device = conditional_button_device{}
    @editable VFX        : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable DamageAmp  : damage_amplifier_powerup_device = damage_amplifier_powerup_device{}
    @editable DamageAmpClearTrigger : trigger_device = trigger_device{}
    @editable CinematicSeq : cinematic_sequence_device = cinematic_sequence_device{}
    @editable PowerDuration : float = 10.0
    @editable Holder : creative_prop = creative_prop{}
    @editable Damage : float = 50.0

    # NEW: assign one of your concrete behaviors in the editor per weapon
    @editable Behavior : secret_weapon_power = secret_weapon_power{}

    var IsHappening : logic = false

    AnimationOnPlayerDamage(CPInstigator : CustomPlayer, CPTarget : CustomPlayer, Type : int)<suspends>:void=
        if(IsHappening?):
            return

        if (Checker.IsHoldingItem[CPInstigator.MyAgentObj]):
            if(InstigatorFC := CPInstigator.MyAgentObj.GetFortCharacter[], TargetFC := CPTarget.MyAgentObj.GetFortCharacter[], Player := player[CPInstigator.MyAgentObj], Player.IsActive[]):
                set IsHappening = true
                Print("Playing Custom Weapon {Behavior.GetName()}")
                # Defer to the behavior to do its thing
                Behavior.Activate(CPInstigator, CPTarget, Self)
                set IsHappening = false