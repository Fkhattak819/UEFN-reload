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

time_travel_power := class<concrete>(power_base):

    @editable var Teleporter : teleporter_device  = teleporter_device {}
    @editable GatherPlayerInfoDelay : float = 0.25
    @editable AbilityCooldown : float = 20.0
    @editable AudioPlayer : audio_player_device = audio_player_device{}

    var PlayerInfoTuple : []tuple(vector3, rotation, float, float, float) = array{}
    StopEvent<private>: event() = event(){}

    # Start Powerup
    Init<public>(InAgent:agent):void=
        if(Fort:=InAgent.GetFortCharacter[]):
            spawn{ActivateFutureDataCollection(Fort)}

    # Stop/Reset Powerup
    Delete<public>():void=
        StopEvent.Signal()
        Teleporter.Disable()
        #EmptyPlayerInfoTuple : []tuple(vector3, rotation, float, float, float) = array{}
        set PlayerInfoTuple = array{}
        Print("Time Travel Deleted")

    # Use power
    ActivatePowerup<public>(Agent:agent)<suspends>:void=
        Teleporter.Enable()
        if(Fort := Agent.GetFortCharacter[], FutureInfo := PlayerInfoTuple[0]):
            Fort.SetHealth(FutureInfo(2))
            Fort.SetShield(FutureInfo(3))
            if(Teleporter.TeleportTo[FutureInfo(0), FutureInfo(1)]){Teleporter.Teleport(Agent)}
            AudioPlayer.Play(Agent)
        Teleporter.Disable()

    # Gather info
    ActivateFutureDataCollection<private>(Fort : fort_character)<suspends>:void=
        Print("Activating Time Travel data collection")
        var Time : float = 0.0
        if(Fort.IsActive[]):
            race:
                StopEvent.Await()
                loop:
                    if(Fort.IsActive[]):
                        NewTuple := (Fort.GetTransform().Translation,Fort.GetTransform().Rotation,Fort.GetHealth(),Fort.GetShield(),Time)
                        set PlayerInfoTuple += array {NewTuple}
                        if(PlayerInfoTuple.Length - 1 = 20): # 20x 1/4 = 5 -> 5 seconds back in time
                            if (NewArray := PlayerInfoTuple.RemoveElement[0]):
                                set PlayerInfoTuple = NewArray
                        set Time += GatherPlayerInfoDelay
                        Sleep(GatherPlayerInfoDelay)
                    else:
                        break
        else:
            return