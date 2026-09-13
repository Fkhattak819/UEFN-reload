
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

creeper_power := class<concrete>(power_base):

    @editable
    ExplosiveDevice : explosive_device = explosive_device{}

    @editable
    ExplosiveDeviceTrigger : trigger_device = trigger_device{}

    @editable
    CreeperSFXExplode : audio_player_device = audio_player_device{}

    @editable 
    Prop : creative_prop = creative_prop{}

    @editable
    CreeperHeadVFX : visual_effect_powerup_device = visual_effect_powerup_device{}

    @editable 
    AbilityTime : float = 15.0

    @editable 
    AbilityCooldown : float = 30.0

    StopEvent<private> : event() = event(){}

    Delete<public>():void=
        StopEvent.Signal()
        
    ActivateAbility<public>(A:agent)<suspends>:void=
        ExplosiveDevice.Reset()
        CreeperSFXExplode.Play(A)
        if(F:=A.GetFortCharacter[]):
            F.Hide()
            race: # ends when
                StopEvent.Await() # game ends or player dies
                Sleep(AbilityTime) # If he does not explode within the ability time, the ability ends
                loop: # updates the ability
                    InitalT := F.GetTransform().Translation
                    InitalR := F.GetTransform().Rotation
                    Prop.MoveTo(InitalT,InitalR, 0.1)

            Print("Creeper Explosive Done")

            ExplosiveDevice.Explode(A)

            # Cleanup
            if(Prop.TeleportTo[TeleAwayPos, rotation{}],ExplosiveDevice.TeleportTo[TeleAwayPos,rotation{}]){Print("Returned creeper prop and explosive device to orginal spot")}
            F.Show()