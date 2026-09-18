using { /Fortnite.com/Characters }
using { /Fortnite.com/Teams }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }
using { /Verse.org/Simulation/Tags }
using { /UnrealEngine.com/Temporary}
using { /Fortnite.com/Playspaces }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /Verse.org/Colors/NamedColors }
using { /Fortnite.com/Devices/CreativeAnimation }
using { /Fortnite.com/Devices/CreativeAnimation/InterpolationTypes }
using { /Fortnite.com/Game }
using { /Verse.org/Assets }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
missile_power := class<concrete>(power_base):

    @editable MissileDevice: missile_device = missile_device{}
    @editable AbilityCooldown : float = 30.0

    ActivateAbility(Agent:agent)<suspends>:void=
        Print("Remote")
        spawn {FlyMissileAsync(Agent)}

    FlyMissileAsync(Agent:agent)<suspends>:void=
        if(MissileDevice.FlightEnabled = true, MissileDevice.MaybeAgentObj = false):
            MissileDevice.Init(Agent)
            Sleep(0.5)
            MissileDevice.SpawnFly()

missile_device := class<concrete>:

    @editable   Chair:chair_device = chair_device{}
    @editable   PlaneProp:creative_prop = creative_prop{}
    @editable   StartLocProp:creative_prop = creative_prop{}
    @editable   GroundMutatorZone : mutator_zone_device = mutator_zone_device{}
    @editable   BorderMutatorZone : mutator_zone_device = mutator_zone_device{}
    @editable   EngineAud:audio_player_device = audio_player_device{}
    @editable   ED:explosive_device = explosive_device{}
    @editable   EDInvis:explosive_device = explosive_device{}

    @editable   AllowedFlightTime:float = 10.0
    # @editable   OutOfBoundsManager : out_of_bounds_manager = out_of_bounds_manager{}
    @editable   Teleporter : teleporter_device = teleporter_device{}
    var SubscriptionFunctions : []cancelable = array{}
    var ZAxisOffset : float = 300.0
    StopEvent<private>: event() = event(){}  

    var OptionalUIPerPlayer:[agent]?canvas = map{}

    var MaybeAgentObj:?agent = false
    var Speed<private>:float = 100.0
    var FlightEnabled<public>:logic = true
    var StartLoc:transform = transform{}

    GetAgent()<decides><transacts>:agent = MaybeAgentObj? 

    DebugGroundMessage(Agent:agent):void=Print("Exit Mutator")

    Init(Agent:agent):void=
        PlaneProp.Hide()
        if(not MaybeAgentObj?):
            AgentExitsBorderEvent := BorderMutatorZone.AgentExitsEvent.Subscribe(StopFlight)
            AgentEntersGroundEvent := GroundMutatorZone.AgentEntersEvent.Subscribe(StopFlight)
            set SubscriptionFunctions = SubscriptionFunctions + array{AgentExitsBorderEvent, AgentEntersGroundEvent}
        set MaybeAgentObj = option{Agent}

    ResetPlane(FC:fort_character)<suspends>:void=
        if. Chair.TeleportTo[PlaneProp.GetTransform().Translation + vector3{Z := -1000.0}, PlaneProp.GetTransform().Rotation]
        Sleep(0.3)
        FC.SetVulnerability(true)
        set FlightEnabled = true
        set MaybeAgentObj = false

    SpawnFly():void=
        if:
            Agent := MaybeAgentObj?
            FC := Agent.GetFortCharacter[]
            set StartLoc = FC.GetTransform()
        spawn. Fly()

    Fly()<suspends>:void=
        Print("FLIGHT")
        PlaneProp.Show()
        var PreviousLookDirection:rotation = rotation{}
       
        if:
            Agent := MaybeAgentObj?
            FC := Agent.GetFortCharacter[]
            FCStart := FC.GetTransform()
            StartLocProp.TeleportTo[FCStart]
        then:
            Sleep(0.1)
            StartTrans := StartLocProp.GetTransform().Translation
            option. Chair.TeleportTo[vector3{X := StartTrans.X, Y := StartTrans.Y, Z := StartTrans.Z + ZAxisOffset}, rotation{}]

            Chair.Seat(Agent)
            GroundMutatorZone.Enable()
            BorderMutatorZone.Enable()
            var PreviousLoc:vector3 = Chair.GetTransform().Translation
            Sleep(0.2)
            race:
                Sleep(AllowedFlightTime)
                StopEvent.Await()
                loop:
                    Sleep(0.0)
                    EDInvis.Explode(Agent)
                    if (FlightEnabled = false):
                        Print("FLIGHT DISABLED")
                        break
                    
                    EngineAud.Play()
                    Trans := Chair.GetTransform()
                    Loc := Trans.Translation
                    LookRot := FC.GetViewRotation()

                    if:
                        SlerpedLookRot := Slerp[PreviousLookDirection, LookRot, 0.0000001]
                        x2SlerpedLookRot := Slerp[PreviousLookDirection, SlerpedLookRot, 0.0000001]
                    then:
                        LookLoc := SlerpedLookRot.GetLocalForward()
                        ForwardLoc := Lerp(PreviousLoc, (Loc + LookLoc * (Speed*300.0)), 0.005)
                        set PreviousLookDirection = LookRot
                        set PreviousLoc = ForwardLoc
                        Chair.MoveTo(ForwardLoc, x2SlerpedLookRot, 0.1)
                    EDInvis.Reset()
            StopFlight(Agent)


    RemoveHUD(Agent:agent):void=
        if(Player:=player[Agent], PlayerUI:=GetPlayerUI[Player]):
            if(MyUI:=OptionalUIPerPlayer[Player]?):
                PlayerUI.RemoveWidget(MyUI)
                if(set OptionalUIPerPlayer[Player] = false) {}

    StopFlight(MyAgent : agent):void=
        if (Agent := MaybeAgentObj?, MyAgent = Agent):
            Print("STOP FLIGHT FUNC")
            set FlightEnabled = false
            if:
                FC := Agent.GetFortCharacter[]
                Teleporter.TeleportTo[StartLoc.Translation, StartLoc.Rotation]
                FC.SetVulnerability(false)
            then:
                Teleporter.Teleport(Agent)
                FC.Show()
            GroundMutatorZone.Disable()
            BorderMutatorZone.Disable()
            PlaneDeath()

    PlaneDeath():void=
        Print("PLANE DEATH")
        if:
            Agent := MaybeAgentObj?
            FC := Agent.GetFortCharacter[]
        then:
            ED.Explode(Agent)
            PlaneProp.Hide()
            EngineAud.Stop()
            spawn. ResetPlane(FC)

    Delete():void=
        StopEvent.Signal()
        for (Function : SubscriptionFunctions):
            Function.Cancel()
        set SubscriptionFunctions = array{}