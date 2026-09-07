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


 <#
    All Minigames should have a emote to return to lobby function via HUD message device and mutatorzone
#>

minigame_base := class<concrete>():
    @editable TeleportHomeHudMessageDevice : hud_message_device = hud_message_device{}
    @editable GameTeleporter : teleporter_device = teleporter_device{}

    TeleportToMinigame(Agent : agent):void=
        GameTeleporter.Teleport(Agent)
        TeleportHomeHudMessageDevice.Show(Agent)

shark_minigame := class<concrete>(minigame_base):
    @editable GunChecker : conditional_button_device = conditional_button_device{}
    @editable UnlockWeaponTrigger : trigger_device = trigger_device{}
    <#
        Teleport a player to a fishing area
        Fill the fishing zone with stuff to make getting the actual gun hard to get
        Once they get it they must return home to shoot a trigger on the vending machine
        If the player is hold said weapon the switch unlocks and they can interact and get the gun
    #>

orca_minigame := class<concrete>(minigame_base):
    @editable UnlockButton : button_device = button_device{}
    <#
        Teleport a player to a area
        Rocketlauncher and selfguided missle on with item spawner
        They must rocket ride to the other side to a button that will unlock when they intract with it
    #>

vehicle_data := class<concrete>:
    @editable Vehicle<public> : vehicle_spawner_sports_car_device = vehicle_spawner_sports_car_device{}
    var IsAvailable<public> : logic = true

vehicle_minigame  := class(minigame_base):
    @editable VehicleDataArray : []vehicle_data = array{}
    @editable MutatorZoneStart : mutator_zone_device = mutator_zone_device{}
    @editable MutatorZoneFinish : mutator_zone_device = mutator_zone_device{}
    @editable FinishHUD : hud_message_device = hud_message_device{}
    @editable LookingForVehicleDelay : float = 0.5
    @editable UnlockButton : button_device = button_device{}
    @editable UnlockGunTeleporter : teleporter_device = teleporter_device{}
    
    <#
        Teleport a player to a car area
        Player must get to the bottom and when they enter the finsh zone, it will teleport them to a new room
        This new room will hold the unlockable button where they can unlock the secret
        This power still need altering to run all the time rn it stop and start like a box fight would
    #>

    StartMutatorEvents<public>():void=
        Print("VehicleManager: Enabled all vehicle events")
        spawn{InitMutatorEvents()}

    StopMutatorEvents<public>():void=
        Print("VehicleManager: Disabled all vehicle events")
        MutatorZoneFinish.Disable()
        MutatorZoneStart.Disable()

        # Added reset vehicles for safety
        ResetVehicles()

    ResetVehicles<private>():void=
        for(CurrentVehicleData : VehicleDataArray):
            CurrentVehicleData.Vehicle.DestroyVehicle()
            CurrentVehicleData.Vehicle.Disable()
            set CurrentVehicleData.IsAvailable = true
    
    InitMutatorEvents<private>()<suspends>:void=
        MutatorZoneStart.Enable()
        MutatorZoneFinish.Enable()
        loop:
            Sleep(0.1)
            AgentEnters := MutatorZoneStart.AgentEntersEvent.Await()
            spawn{SearchForAvailableVehicle(AgentEnters)}
                
        
    SearchForAvailableVehicle<private>(AgentEnters:agent)<suspends>:void=
        Print("VehicleManager: Agent entered Main mutator zone.")
        race:
            loop: # If agent exits the mutator zone
                Sleep(0.1)
                AgentExits := MutatorZoneStart.AgentExitsEvent.Await()
                if(AgentExits = AgentEnters):
                    Print("VehicleManager: Agent left mutator zone, cancelling search for available vehicle.")
                    break
            loop: # Searching for available vehicle
                Sleep(LookingForVehicleDelay)
                Print("VehicleManager: Searching for available vehicle.")
                MaybeAvailableVehicle := GetMaybeAvailableVehicle()
                if(AvailableVehicle := MaybeAvailableVehicle?):
                    Print("VehicleManager: Found available vehicle.")
                    spawn{ManageVehicleEvents(AgentEnters,AvailableVehicle)}
                    break

    ManageVehicleEvents<private>(Agent:agent,AvailableVehicle:vehicle_data)<suspends>:void=
        set AvailableVehicle.IsAvailable = false
        AvailableVehicle.Vehicle.Enable()
        AvailableVehicle.Vehicle.RespawnVehicle()
        AvailableVehicle.Vehicle.VehicleSpawnedEvent.Await()
        AvailableVehicle.Vehicle.AssignDriver(Agent)

        var ReachedFinish : logic = false

        race:
            AvailableVehicle.Vehicle.AgentExitsVehicleEvent.Await()# when agent exits vehicle
            loop: # If agent exits the mutator zone
                Sleep(0.1) 
                AgentExits := MutatorZoneStart.AgentExitsEvent.Await()
                if(AgentExits = Agent):
                    Print("VehicleManager: Agent failed to reach finish line.")
                    break
            loop:
                Sleep(0.1)
                AgentEnters := MutatorZoneFinish.AgentEntersEvent.Await()
                if(AgentEnters = Agent):
                    Print("VehicleManager: Agent reached finish line.")
                    set ReachedFinish = true
                    break

        AvailableVehicle.Vehicle.DestroyVehicle()
        AvailableVehicle.Vehicle.VehicleDestroyedEvent.Await()
        AvailableVehicle.Vehicle.Disable()
        set AvailableVehicle.IsAvailable = true
        # TeleportManager.AgentToLobby(Agent, false)

        # Do stuff to player that reached the finish line
        if(ReachedFinish?):
            Print("VehicleManager: Rewarding Agent.")
            FinishHUD.Show(Agent)
            UnlockGunTeleporter.Teleport(Agent)
        else:
            GameTeleporter.Teleport(Agent)

    GetMaybeAvailableVehicle<private>():?vehicle_data=
        var ReturnVehicle : ?vehicle_data = false
        for(CurrentVehicleData : VehicleDataArray,CurrentVehicleData.IsAvailable?):
            set ReturnVehicle = option{CurrentVehicleData}
            return ReturnVehicle
        return ReturnVehicle

minigame_manager := class<concrete>():

    @editable SharkGame : shark_minigame = shark_minigame{}

    @editable OrcaGame  : orca_minigame = orca_minigame{}

    @editable CarGame   : vehicle_minigame = vehicle_minigame{}



