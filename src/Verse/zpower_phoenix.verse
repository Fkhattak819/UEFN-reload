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

phoenix_power := class<concrete>(power_base):

    @editable
    FireVolume : fire_volume_device = fire_volume_device{}

    @editable
    FireHolder : creative_prop = creative_prop{}

    @editable
    ItemGranter : item_granter_device = item_granter_device{}

    Init(Agent : agent):void=
        ItemGranter.GrantItem(Agent)

    ActivateAbility(Agent : agent, TargetAgent : agent)<suspends>:void=
        if:
            FortChar : fort_character = TargetAgent.GetFortCharacter[]
            TargetLocation := FortChar.GetTransform()
        then:
            FireHolder.MoveTo(TargetLocation.Translation, rotation{}, 0.1)
            Print("Activate Phoenix Ability")
            FireVolume.Ignite()
            Sleep(5.0)
            # FireVolume.Extinguish()
            
            if (FireHolder.TeleportTo[TeleAwayPos, TargetLocation.Rotation]){}
