
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Game }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
prop_follow_power := class<concrete>(remote_power_base):

    @editable
    AbilityCooldown : float = 30.0

    @editable
    AbilityDuration : float = 10.0

    @editable
    XDistanceFromTarget : float = -30.0 # try to reach 50.0 behind the player

    @editable
    HitDistance : float = 50.0 

    @editable FollowSpeed : float = 700.0      # cm / s  – how fast the prop flies
    var UpdateRate  : float = 0.1       # s       – tick interval (≈20 FPS)

    @editable
    PropFollowSFX : audio_player_device = audio_player_device{}

    @editable
    Prop : creative_prop = creative_prop{}

    @editable
    ExplosiveDevice : explosive_device = explosive_device{}

    StopEvent<private>: event() = event(){}

    Delete<public>():void=
        StopEvent.Signal()
        BreakPlayerViewLoop()

    # on remote primary click, spawn prop that follows chosen enemy
    # will continuously follow enemy until time limit or certain distance is reached between prop and enemy
    # if certain distance is reached, kill the enemy
    # will need delete function

    ActivateAbility(CP : CustomPlayer, CPMap : [agent]CustomPlayer)<suspends>:void=
        MaybeTargetAgent := PickTarget(CP, CPMap)
        if (TargetAgent := MaybeTargetAgent?, InstigatorAgent := CP.MyAgentObj):
            StartFollowLoop(InstigatorAgent, TargetAgent)

    StartFollowLoop(InstigatorAgent : agent, TargetAgent : agent)<suspends>:void=
        PropFollowSFX.Play(TargetAgent)
        if(InstigatorFort := InstigatorAgent.GetFortCharacter[], TargetFort := TargetAgent.GetFortCharacter[]):
            if. Prop.TeleportTo[InstigatorFort.GetTransform()]
            spawn. FollowLoop(TargetFort, InstigatorFort)

    FollowLoop(Target : fort_character, Instigator : fort_character)<suspends>:void =
        # race:
        #     Sleep(AbilityDuration)
        #     loop:
        #         if (not Target.IsActive[]):
        #             break
        #         var TargetPos  : vector3 = Target.GetTransform().Translation
        #         var DesiredPos : vector3 =
        #             TargetPos + vector3{X:=XDistanceFromTarget, Y:=0.0, Z:=0.0}
 
        #         if. Prop.TeleportTo[DesiredPos, Prop.GetTransform().Rotation]

        #         if (Distance(TargetPos, DesiredPos) <= HitDistance):
        #             Target.Damage(9999.0)
        #             if. Prop.TeleportTo[TeleAwayPos, rotation{}]
        #             break

        #         Sleep(TickRate)
        var CurrentTransform : transform = Prop.GetTransform()
        var CurrentLocation  : vector3   = CurrentTransform.Translation
        race:
            StopEvent.Await()
            Sleep(AbilityDuration)
            loop:
                # quit if target gone
                if (not Target.IsActive[]):
                    break
                var TargetPos : vector3 = Target.GetTransform().Translation
                var GoalPos   : vector3 = TargetPos + vector3{X := XDistanceFromTarget, Y := 0.0, Z := 0.0}

                var ToGoal      : vector3 = GoalPos - CurrentLocation
                var DistToGoal  : float   = ToGoal.Length()

                if. Agent := Target.GetAgent[] then. ExplosiveDevice.Explode(Agent)
                ExplosiveDevice.Reset()

                # check “hit” radius first
                if (DistToGoal <= HitDistance):
                    Target.Damage(damage_args{Instigator := option{Instigator}, Amount := 999.0, Source := option {custom_game_action_causer{} }})      # or Target.Eliminate()
                    break

                # step toward goal, capped by FollowSpeed × UpdateRate
                if (DistToGoal > 1.0):         # tiny buffer to prevent jitter
                    var StepDist : float   = FollowSpeed * UpdateRate
                    var Step : vector3 = vector3{}
                    if (DistToGoal <= StepDist):
                        set Step = ToGoal
                    else:
                        if (Unit := ToGoal.MakeUnitVector[]):
                            NewX := Unit.X * StepDist
                            NewY := Unit.Y * StepDist
                            NewZ := Unit.Z * StepDist
                            set Step = vector3{X:=NewX, Y:=NewY, Z:=NewZ}
                            
                    set CurrentLocation = CurrentLocation + Step

                # move the prop; abort if teleport fails
                Prop.MoveTo(CurrentLocation, Target.GetViewRotation(), UpdateRate)

        if. Prop.TeleportTo[TeleAwayPos, rotation{}]
        

    