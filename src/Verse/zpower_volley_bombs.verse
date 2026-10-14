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

volley_bombs_power := class<concrete>(power_base):

    #@editable Prop : creative_prop = creative_prop{}
    @editable AudioPlayer : audio_player_device = audio_player_device{}
    @editable ExplosiveDevice : explosive_device = explosive_device{}
    @editable ShotsAvailable : int = 6
    @editable ShotDistance : float = 800.0
    @editable ShotTravelTime : float = 0.5
    @editable AbilityCooldown : float = 25.0
    @editable WearableVFX : visual_effect_powerup_device = visual_effect_powerup_device{}

    ResetExplosiveDeviceDelay : float = 0.1
    StopEvent<private>: event() = event(){}  

    # Stop Powerup
    Delete<public>():void=
        StopEvent.Signal()
        Print("ShootingProps Deleted")

    # Use Powerup
    ActivateAbility<public>(A:agent)<suspends>:void=
        Print("ShootingProps Activated")
        ExplosiveDevice.Show()
        ExplosiveDevice.Reset()
        AudioPlayer.Enable()
        AudioPlayer.Play(A)
        InitalExplosiveT := ExplosiveDevice.GetTransform()
        if(F:=A.GetFortCharacter[]):
            race:
                StopEvent.Await() # when game over or player dead
                loop:
                    ExplosiveDevice.ExplodedEvent.Await()
                    Sleep(ResetExplosiveDeviceDelay)
                    ExplosiveDevice.Reset()
                    Print("Reseting")
                block: # when ability over
                    for(I:=1 .. ShotsAvailable + 1): # ability over once all shots have been sent out
                        Print("Shot {I} sent out")
                        block: # Destination reached
                            StartPos := F.GetViewLocation() + F.GetViewRotation().GetLocalForward()
                            EndPos := F.GetViewLocation() + F.GetViewRotation().GetLocalForward() * ShotDistance
                            Rotation := F.GetTransform().Rotation
                            if(ExplosiveDevice.TeleportTo[StartPos,Rotation]):
                                MoveToResult := ExplosiveDevice.MoveTo(EndPos,Rotation,ShotTravelTime)
                                if(MoveToResult = move_to_result.DestinationReached):
                                    Print("Reached destination")
                                    ExplosiveDevice.Explode(A) 
            Print("Loop Canceled")
            Print("Ability over")
        AudioPlayer.Disable()
        ExplosiveDevice.Hide()     
        if(ExplosiveDevice.TeleportTo[InitalExplosiveT]){Print("Moving volley bombs explosive device back")}     
        Sleep(2.0)
        ExplosiveDevice.Reset()