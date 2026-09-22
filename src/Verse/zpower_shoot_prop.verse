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

shoot_prop_power := class<concrete>(power_base):

    OutOfBoundsManager : out_of_bounds_manager = out_of_bounds_manager{}
    @editable ExplosiveDevice : explosive_device = explosive_device{}
    @editable ConditionalDevice : conditional_button_device = conditional_button_device {}
    @editable Prop : creative_prop = creative_prop{}
    @editable PreviewCinSeqDevice : cinematic_sequence_device = cinematic_sequence_device{}
    @editable FullVisibilityCinSeqDevice : cinematic_sequence_device = cinematic_sequence_device{}
    @editable AudioPlayer : audio_player_device = audio_player_device{}
    @editable LockVertical : logic = false
    @editable WearableVFX : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable AbilityDuration : float = 3.0
    @editable AbilityDistance : float = 4000.0
    @editable PreviewUpdateDelay : float = 0.1
    @editable PreviewDistance : float = 600.0
    @editable OffsetZ : float = 30.0
    @editable ConditionalCheckingDelay : float = 0.1
    @editable AbilityCooldown : float = 15.0
    @editable ExplosionDelay : float = 0.5
    @editable DefaultPropPos : vector3 = vector3{}
    StopEvent<private>: event() = event(){}
    ActivateEvent<private>: event() = event(){}

    Init<public>(A:agent):void=
        if(F:=A.GetFortCharacter[]):
            spawn{AbilityChecking(A,F)}

    # Stop Powerup
    Delete<public>():void=
        StopEvent.Signal()
        Print("PreviewAndSend Deleted")

    ActivateAbility<public>()<suspends>:void=
        ActivateEvent.Signal()
        Print("PreviewAndSend Activated")

    AbilityChecking<private>(A:agent,F:fort_character)<suspends>:void=
        var ActivatedLogic : logic = false
        ConditionalDevice.Enable()
        Prop.Show()
        race:
            StopEvent.Await() # when eliminated or game over
            loop:
                Sleep(ConditionalCheckingDelay)
                if(ConditionalDevice.IsHoldingItem[A,0]): # When holding remote
                    var TempV3 : vector3 = vector3{}
                    PreviewCinSeqDevice.Play(A)
                    race: # preview
                        loop: # when not holding conditional
                            Sleep(ConditionalCheckingDelay)
                            if(not ConditionalDevice.IsHoldingItem[A,0]):
                                break
                        loop: # displaying preview
                            Sleep(PreviewUpdateDelay)
                            set TempV3 = F.GetViewLocation() + F.GetViewRotation().GetLocalForward() * PreviewDistance
                            if(LockVertical?){set TempV3.Z = F.GetTransform().Translation.Z + OffsetZ}
                            VerifiedLocation := OutOfBoundsManager.Check(TempV3)
                            if(Prop.TeleportTo[VerifiedLocation,F.GetTransform().Rotation]){}
                        block: # when ability activated
                            ActivateEvent.Await()
                            set ActivatedLogic = true
                    PreviewCinSeqDevice.Stop(A)
                    if(not ActivatedLogic?){Print("Didnt activate the ability")}
                    else:
                        FullVisibilityCinSeqDevice.Play()
                        AudioPlayer.Play()
                        race: # sending
                            block:
                                var MoveToStart : vector3 =  F.GetViewLocation() + F.GetViewRotation().GetLocalForward() * PreviewDistance
                                if(LockVertical?){set MoveToStart.Z = F.GetTransform().Translation.Z + OffsetZ}
                                var MoveToEnd : vector3 =  F.GetViewLocation() + F.GetViewRotation().GetLocalForward() * AbilityDistance
                                if(LockVertical?){set MoveToEnd.Z = F.GetTransform().Translation.Z + OffsetZ}
                                if(Prop.TeleportTo[MoveToStart,F.GetTransform().Rotation]):
                                    MoveToResult := Prop.MoveTo(MoveToEnd,F.GetTransform().Rotation,AbilityDuration)
                                    if(MoveToResult = move_to_result.DestinationReached):
                                        Print("Prop reached the destination")
                            loop:
                                if(ExplosiveDevice.TeleportTo[Prop.GetTransform()]):
                                    ExplosiveDevice.Explode(A)
                                Sleep(ExplosionDelay)
                                ExplosiveDevice.Reset()
                        Print("Loop Canceled")
             
                    if(ActivatedLogic?):
                        FullVisibilityCinSeqDevice.Stop()
                        AudioPlayer.Stop()
                        # Sleep(AbilityCooldown)
                        Print("Ability back online")
                        set ActivatedLogic = false
        spawn. Reset(A)               
            

    Reset(A : agent)<suspends>:void=
        PreviewCinSeqDevice.Stop(A)
        FullVisibilityCinSeqDevice.Stop()
        if(Prop.TeleportTo[DefaultPropPos,rotation{}]){Print("PreviewAndSend: Prop returned to original Pos")}
        ConditionalDevice.Disable()
        Prop.Hide()
        Sleep(ExplosionDelay * 2.0)
        ExplosiveDevice.Reset()