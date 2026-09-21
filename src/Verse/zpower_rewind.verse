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

rewind_power := class<concrete>(power_base):

    @editable AbilityDuration : float = 15.0
    @editable AbilityCooldown : float = 30.0
    @editable AudioPlayer : audio_player_device = audio_player_device{}
    # Only one logic should be checked
    @editable PlayAudioOnlyForPowerUser : logic = false
    @editable PlayAudioAtLocation : logic = true
    @editable SpecialEffectsManager : special_effects_manager = special_effects_manager{}
    @editable VFXOffset : vector3 = vector3{}
    @editable Prop : creative_prop_asset = DefaultCreativePropAsset
    @editable TeleporterDevice : teleporter_device = teleporter_device{}
    StopEvent<private>: event() = event(){}  

    # Use Powerup
    ActivateAbility<public>(CP:CustomPlayer,TimerUI:Timer)<suspends>:void=
        A := CP.MyAgentObj
        # Smart way to do active and not active timers with your current system is to call this function without spawn and wait for it to finish
        # Once it finishes you start the cooldown timer
        Print("Rewind Respawn Activated")
        TeleporterDevice.Enable()
        AudioPlayer.Enable()
        AudioPlayer.Play(A)
        if(F:=A.GetFortCharacter[]):
            RespawnT := F.GetTransform()
            MaybeVFXProp := SpawnProp(Prop,RespawnT.Translation + VFXOffset,rotation{})(0)
            set TimerUI.IsActive = true # Making sure he cant use it again
            race:
                StopEvent.Await() # Stops the whole thing
                TimerUI.NewStartActiveCountdown(AbilityDuration) # Active cooldown UI
                loop:
                    Sleep(0.1)
                    Result := F.DamagedEvent().Await()
                    Amount := Result.Amount
                    Health := F.GetHealth()
                    if((Health - Amount) <= 0.0):
                        break
            Print("Loop Canceled")
                        
            if(TeleporterDevice.TeleportTo[RespawnT]) { TeleporterDevice.Teleport(A) }
            if(VFXProp := MaybeVFXProp?) { VFXProp.Dispose() }
            spawn . SpecialEffectsManager.BlinkingInvincibilityEffect(F) # suspends
            AudioPlayer.Stop()
            TimerUI.NewStartActiveCountdown(AbilityCooldown)
            #AudioPlayer.Reset()
            Sleep(1.0)
            SpecialEffectsManager.ResetSettings(F) # makes sure player is visible ...
            set TimerUI.IsActive = true # Ability over, he can use it again
        TeleporterDevice.Disable()
        AudioPlayer.Disable()