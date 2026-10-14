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

xray_power := class<concrete>(power_base):

    # Use 15 beacons
    # Create one material that you want to use, make sure its a UI material
    # Create one widget blueprint
    # Apply it to all beacons
    # You can copy the bounty_hunter one since it has all the correct settings
    @editable Beacons : []beacon_device = array{}
    # @editable WearableVFX : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable UpdateBeaconLocationDelay : float = 0.1
    StopEvent<private>: event() = event(){}

    var TrackedPlayers : int = 0
    @editable UIText1 : string = "Tracking "
    @editable UIText2 : string = " Players"
    var MaybeTimerUI : ?Timer = false

    # Init Powerup
    Init<public>(CP:CustomPlayer,CPMap:[agent]CustomPlayer,TimerUI:Timer)<suspends>:void=

        ThisA := CP.MyAgentObj
        FortArray := GetActiveFortCharacterArray(ThisA,CPMap)

        set MaybeTimerUI = option{TimerUI}
        TimerUI.ShowTimer()
        set TrackedPlayers = FortArray.Length
        UpdateUI()

        for(I:=0 .. FortArray.Length - 1):
            if(Fort := FortArray[I],Beacon := Beacons[I]):
                Print("Xray: Adding player to showlist")
                spawn . GlueBeaconToFort(Beacon,Fort) 
                Beacon.RemoveAllFromShowList()
                Beacon.AddToShowList(ThisA)

    UpdateUI<private>():void=
        if(TimerUI := MaybeTimerUI?):
            TimerUI.Update(UIText1 + "{TrackedPlayers}" + UIText2) 
            
    GlueBeaconToFort<private>(Beacon:beacon_device,F:fort_character)<suspends>:void=
        Beacon.Enable()
        race:
            StopEvent.Await()
            loop:
                Sleep(UpdateBeaconLocationDelay)
                if(not F.IsActive[]):
                    set TrackedPlayers -= 1
                    UpdateUI()
                    break
                else:
                    FortLocation := F.GetTransform().Translation
                    FortRotation := F.GetTransform().Rotation

                    FortVectors := vector3{X := FortLocation.X, Y := FortLocation.Y, Z := FortLocation.Z - 240.0}
                    Beacon.MoveTo(FortVectors, FortRotation, 0.1)
        Beacon.RemoveAllFromShowList()
        Beacon.Disable()
        Print("Loop Canceled")
        Print("Xray: Stoped tracking player")
        
    # Stop Powerup
    Delete<public>():void=
        Print("xray_power Deleted")
        StopEvent.Signal()
        for(Beacon:Beacons):
            Beacon.RemoveAllFromShowList()
            Beacon.Disable()
        

    GetActiveFortCharacterArray<private>(ThisA:agent,AllCPMap:[agent]CustomPlayer):[]fort_character=
        var Array : []fort_character = array{}
        for(Key -> Value : AllCPMap, Key <> ThisA):
            IsInLobby := Value.GetIsInLobby() 
            if(F:= Key.GetFortCharacter[]): #not IsInLobby?
                set Array += array{F}
            else:
                Print("Xray : failed to convert (player in lobby or not fort_character)")
        return Array

