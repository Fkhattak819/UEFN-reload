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

animation_power_base := class<concrete>(power_base):
    @editable ImmunityManager : immunity_manager = immunity_manager{}
    @editable Camera : ?gameplay_camera_fixed_point_device = false
    @editable CinematicSeq : cinematic_sequence_device = cinematic_sequence_device{}
    @editable PowerDuration : float = 10.0
    @editable AbilityCooldown : float = 20.0
    @editable RefHolder : creative_prop = creative_prop{}
    @editable TargetRefTrigger : trigger_device = trigger_device{}
    @editable WeaponChecker : conditional_button_device = conditional_button_device{}
    @editable WeaponGranter : item_granter_device = item_granter_device{}
    @editable ExplosiveDevice : explosive_device = explosive_device{}
    @editable AnimationSFX : audio_player_device = audio_player_device{}
    @editable VisualExplosiveDevice: explosive_device = explosive_device{}

    HidePlayersAndStasis(Fort1 : fort_character, Fort2 : fort_character, Time : float)<suspends>:void=
        Fort1.SetVulnerability(false)
        Fort2.SetVulnerability(false)
        Fort1.Hide()
        Fort1.PutInStasis(stasis_args{})
        Fort2.Hide()
        Fort2.PutInStasis(stasis_args{})
        Sleep(Time)
        Fort1.Show()
        Fort1.ReleaseFromStasis()
        Fort2.Show()
        Fort2.ReleaseFromStasis()

    HidePlayerAndStasis(Fort1 : fort_character, Time : float)<suspends>:void=
        Fort1.SetVulnerability(false)
        Fort1.Hide()
        Fort1.PutInStasis(stasis_args{})
        Sleep(Time)
        Fort1.Show()
        Fort1.ReleaseFromStasis()

animation_power_both := class<concrete>(animation_power_base):
    @editable UserRefTrigger :trigger_device = trigger_device{}
    @editable UserTele :teleporter_device = teleporter_device{}
    @editable TargetTele :teleporter_device = teleporter_device{}


    ActivateAbility(Instigator : agent, Target :agent)<suspends>:void=
        if:
            WeaponChecker.IsHoldingItem[Instigator]
            TargetFort := Target.GetFortCharacter[]
            TargetLocation := TargetFort.GetTransform().Translation
            InstigatorFort := Instigator.GetFortCharacter[]
        then:
            if(Cam := Camera?):
                Cam.AddTo(Instigator)
                Cam.AddTo(Target)
            RefHolder.MoveTo(TargetLocation, InstigatorFort.GetTransform().Rotation, 0.1)
            spawn. HidePlayersAndStasis(InstigatorFort, TargetFort, PowerDuration)
            TargetRefTrigger.Trigger(Target)
            UserRefTrigger.Trigger(Instigator)
            UserTele.Teleport(Instigator)
            TargetTele.Teleport(Target)
            AnimationSFX.Play(Target)
            AnimationSFX.Play(Instigator)
            CinematicSeq.Play()
            ExplosiveDevice.Reset()
            ExplosiveDevice.Explode(Instigator)
            Sleep(PowerDuration)
            AnimationSFX.Stop(Target)
            AnimationSFX.Stop(Instigator)
            ExplosiveDevice.Reset()
            if(RefHolder.TeleportTo[TeleAwayPos, rotation{}]){}
            Sleep(0.5)
            spawn. ImmunityManager.ApplyBoth(Instigator, Target) #makes them vulnerable at the end of this

animation_power_target := class<concrete>(animation_power_base):

    ActivateAbility(Instigator : agent, Target :agent)<suspends>:void=
        if:
            WeaponChecker.IsHoldingItem[Instigator]
            TargetFort := Target.GetFortCharacter[]
            TargetLocation := TargetFort.GetTransform().Translation
            InstigatorFort := Instigator.GetFortCharacter[]
        then:
            if(Cam := Camera?):
                Cam.AddTo(Target)
            RefHolder.MoveTo(TargetLocation, InstigatorFort.GetTransform().Rotation, 0.1)
            ExplosiveDevice.Explode(Instigator)
            spawn. HidePlayerAndStasis(TargetFort, PowerDuration)
            TargetRefTrigger.Trigger(Target)
            AnimationSFX.Play(Target)
            CinematicSeq.Play()
            Sleep(PowerDuration)
            ExplosiveDevice.Reset()
            VisualExplosiveDevice.Explode(Instigator)
            if(Cam := Camera?):
                Cam.RemoveFrom(Target)
            if(RefHolder.TeleportTo[TeleAwayPos, rotation{}]){}
            AnimationSFX.Stop(Target)
            Sleep(0.5)
            VisualExplosiveDevice.Reset()
            spawn. ImmunityManager.Apply(Target) #makes them vulnerable at the end of this
            # TargetFort.Damage(damage_args{Amount := 50.0, Instigator := option{InstigatorFort}})

animation_power_self := class<concrete>(animation_power_base):

    ActivateAbility(Instigator : agent)<suspends>:void=
        if:
            WeaponChecker.IsHoldingItem[Instigator]
            InstigatorFort := Instigator.GetFortCharacter[]
            InstigatorLocation := InstigatorFort.GetTransform().Translation
        then:
            if(Cam := Camera?):
                Cam.AddTo(Instigator)
            RefHolder.MoveTo(InstigatorLocation, InstigatorFort.GetTransform().Rotation, 0.1)
            ExplosiveDevice.Reset()
            ExplosiveDevice.Explode(Instigator)
            spawn. HidePlayerAndStasis(InstigatorFort, PowerDuration)
            TargetRefTrigger.Trigger(Instigator)
            AnimationSFX.Play(Instigator)
            CinematicSeq.Play()
            Sleep(PowerDuration)
            if(RefHolder.TeleportTo[TeleAwayPos, rotation{}]){}
            AnimationSFX.Stop(Instigator)
            ExplosiveDevice.Reset()
            Sleep(0.5)
            spawn. ImmunityManager.Apply(Instigator) #makes them vulnerable at the end of this
