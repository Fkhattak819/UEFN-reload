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

electric_power := class<concrete>(power_base):
    
    @editable
    MovementModulator : movement_modulator_device = movement_modulator_device{}

    @editable
    AudioPlayer : audio_player_device = audio_player_device{}

    Init(Agent : agent):void=
        MovementModulator.Activate(Agent)
    
    ActivateAbility(TargetFort : fort_character)<suspends>:void=
        TargetFort.PutInStasis(stasis_args{})
        if(Agent := TargetFort.GetAgent[]):
            AudioPlayer.Play(Agent)
        Sleep(0.3)
        TargetFort.ReleaseFromStasis()
        TargetFort.Show()