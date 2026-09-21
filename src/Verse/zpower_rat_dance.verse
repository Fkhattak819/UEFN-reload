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

dance_power := class<concrete>(power_base):

    var MaybePlayspace : ?fort_playspace = false
    
    @editable
    Mover : creative_prop = creative_prop{}

    @editable
    DBP : creative_prop = creative_prop{}

    @editable
    DSFX : audio_player_device = audio_player_device{}

    @editable
    DBomb : explosive_device = explosive_device{}

    @editable
    ItemGranter : item_granter_device = item_granter_device{}

    @editable
    ItemChecker : conditional_button_device = conditional_button_device{}

    @editable
    AbilityCooldown : float = 20.0


    ActivateAbility(Agent : agent, TargetFort : fort_character)<suspends>:void=
        if:
            ItemChecker.IsHoldingItem[Agent]
            InstigatorFC : fort_character = Agent.GetFortCharacter[]
            TargetAgent : agent = TargetFort.GetAgent[]
            Location := TargetFort.GetTransform()
            Mover.TeleportTo[Location]
        then:
            DBomb.Explode(Agent)
            DSFX.Play(TargetAgent)
            DBP.Show()
            TargetFort.PutInStasis(stasis_args{})
            TargetFort.SetVulnerability(false)
            TargetFort.Hide()
            spawn:
                HideGatorTiming(TargetAgent)
            Sleep(5.5)
            TargetFort.Show()
            TargetFort.SetVulnerability(true)
            Mover.MoveTo(TeleAwayPos, rotation{}, 0.01)
            TargetFort.ReleaseFromStasis()
            DSFX.Stop(Agent)
            DBomb.Reset()
            Sleep(2.0)
            DBP.Show()

    HideGatorTiming(Agent : agent)<suspends>:void=
        Sleep(4.9)
        DBP.Hide()
        Sleep(0.5)



