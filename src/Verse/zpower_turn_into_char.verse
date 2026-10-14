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
using { /Fortnite.com/Playspaces }

turn_into_char_power := class<concrete>(power_base):

    @editable
    ClassSelector : class_and_team_selector_device = class_and_team_selector_device{}

    # @editable
    # ItemGranter : item_granter_device = item_granter_device{}

    @editable
    BP : creative_prop = creative_prop{}

    @editable
    IdleAnim : cinematic_sequence_device = cinematic_sequence_device{}

    @editable
    RunAnim : cinematic_sequence_device = cinematic_sequence_device{}

    @editable
    ZAxisOffset : float = 0.0

    @editable
    YAxisOffset : float = 0.0

    @editable
    XAxisOffset : float = 0.0

    @editable
    PropMoveTime : float = 0.20

    @editable
    CharSFX : audio_player_device = audio_player_device{}
    StopEvent<private>: event() = event(){}


    Delete<public>(Agent : agent):void=
        StopEvent.Signal()
        IdleAnim.Stop()
        RunAnim.Stop()
        BP.Hide()

    ActivateAbility<public>(Agent : agent):void=
        ClassSelector.ChangeClass(Agent)
        spawn. StartMovement(Agent, BP)

    AttachChar(Agent : agent, FortChar : fort_character)<suspends>:void=
        if(FortChar1 := Agent.GetFortCharacter[]):
            FortChar1.Hide()
            race:
                StopEvent.Await()
                loop:
                    PlayerLocation := FortChar1.GetTransform().Translation
                    PlayerRotation := FortChar1.GetTransform().Rotation
                    BPLocation := vector3{X := PlayerLocation.X + XAxisOffset, Y := PlayerLocation.Y + YAxisOffset, Z := PlayerLocation.Z + ZAxisOffset}
                    BP.MoveTo(BPLocation, PlayerRotation, PropMoveTime)

            NewBPLocation := TeleAwayPos
            BP.MoveTo(NewBPLocation, rotation{}, PropMoveTime)
            Print("Broke Char Loop")

    StartMovement(Agent : agent, FollowProp : creative_prop)<suspends>:void=
        if(PlayerFC := Agent.GetFortCharacter[]):
            CharSFX.Play(Agent)
            PlayerFC.Hide()
            IdleAnim.Play(Agent)
            PlayerFC.Hide()
            FollowProp.Show()
            # Event := PlayerFC.SprintedEvent().Subscribe(OnMoved)
            spawn. AttachChar(Agent, PlayerFC)
            
    # OnMoved(MoveData : tuple(fort_character, logic)):void=
    #     if (Agent := MoveData(0).GetAgent[]):
    #         if (MoveData(1)?):
    #             IdleAnim.Stop(Agent)
    #             RunAnim.Play(Agent)
    #         else:
    #             RunAnim.Stop(Agent)
    #             IdleAnim.Play(Agent)