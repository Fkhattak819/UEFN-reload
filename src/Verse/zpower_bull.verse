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

bull_power := class<concrete>(power_base):

    @editable ExplosiveDevice : explosive_device = explosive_device{}
    @editable ClassSelector  : class_and_team_selector_device  = class_and_team_selector_device {}
    # ATTACH THE MUTATOR ZONE TO EXPLOSIVE DEVICE
    @editable MutatorZone : mutator_zone_device = mutator_zone_device{}
    @editable AudioPlayer : audio_player_device = audio_player_device{}
    #Explosion delay = follow delay
    # Min value should be 0.11
    @editable ExplosionDelay : float = 0.5
    var BreakLoop : logic = false

    StopEvent<private>: event() = event(){}
    StartEvent<private>: event() = event(){}

    Init<public>(A:agent)<suspends>:void=
        set BreakLoop = false
        ClassSelector.Enable()
        ClassSelector.ChangeClass(A)
        ClassSelector.Disable()
        MutatorZone.Enable()
        InitalT := ExplosiveDevice.GetTransform()
        if(F:=A.GetFortCharacter[]):
            race:
                StopEvent.Await()
                loop:
                    if(F.IsActive[] and not BreakLoop?):
                        ExplosiveDevice.Reset()
                        Sleep(ExplosionDelay)
                        if(ExplosiveDevice.TeleportTo[F.GetTransform()]):
                            ExplosiveDevice.Explode(A)
                    else:
                        break
                loop:
                    Sleep(0.1)
                    if(F.IsActive[] and not BreakLoop?):
                        Print("looping")
                        Result := MutatorZone.AgentEntersEvent.Await()
                        if(Result <> A):
                            Print("playing audio")
                            AudioPlayer.Play(A) 
                    else:
                        break
            Print("Loop Canceled")
        # Resets

        spawn. Reset(InitalT, A)
     

    StartPower<public>():void= StartEvent.Signal()

    # Stop/Reset Powerup
    Delete<public>():void=
        set BreakLoop = true
        StopEvent.Signal()
        AudioPlayer.Stop()
        Print("Bull Deleted")


    Reset(InitialT : transform, A : agent)<suspends>:void=
        if(ExplosiveDevice.TeleportTo[InitialT]){}
        Sleep(ExplosionDelay * 2.0)
        ExplosiveDevice.Reset()
        MutatorZone.Disable()
        AudioPlayer.Stop(A)
    