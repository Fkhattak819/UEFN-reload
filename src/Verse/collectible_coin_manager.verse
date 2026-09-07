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
using { /Verse.org }
using { /Verse.org/Assets }


RangeTool := class<concrete>:
    @editable XRangeMin : float = -500.0
    @editable XRangeMax : float = 500.0
    @editable YRangeMin : float = -500.0
    @editable YRangeMax : float = 500.0

PowerType := enum:
    Normal
    Exotic
    Mythic

collectible_event := class:
    var Handlers : []type{_(:collectible):void} = array{}
 
    Subscribe(Handler : type{_(:collectible):void}):void =
        set Handlers += array{Handler}
 
    Signal(Value : collectible):void =
        for (Handler : Handlers):
            Handler(Value)

collectible := class<concrete><unique>():
    @editable PowerIndex : int = -1
    @editable Type : PowerType = PowerType.Normal
    @editable CollectibleDevice : collectible_object_device = collectible_object_device{}
    @editable CollectibleSFX : audio_player_device = audio_player_device{}
    StopEvent: event() = event(){}
    DespawnedEvent : collectible_event = collectible_event{}
    DespawnTime : float = 35.0

    DespawnCollectibleCheck()<suspends>:void=
        var SleepCompleted : logic = false
        race:
            block:
                Sleep(DespawnTime)
                set SleepCompleted = true
            StopEvent.Await()

        if (SleepCompleted = true):
            CollectibleDevice.Hide()
            DespawnedEvent.Signal(Self)
            
        set SleepCompleted = false


collectible_coin_manager := class<concrete>():

    @editable
    Collectibles : []collectible = array{}

    @editable
    MythicTimer : timer_device = timer_device{}

    @editable
    ExoticTimer : timer_device = timer_device{}

    @editable
    MythicHudMessageDevice : hud_message_device = hud_message_device{}

    @editable
    ExoticHudMessageDevice : hud_message_device = hud_message_device{}

    @editable
    XPCollectible : collectible_object_device = collectible_object_device{}

    @editable
    CollectedXP : accolades_device = accolades_device{}

    @editable 
    SkyCollectibleSFX : audio_player_device = audio_player_device{}


    @editable XPCoinDifficulty : int = 5
    @editable ExoticDifficulty : int = 3
    @editable SpawnBounds : RangeTool = RangeTool{}


    @editable 
    ZBarrier : float = 20000.0
    # ZBarrier : float = 2000.0
 
    Gravity : float = 980.0 # cm/s^2 (approximate gravity in Fortnite)
 
    UpdateRate : float = 0.05 # 60fps

    # Teleports the object to the player's location and makes it fall to the ground
    TeleportAndDrop(Agent : agent, Collectible : collectible) : void =
        var zOff : float = 0.0
        Print("Teleporting collectible to eliminated player")
        Collectible.CollectibleDevice.RespawnForAll()
        Collectible.CollectibleDevice.Show()
        if (Character := Agent.GetFortCharacter[]):
            # Get player's current position
            AgentTransform := Character.GetTransform()
            AgentLocation := AgentTransform.Translation

            if. Collectible.Type = PowerType.Exotic then. set zOff = 60.0
 
            # Teleport object to player's location
            NewZOffset := AgentLocation.Z + 120.0 + zOff
            if (Collectible.CollectibleDevice.TeleportTo[vector3{X := AgentLocation.X, Y := AgentLocation.Y, Z := NewZOffset}, rotation{}]):
                # Start gravity simulation
                if (NewZOffset > 3600.0):
                    spawn{SimulateGravity(Collectible, 3650.0)}

            spawn. Collectible.DespawnCollectibleCheck()

    # Teleports the xp collectible object to the player's location 
    TeleportXPCollectible(Agent : agent) : void =
        Print("Teleporting collectible to eliminated player")
        XPCollectible.RespawnForAll()
        XPCollectible.Show()
        if (Character := Agent.GetFortCharacter[]):
            # Get player's current position
            AgentTransform := Character.GetTransform()
            AgentLocation := AgentTransform.Translation
 
            # Teleport object to player's location
            NewZOffset := AgentLocation.Z + 100.0
            if (XPCollectible.TeleportTo[vector3{X := AgentLocation.X, Y := AgentLocation.Y, Z := NewZOffset}, rotation{}]) {}

    # Teleports the exotic or mythic collectible to the sky and makes it fall to the ground
    TeleportAndDropFromSky(Collectible : collectible) : void =
        var Zlevel : float = 3600.0
        Print("Teleporting collectible from the sky")
        Collectible.CollectibleDevice.RespawnForAll()
        Collectible.CollectibleDevice.Show()
        # Get random x and y pos
        RandomXPos := GetRandomFloat(SpawnBounds.XRangeMin, SpawnBounds.XRangeMax)
        RandomYPos := GetRandomFloat(SpawnBounds.YRangeMin, SpawnBounds.YRangeMax)

        if (Collectible.Type <> PowerType.Normal):
            SkyCollectibleSFX.Play()
            if(Collectible.Type = PowerType.Mythic):
                set Zlevel = 3800.0
                MythicHudMessageDevice.Show()
            else if (Collectible.Type = PowerType.Exotic):
                set Zlevel = 4000.0
                ExoticHudMessageDevice.Show()

    
        # Teleport object to the sky
        if (Collectible.CollectibleDevice.TeleportTo[vector3{X := RandomXPos, Y := RandomYPos, Z := ZBarrier}, rotation{}]):
            Print("Finished teleport")
            spawn{SimulateGravity(Collectible, Zlevel)}

 
    # Simulates gravity by moving the object down until it reaches z 
    SimulateGravity(Collectible : collectible, ZLevel : float)<suspends> : void =
        var CurrentTransform : transform = Collectible.CollectibleDevice.GetTransform()
        var CurrentLocation : vector3 = CurrentTransform.Translation
        Sleep(5.0)
        # Continue moving down until we reach ground level 
        race:
            Collectible.StopEvent.Await()
            loop:
                Sleep(0.0)
                if (CurrentLocation.Z <= ZLevel):
                    # Set final position at ground level
                    FinalLocation := vector3{X := CurrentLocation.X, Y := CurrentLocation.Y, Z := ZLevel}
                    if (Collectible.CollectibleDevice.TeleportTo[FinalLocation, CurrentTransform.Rotation]):
                        break
                    else:
                        break
    
                # Calculate new position with gravity
                NewZ := CurrentLocation.Z - (Gravity * UpdateRate)
                set CurrentLocation = vector3{X := CurrentLocation.X, Y := CurrentLocation.Y, Z := NewZ}
    
                # Update object position
                if (Collectible.CollectibleDevice.TeleportTo[CurrentLocation, CurrentTransform.Rotation]):
                    Sleep(UpdateRate)
                else:
                    break


    