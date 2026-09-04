using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /Verse.org/Colors }
using { /Verse.org/Assets }
using { /Verse.org }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }


# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level

# One row per secret-weapon config
               

CustomPlayer := class<unique>():
    MyAgentObj : agent
    SecretWeapons : []secret_weapon
    PinpadTriggers : []pinpad_trigger_data
    ResetCustomWeaponVFX : visual_effect_powerup_device

    var PowerUp: int = -1
    var IsInLobby : logic = false

    # ---- SECRET WEAPON STATE ----
    var HasCustomWeaponVFX : [int]logic = map{}
    var CustomWeaponVFXLoopActive : logic = false
    var CurrentWeaponID : int = -1

    #Gun Order
    #Chimp Gun - Six Shooter | Has Animation
    #Croc Gun - Purple Scar  | Has Animation
    #Deer Gun - Blue Pistol  | Has Animation
    #Elephant Gun - Heavy Shot Gun 
    #Shark Gun - Combat Shotgun | Has Animation
    #Orca Gun - Quad Launcher | Shoots Out Orca Prop

    AttachCustomWeaponVFX()<suspends>:void=
        set CustomWeaponVFXLoopActive = true
        Print("Starting Custom Weapon VFX Loop")
        loop:
            Sleep(0.1)
            if (Player := player[MyAgentObj], Player.IsActive[]):
                var WeaponId : int = -1
                var FoundWeapon : logic = false
                for(Index -> Weapon : SecretWeapons, not FoundWeapon?):
                    if (Weapon.Checker.IsHoldingItem[MyAgentObj]):
                        set WeaponId = Index
                        set FoundWeapon = true

                if (WeaponId > -1):
                    if (Switch := PinpadTriggers[WeaponId].Switch, Switch.GetCurrentState[MyAgentObj], Weapon := SecretWeapons[WeaponId]):
                        # only trigger if they just picked it up
                        if (HasVFX := HasCustomWeaponVFX[WeaponId], not HasVFX?):
                            Print("Attaching VFX")
                            if (CurrentWeaponID > -1, set HasCustomWeaponVFX[CurrentWeaponID] = false) {Print("Set previous flag to true")}
                            set CurrentWeaponID = WeaponId
                            if (set HasCustomWeaponVFX[WeaponId] = true) {Print("Set new flag to true")}
                            Weapon.VFX.Pickup(MyAgentObj)
                        else:
                            # Print("Already has vfx attached, CurrentWeaponID = {CurrentWeaponID}")
                else:
                    # reset the flag once they’re not holding anymore
                    if (CurrentWeaponID > -1, HasVFX := HasCustomWeaponVFX[CurrentWeaponID], HasVFX?):
                        Print("Removing VFX")
                        ResetCustomWeaponVFX.Pickup(MyAgentObj)
                        if (set HasCustomWeaponVFX[CurrentWeaponID] = false) {Print("Set flag to false")}
                        set CurrentWeaponID = -1
                    else:
                        # Print("Not holding any weapon, already removed vfx, CurrentWeaponID = {CurrentWeaponID}")
            else:
                break
        Print("Ending Custom Weapon VFX Loop")
        set CustomWeaponVFXLoopActive = false

    # ---- SECRET WEAPON STATE ----
    
    CancelRemoteEvent<public> : event() = event(){}

    var IsInPracticeZone : logic = false
    var IsRespawning : logic = false

    SetIsInLobby(Lobby : logic):void=
        set IsInLobby = Lobby

    GetIsInLobby():logic=
        return IsInLobby

    SetPowerUp(PU : int):void=
        set PowerUp = PU

    GetPowerUp():int=
        return PowerUp

    HasPowerUp<public>()<decides><transacts>:void=
        PowerUp > 0

    RemovePowerUp():void=
        set PowerUp = -1

    
#------------------------------------------------------------------

