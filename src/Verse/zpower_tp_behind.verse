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

tp_behind_power := class<concrete>(remote_power_base):

    var MaybePlayspace : ?fort_playspace = false

    OutOfBoundsManager : out_of_bounds_manager = out_of_bounds_manager{}

    @editable
    BehindTeleporter : teleporter_device = teleporter_device{}

    @editable
    TeleportBehindSFX : audio_player_device = audio_player_device{}

    @editable AbilityCooldown : float = 15.0

    Delete<public>():void=
        BreakPlayerViewLoop()

    OnTeleportPower(CP: CustomPlayer, CPMap: [agent]CustomPlayer)<suspends>:void=
        MaybePlayerInView := GetPlayerInView()
        var MaybeOtherAgent : ?agent = false
        if:
            Print("GOT PLAYER IN VIEW")
            MaybePlayerInView?
            set MaybeOtherAgent = option. agent[MaybePlayerInView?]
        else:
            Print("GOT CLOSEST PLAYER")
            set MaybeOtherAgent = FindClosestMaybeAgent(CP, CPMap)
        if (TargetAgent := MaybeOtherAgent?):
            if(FC := TargetAgent.GetFortCharacter[]):
                Print("Teleporting Behind Enemy")
                Pos : vector3 = FC.GetTransform().Translation
                Rotation : rotation = FC.GetTransform().Rotation
                Offset : vector3 = Rotation.RotateVector(vector3{X:=-100.0, Y:=0.0, Z:=10.0})
                Destination : vector3 = Pos + Offset
                PlayerRefDestination : vector3 = Pos

                # Added out of bounds checking
                # VerifiedDestination := OutOfBoundsManager.Check(Destination)
                
                if (BehindTeleporter.TeleportTo[PlayerRefDestination, Rotation]):
                    Print("Teleported Behind Enemy")
                    TeleportBehindSFX.Play(TargetAgent)
                    BehindTeleporter.Teleport(CP.MyAgentObj)
                    