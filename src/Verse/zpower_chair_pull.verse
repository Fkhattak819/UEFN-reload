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

chair_pull_power := class<concrete>(remote_power_base):

    OutOfBoundsManager : out_of_bounds_manager = out_of_bounds_manager{}
    @editable ExplosiveDevice : explosive_device = explosive_device{} # for destroying builds only
    @editable ChairDevice : chair_device = chair_device{}
    @editable AudioPlayer : audio_player_device = audio_player_device{}
    @editable AbilityCooldown : float = 30.0
    @editable MoveDuration : float = 3.0
    @editable ExplodeDelay : float = 0.2
    @editable OffsetDistance : float = 200.0 # how far away from the direction you are looking at the player would get pulled to
    @editable ChairRotation : logic = false
    StopEvent<private>: event() = event(){}

    # Stop Powerup
    Delete<public>():void=
        StopEvent.Signal()
        BreakPlayerViewLoop()
        Print("Chair Pull Deleted")

    # Powerup
    ActivatePowerup<public>(CP:CustomPlayer,CPMap:[agent]CustomPlayer)<suspends>:void=
        MaybePlayerInView := GetPlayerInView()
        var MaybeOtherAgent : ?agent = false
        if:
            MaybePlayerInView?
            set MaybeOtherAgent = option. agent[MaybePlayerInView?]
        else:
            set MaybeOtherAgent = FindClosestMaybeAgent(CP, CPMap)

        if (OtherA := MaybeOtherAgent?):
            ThisA := CP.MyAgentObj
            InitalChairT := ChairDevice.GetTransform()
            ChairDevice.Enable()
            if(ThisF:=ThisA.GetFortCharacter[], OtherF:=OtherA.GetFortCharacter[]):
                race:
                    StopEvent.Await() # Game over or player dead
                    loop: # Explosive device
                        ExplosiveDevice.Reset()
                        Sleep(ExplodeDelay)
                        if(ExplosiveDevice.TeleportTo[OtherF.GetTransform()]):
                            ExplosiveDevice.Explode(ThisA)
                    loop: # Move to
                        var MoveToPos : vector3 = ThisF.GetViewLocation() + ThisF.GetViewRotation().GetLocalForward() * OffsetDistance
                        set MoveToPos.Z = ThisF.GetTransform().Translation.Z
                        if(ChairDevice.TeleportTo[OtherF.GetTransform().Translation,ThisF.GetTransform().Rotation]):
                            var NewRotation : rotation = rotation{}
                            if(not ChairRotation?){set NewRotation = ThisF.GetTransform().Rotation}
                            else:
                                if(LookDirection := (MoveToPos - OtherF.GetTransform().Translation).MakeUnitVector[]):
                                    Yaw := RadiansToDegrees(ArcTan(LookDirection.Y, LookDirection.X)) - 90.0
                                    Pitch := RadiansToDegrees(ArcTan(LookDirection.Z, Sqrt((LookDirection.X * LookDirection.X) + (LookDirection.Y * LookDirection.Y))))
                                    Roll := 0.0
                                    set NewRotation = MakeRotationFromYawPitchRollDegrees(Yaw, Pitch, Roll)
                            ChairDevice.Seat(OtherA)
                            AudioPlayer.Play(ThisA)
                            # VerifiedMoveToPos := OutOfBoundsManager.Check(MoveToPos)
                            MoveToResult := ChairDevice.MoveTo(MoveToPos,NewRotation,MoveDuration)
                            if(MoveToResult = move_to_result.DestinationReached):
                                Print("Chair Pull: Move to Destination reached")
                                ChairDevice.Eject(OtherA)
                                break

                Print("Loop Canceled")

            spawn. Reset(InitalChairT)
           

    Reset(InitialChairT : transform)<suspends>:void=
        if(ChairDevice.TeleportTo[InitialChairT]){Print("Chair device back to primary pos")}
        ChairDevice.Disable()
        Sleep(ExplodeDelay * 2.0)
        ExplosiveDevice.Reset()
