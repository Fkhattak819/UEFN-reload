
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }

teleport_manager := class(creative_device):

    @editable LobbyMapController : map_controller_device = map_controller_device{}
    @editable LobbyTeleporter : teleporter_device = teleporter_device{}
    @editable LobbyProps : []creative_prop = array{}
    @editable TeleportOffset : vector3 = vector3{X:=0.0,Y:=0.0,Z:=50.0}
    @editable SecretWeaponPanelLocation : vector3 = vector3{X:=-1040.0,Y:=168.0,Z:=4392.0}
    @editable DefaultMod : movement_modulator_device = movement_modulator_device{}

    var SpawnCount : int = 0

    # When game is reseting
    AgentsToLobby<public>(CustomPlayers:[agent]CustomPlayer):void=
        Print("Teleporting all players to Lobby")
        set SpawnCount = 0
        ShuffledProps := Shuffle(LobbyProps)
        var I : int = 0
        for(Key -> Value : CustomPlayers, not Value.IsRespawning?):
            LobbyMapController.Activate(Key)
            if(Prop := ShuffledProps[I]):
                Pos := Prop.GetTransform()
                if(LobbyTeleporter.TeleportTo[Pos]):
                    LobbyTeleporter.Teleport(Key)
                    set I += 1

    AgentToLobby<public>(Agent:agent):void=
        Print("Teleporting player to lobby")
        LobbyMapController.Activate(Agent)
        if(Index := Mod[SpawnCount, 12], Prop := LobbyProps[Index]):
            Print("Spawn Count is {SpawnCount}, LobbyProp Index is {Index}")
            Pos := Prop.GetTransform()
            if(LobbyTeleporter.TeleportTo[Pos]):
                LobbyTeleporter.Teleport(Agent)
            DefaultMod.Activate(Agent)
        set SpawnCount += 1

    AgentToSecretWeaponPanel<public>(Agent:agent):void=
        if(LobbyTeleporter.TeleportTo[SecretWeaponPanelLocation, rotation{}]):
            LobbyTeleporter.Teleport(Agent)
