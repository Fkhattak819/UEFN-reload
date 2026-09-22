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

revive_power := class<concrete>(power_base):
    
    @editable AbilityDuration : float = 15.0
    @editable AbilityCooldown : float = 30.0
    @editable SpecialEffectsManager : special_effects_manager = special_effects_manager{}
    @editable AudioPlayerDevice : audio_player_device = audio_player_device{}
    @editable RespawnVFX : creative_prop_asset = DefaultCreativePropAsset 
    @editable Cinematic : cinematic_sequence_device = cinematic_sequence_device{}
    @editable RefMover : creative_prop = creative_prop{} 
    @editable ExplosiveDevice : explosive_device = explosive_device{}
    @editable
    NinjaVFX : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable RefTrigger : trigger_device = trigger_device{}
    StopEvent<private>: event() = event(){}  
    var MaybeTimerUI : ?Timer = false
    @editable UIText : string = "Self Revive Ready"
    @editable UIText2 : string = "No More Revives"
    @editable PlayTime : float = 4.0

    UpdateUI<private>():void=
        if(TimerUI := MaybeTimerUI?):
            TimerUI.Update(UIText2) 

    # Init
    Init<public>(A:agent, TimerUI : Timer)<suspends>:void=
        set MaybeTimerUI = option{TimerUI}
        TimerUI.Update(UIText) 
        NinjaVFX.Pickup()
        if(F:=A.GetFortCharacter[]){spawn{ActivateAbility(A,F)}}

    # Stop Powerup
    Delete<public>():void=
        StopEvent.Signal()
        Print("Revive Player Deleted")

    # Use Powerup
    ActivateAbility<public>(A:agent,F:fort_character)<suspends>:void=
        race:
            StopEvent.Await()
            loop:
                Result := F.DamagedEvent().Await()
                Amount := Result.Amount
                Health := F.GetHealth()
                Print("Player damaged event")
                if((Health - Amount) <= 0.0):
                    RefTrigger.Trigger(A)
                    Cinematic.Play()
                    spawn. SpecialEffectsManager.InvisibleInvincibilityEffect(F)
                    Print("Player is about to die, applying invincibility")
                    F.PutInStasis(stasis_args{})
                    RevivePos := F.GetTransform().Translation
                    if(ExplosiveDevice.TeleportTo[RevivePos, rotation{}]){ExplosiveDevice.Explode(A)}
                    if(RefMover.TeleportTo[RevivePos, F.GetTransform().Rotation]){}
                    AudioPlayerDevice.Play(A)
                    
                    Sleep(PlayTime)
                    if(RefMover.TeleportTo[TeleAwayPos,rotation{}]){Print("Brought Animation Away")}
                    F.ReleaseFromStasis()
                    Sleep(0.1)
                    F.Show()
                    Sleep(0.1)
                    F.SetVulnerability(true)
                    UpdateUI()
                    break

        Print("Loop Canceled")
        SpecialEffectsManager.ResetSettings(F)
        ExplosiveDevice.Reset()