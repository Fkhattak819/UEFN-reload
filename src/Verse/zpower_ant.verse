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

ant_power := class<concrete>(power_base):

    @editable Props : []creative_prop = array{}
    # @editable WearableVFX : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable Teleporter : teleporter_device = teleporter_device{}
    @editable UpdatePropLocationDelay : float = 0.1
    @editable AbilityCooldown : float = 15.0
    @editable AbilityDuration : float = 10.0

    StopEvent<private>: event() = event(){}
    var TrackedPlayers : int = 0

    ActivatePowerup(CP : CustomPlayer, CPMap:[agent]CustomPlayer)<suspends>:void=
        Agent := CP.MyAgentObj
        if(FC := Agent.GetFortCharacter[]):
            FortLocation := FC.GetTransform().Translation
            FortRotation := FC.GetTransform().Rotation
            FortVectors := vector3{X := FortLocation.X, Y := FortLocation.Y, Z := 3100.0}

            Teleporter.MoveTo(FortVectors, rotation{}, 0.1)
            Teleporter.Teleport(Agent)
            FortArray := GetActiveFortCharacterArray(Agent,CPMap)
            set TrackedPlayers = FortArray.Length

            for(I:=0 .. FortArray.Length - 1):
                if(Fort := FortArray[I],Prop := Props[I]):
                    Print("Xray: Adding player to showlist")
                    spawn. GluePropToFort(Prop,Fort) 

            Sleep(AbilityDuration)
            spawn. TeleportToAgentToClosestPlayer(CP, CPMap)
         
    GluePropToFort<private>(Prop:creative_prop,F:fort_character)<suspends>:void=
        race:
            StopEvent.Await()
            Sleep(AbilityDuration)
            loop:
                Sleep(UpdatePropLocationDelay)
                if(not F.IsActive[]):
                    set TrackedPlayers -= 1
                    break
                else:
                    FortLocation := F.GetTransform().Translation
                    FortRotation := F.GetTransform().Rotation

                    FortVectors := vector3{X := FortLocation.X, Y := FortLocation.Y, Z := -40.0}
                    Prop.MoveTo(FortVectors, FortRotation, 0.1)

        Prop.MoveTo(TeleAwayPos, rotation{}, 0.1)
        Print("Loop Cancelled")

    TeleportToAgentToClosestPlayer(CP : CustomPlayer, CPMap : [agent]CustomPlayer)<suspends>:void=
        Closest := FindClosestMaybeAgent(CP, CPMap)
        if(ClosestAgent := Closest?, ClosestFC := ClosestAgent.GetFortCharacter[]):
            ClosestFCLocation := ClosestFC.GetTransform().Translation
            ClosestFCVectors := vector3{X := ClosestFCLocation.X - 70.0, Y := ClosestFCLocation.Y, Z := ClosestFCLocation.Z}
            Teleporter.MoveTo(ClosestFCVectors, rotation{}, 0.1)
            Teleporter.Teleport(CP.MyAgentObj)
        else:
            if (FC := CP.MyAgentObj.GetFortCharacter[]):
                Teleporter.MoveTo(vector3{X := FC.GetTransform().Translation.X, Y := FC.GetTransform().Translation.Y, Z := FC.GetTransform().Translation.Z + 300.0}, rotation{}, 0.1)
                Teleporter.Teleport(CP.MyAgentObj)

    # Stop Powerup
    Delete<public>():void=
        Print("xray_power Deleted")
        StopEvent.Signal()
        for(Prop:Props):
            spawn. Prop.MoveTo(TeleAwayPos, rotation{}, 0.1)

    GetActiveFortCharacterArray<private>(ThisA:agent,AllCPMap:[agent]CustomPlayer):[]fort_character=
        var Array : []fort_character = array{}
        for(Key -> Value : AllCPMap, Key <> ThisA, not Value.IsInLobby?):
            if(F:= Key.GetFortCharacter[]): #not IsInLobby?
                set Array += array{F}
            else:
                Print("Xray : failed to convert (player in lobby or not fort_character)")
        return Array

