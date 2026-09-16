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

jump_explode_power := class<concrete>(power_base):
    
    @editable
    JumpExplodeSFX : audio_player_device = audio_player_device{}

    @editable
    Bomb : explosive_device = explosive_device{}
    
    MoveBomb(Agent : agent, Explosion : explosive_device)<suspends>:void=
        Print("jumped")
        Sleep(0.01)
            if:
                FortCharacter := Agent.GetFortCharacter[]
                PlayerRotation: rotation = FortCharacter.GetViewRotation()
                PlayerPosition: vector3 = FortCharacter.GetTransform().Translation
            then:
                spawn. ExplodeAndResetBomb(Agent, PlayerPosition, PlayerRotation, Explosion)

    ExplodeAndResetBomb(Agent : agent, Pos : vector3, Ro : rotation, Explosion : explosive_device)<suspends>:void=
        Explosion.MoveTo(Pos, Ro, 0.01)
        Explosion.Explode(Agent)
        JumpExplodeSFX.Play(Agent)
        Sleep(0.1)
        Explosion.Reset()
        Explosion.MoveTo(TeleAwayPos, Ro, 0.01)


    # If you want to use this one
    # it will only track the jumping for one player instead of the whole lobby
    # and only track jumping for when someone has the power
    
    StopEvent<private>: event() = event(){}

    Delete<public>():void=
        StopEvent.Signal()
        JumpExplodeSFX.Disable()

    Init<public>(A:agent):void=
        if(F:=A.GetFortCharacter[]) { spawn{StartPowerup(A,F)} }
        JumpExplodeSFX.Enable()

    StartPowerup<private>(A:agent,F:fort_character)<suspends>:void=
        race:
            StopEvent.Await()
            loop:
                Sleep(0.1)
                F.JumpedEvent().Await()
                spawn{MoveBomb(A,Bomb)}

        Print("Loop Canceled")
