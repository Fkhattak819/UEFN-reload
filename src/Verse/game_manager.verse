using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Assets }
using { /Verse.org/Random }
using { /Verse.org/Colors/NamedColors }
using { /Fortnite.com/Characters }
using { /Verse.org/Colors }
using { /Fortnite.com/Game }
using { /Fortnite.com/FortPlayerUtilities }
using { /Fortnite.com/Playspaces }
using { /Verse.org }
using { /Verse.org/Simulation/Tags }


actor_tag := class(tag):

S2M<localizes>(S : string): message = "{S}"

LeaderBoardString<localizes>(A : agent, S : string): message = "{A}{S}"
StatsMessage<localizes>(Kills:int, Deaths:int,Elo:int,KD:string):message = "Kills: {Kills}\nDeaths: {Deaths}\nElo: {Elo}\nKD: {KD}"

P2M<localizes>(A : agent): message = "{S}"

<# MADE BY

# ███████╗██╗  ██╗██████╗ ██████╗ ███████╗██████╗ ██╗ ██████╗████████╗██╗ ██████╗ ███╗   ██╗███████╗
# ██╔════╝╚██╗██╔╝██╔══██╗██╔══██╗██╔════╝██╔══██╗██║██╔════╝╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝
# █████╗   ╚███╔╝ ██████╔╝██████╔╝█████╗  ██║  ██║██║██║        ██║   ██║██║   ██║██╔██╗ ██║███████╗
# ██╔══╝   ██╔██╗ ██╔═══╝ ██╔══██╗██╔══╝  ██║  ██║██║██║        ██║   ██║██║   ██║██║╚██╗██║╚════██║
# ██║     ██╔╝ ██╗██║     ██║  ██║███████╗██████╔╝██║╚██████╗   ██║   ██║╚██████╔╝██║ ╚████║███████║
# ╚═╝     ╚═╝  ╚═╝╚═╝     ╚═╝  ╚═╝╚══════╝╚═════╝ ╚═╝ ╚═════╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝
                                                                                                  
#>

custom_game_action_causer := class(game_action_causer) {}

pinpad_trigger_data := class<concrete>:
    @editable Button : button_device = button_device{}
    @editable Switch : switch_device = switch_device{}
    @editable ItemGranter : item_granter_device = item_granter_device{}

xp_button_data := class<concrete>:
    @editable Button : button_device = button_device{}
    @editable Price : int = 0
    @editable AccoladeDevice : accolades_device = accolades_device{}

game_manager := class(creative_device):

    var PlayersMap : [agent]CustomPlayer = map{}
    var AgentMap : [agent]agent_data = map{}
    var TimerMap : [agent]Timer = map{}
    var NukeChosen : logic = false
    @editable PowerManager : power_manager = power_manager{}
    @editable CollectibleCoinManager : collectible_coin_manager = collectible_coin_manager{}
    @editable PinpadTriggers : []pinpad_trigger_data = array{}
    @editable SecretWeapons : []secret_weapon = array{}
    @editable StatBoardManager : stat_table_device = stat_table_device{}
    @editable MinigameManager : minigame_manager = minigame_manager{}
    # @editable TeamManager : team_manager = team_manager{}
    @editable TeleportManager : teleport_manager = teleport_manager{}
    var PlayerStatsManager : player_stats_manager = player_stats_manager{}

    @editable EndGameDevice : end_game_device = end_game_device{}
    
    var PlayersInBoxFight : int = 0
    var HudMessageIDArray : []int = array{}

    @editable
    RemoteRemover : item_remover_device = item_remover_device{}

    @editable
    PlayerSpawners : []player_spawner_device = array{}

    @editable
    GameCircleCenterProp : creative_prop = creative_prop{}

    @editable
    GameCircleRadius : float = 1500.0

    @editable
    ClearUI : hud_message_device = hud_message_device{}

    @editable
    StartGameTrigger : trigger_device = trigger_device{}
    
    @editable
    SafeZone1 : basic_storm_controller_device = basic_storm_controller_device{}

    @editable
    SafeZone2 : basic_storm_controller_device = basic_storm_controller_device{}

    @editable DeathVFXs : []creative_prop_asset = array{} 

    @editable
    ResetAllVFX : visual_effect_powerup_device = visual_effect_powerup_device{}

    @editable
    ResetAllVFX2 : visual_effect_powerup_device = visual_effect_powerup_device{}

    @editable
    ResetCustomWeaponVFX : visual_effect_powerup_device = visual_effect_powerup_device{}
    
    @editable
    ResetInventoryItemRemover : item_remover_device = item_remover_device{}

    @editable
    ResetBuildsExplosiveDevice : explosive_device = explosive_device{}

    @editable
    ResetBuildsExplosiveDevice2 : explosive_device = explosive_device{}

    @editable
    ResetBuildsExplosiveDevice3 : explosive_device = explosive_device{}
    
    @editable
    ResetBuildsExplosiveDevice4 : explosive_device = explosive_device{}

    @editable
    GoldRemote : signal_remote_manager_device = signal_remote_manager_device{}

    @editable EliminatedItemsDropSpawner : item_spawner_device = item_spawner_device{}
    @editable EliminatedItemsDropMover : creative_prop = creative_prop{}
    @editable RemoteGranter : item_granter_device = item_granter_device{}
    @editable ARGranter : item_granter_device = item_granter_device{}
    @editable ShotgunGranter : item_granter_device = item_granter_device{}
    @editable SMGGranter : item_granter_device = item_granter_device{}
    @editable HealsGranter : item_granter_device = item_granter_device{}
    @editable UtilsGranter : item_granter_device = item_granter_device{}
    @editable ClearInventory : item_remover_device = item_remover_device{}

    @editable
    DeathHUD : hud_message_device = hud_message_device{}

    @editable CustomElimSFX : []audio_player_device = array{}

    @editable
    ResetBuildsExplosiveDeviceTrigger : trigger_device = trigger_device{}

    @editable
    DefaultClass : class_and_team_selector_device = class_and_team_selector_device{}

    @editable
    XPCollectable : []collectible_object_device = array{}

    @editable
    CollectableAccolade : accolades_device = accolades_device{}

    @editable
    RespawnTrigger : trigger_device = trigger_device{}

    @editable CoinTag : actor_tag = actor_tag{}
    @editable VeryLargeAccolade : accolades_device = accolades_device{}

    # Custom Cooldown
    var CustomTimer : Timer = Timer{}
    var DeathCounter : int = 0

#---------------------------------------------------------------------------------------------------------------------
 
    @editable
    DebugButton : button_device = button_device{}
    @editable
    DebugAvaliablePowersButton : button_device = button_device{}
    @editable
    DebugUsedPowerButton : button_device = button_device{}

    # --- Single source of truth ---
    var PowerCatalog : [int]PowerType = map{} # id -> type
    
    var ExoticPowersList : []int = array{}
    var MythicPowersList : []int = array{}
    var AvailablePowerUps : []int = array{}
    var AvailableMythicPowers : []int = array{}
    var AvailableExoticPowers : []int = array{}

    var UsedPowers : []int = array{}
    var UsedMythicPowers : []int = array{}
    var UsedExoticPowers : []int = array{}

    PULL               : int = 1   #RIZZLER - Use Pistol To Pull People In                                            #3DDONE POWERDONE
    ONESHOT            : int = 2   #TUN SAHUR - Use Bat To One Shot Enemies                                           #3DDONE POWERDONE
    TELEPORT_BEHIND    : int = 3   #TIM CHEESE -Point Remote At Enemy \n Teleport Behind Them                         #3DDONE POWERDONE
    FREEZE             : int = 4   #LOS TRALALERITOES -Use Pistol To Freeze Enemies                                   #3DDONE POWERDONE
    FLOOD              : int = 5   #ORCALERO ORCALALA- Point Remote At Enemy \n Flood Them With Water                 #3DDONE POWERDONE
    AURA               : int = 6   #GOKU - Aura Slows Enemies Around You                                              #3DDONE POWERDONE
    INVIS              : int = 7   #GRAIPUSS MEDUSSI - Hold Card To Go Invisible                                      #3DDONE POWERDONE
    TIME_TRAVEL        : int = 8   #DOGE - Use Remote To Teleport Back In Time                                        #3DDONE POWERDONE
    REWIND             : int = 9   #BONNECA AMBALUBU -  Use Remote \n Place Down Respawn Tire                         #3DDONE POWERDONE
    BULL               : int = 10  #LA VACCA SATURNO - Charge Through Builds And Destroy Them                         #3DDONE POWERDONE
    
    BACKSTAB           : int = 11  #MINION - Take Reduced Damage From Behind                                          #3DDONE POWERDONE
    LIFESTEAL          : int = 12  #GANGSTER FOOTERA - Steal Shield And Health From Enemies                           #3DDONE POWERDONE
    ASTRONAUT          : int = 13  #MORDEKAI - High Jump \n Deal More Damage In Air                                   #3DDONE POWERDONE
    KNOCKBACK          : int = 14  #CAPCHINO ASSACINO - Bullets Cause Strong Knockback                                #3DDONE POWERDONE
    CIRCLE_BOMBS       : int = 15  #GEGE NUGGET- Shoot Nuggets In All Directions                                      #3DDONE POWERDONE
    XRAY               : int = 16  #ANONYMOUS - See enemies through walls                                             #3DDONE POWERDONE                             
    AGILITY            : int = 17  #PIPI POTATOE - Move Faster And Deal More Damage When Crouched                     #3DDONE POWERDONE
    DANCE              : int = 18  #BALLERINA CAPPUCCINO - Store Health And Damage When Dancing                       #3DDONE POWERDONE
    SUPERCHARGED       : int = 19  #LIRILI LARILA - Charge Up Damage Taken And Unleash It                             #3DDONE POWERDONE
    SELFREVIVE         : int = 20  #MASSIVE - Get Revived By Ninja When Dead                                          #3DDONE POWERDONE

    IMMUNE             : int = 21  #ODIN ODIN - Temporary Invulnerability When Damaged                                #3DDONE POWERDONE
    FASTERDAMAGE       : int = 22  #SONIC - Move Faster With More Damage                                              #3DDONE POWERDONE
    SNAP               : int = 23  #GARAMA MADUNDUNG  - Use Remote \n Eliminate half the lobby                        #3DDONE POWERDONE              
    BUSH               : int = 24  #BRR BRR PATAPIM - Use Remote \n Place Down And Heal In A Bush                     #3DDONE POWERDONE
    AIMBOT             : int = 25  #CHAD PEPE - Spam Crouch To Enable Aimbot                                          #3DDONE POWERDONE
    FLY                : int = 26  #FLURI FLURA - Double jump to fly                                                  #3DDONE POWERDONE
    ANT                : int = 27  #AMONG US - Use Remote \n Vent Underground And Teleport Up                         #3DDONE POWERDONE                  
    ELECTRIC           : int = 28  #MANGO - Faster \n Bullets Stun Enemies                                            #3DDONE POWERDONE
    VOLLEY_BOMBS       : int = 29  #SIVINIA BOMBONDINO - Use Remote \n Shoot Out a Volley Of Bombs                    #3DDONE POWERDONE                  
    SPIDEY             : int = 30  #SPIDEY - Enables Double Jump                                                      #3DDONE POWERDONE

    # BOUNTY_HUNTER      : int = 31  #JOHN WICK - Hunt Down Your Bounty For Ice Cream                                             HOLD OFF
    CHAR               : int = 32  #SKIBIDI - OG Unbeatable Brainrot                                                  #3DDONE POWERDONE                                      
    CHAIRPULL          : int = 33  #FISHINI BOSSINI - Point Remote At Enemy \n Pull People In With A Chair            #3DDONE POWERDONE
    FINISHER2          : int = 34  #GORILLIO WATERMELLODRILLO - Extra Health, Damage \n Less Speed                    #3DDONE POWERDONE
    FINISHER3          : int = 35  #BRAIN ROT GOD - Teleport Three People In Front Of You                             #3DDONE POWERDONE
    MISSILE            : int = 36  #BOMBADINO CROCODILO - Use Remote \n Become A Brainrot Plane                       #3DDONE POWERDONE
    ENGLISH_OR_SPANISH : int = 37  #ENGLISH_OR_SPAN - Use Remote \n Whoever Moves First Is Dead                       #3DDONE POWERDONE
    CREEPER            : int = 38  #CREEPER - Use Remote \n Turn Into A Creeper And Explode Near Enemies              #3DDONE
    CHAR2              : int = 39  #CHIMPANZINI BANANININI - Become Chimpanzini Bananini                              #3DDONE
    JUMPSCARE          : int = 40  #FREDDY - Point Remote At Enemy \n Activate Jumpscare                              #3DDONE 

    BLIND              : int = 41  #BAG HEAD - Use Pistol To Blind Enemies With A Bag                                 #3DDONE
    PHONE_CALL_MUL     : int = 42  #DAWG  - Let Me Know… Let Me Know…                                                 #3DDONE
    PROPFOLLOW         : int = 43  #JOB JOB SAHUR - Point Remote At Enemy \n J*b App Chases Enemy                     #3DDONE
    SHOOT_PROP         : int = 44  #ANGRY BIRD -  Use Remote \n Shoot Out An Angry Bird                               #3DDONE   HOLD OFF
    RAT_DANCE          : int = 45  #RAT DANCE - Use Pistol To Force Enemies To Rat Dance                              #3DDONE
    SALSA_ANIMATION       : int = 46  #SALSA - Use Pistol To Force Enemies To Summer Emote                                     
    WINTERARC_ANIMATION   : int = 47  #WINTER ARC - Use Pistol \n This Is For My Winter Arc                                
    SLAP_COMP_ANIMATION   : int = 48  #SLAP COMP - Use Pistol \n Slap Of Doom                                                   HOLD OFF
    MUSTARD_ANIMATION     : int = 49  #MUSTARD - Use Pistol \n MUSTARD!!!!!                                           #3DDONE
    SIXSEVEN_ANIMATION    : int = 50  #6 7 - Use Pistol \n Six, Seven!!!                                              #3DDONE   

    SUI_ANIMATION         : int = 51  #ROLANDO - Sui Animation After Everykill                                                  HOLD OFF
    KID_ON_BOAT_ANIMATION : int = 52  #BOAT KID - Use Pistol \n Force Enemies On A Boat                                         HOLD OFF
    ONE_POUND_FISH_ANIMATION: int = 53 #ONE POUND FISH - Use Pistol \n On Pound Fish Animation                                  HOLD OFF
    TRANSFORM          : int = 54      #TRALALERO TRALALA - Use Pistol \n Force Enemy To Become Brainrot              #3DDONE

    #Secret Powers
    SQUIDGIRL : int = 102 #NOT USING

    BANANA_GUN_INDEX : int = 0
    CROC_GUN_INDEX : int = 1
    DEER_GUN_INDEX : int = 2
    ELEPHANT_GUN_INDEX : int = 3
    SHARK_GUN_INDEX : int = 5
    ORCA_GUN_INDEX : int = 6
    BIKE_GUN_INDEX : int = 7

    ReassignPower(Agent : agent, NewPower : int):void=
        if(CP := PlayersMap[Agent], CTimer := TimerMap[Agent]):
            RemovePower(CP)
            ReturnCurrentPowerToPools(CP)
            AssignPowerup(Agent, NewPower)

    OnCoinCollected(Agent : agent):void=
        VeryLargeAccolade.Award(Agent)

    OnBegin<override>()<suspends>:void=
        InitPowerCatalog()
        RebuildPoolsFromCatalog()

        set PowerManager.TPBehindPower.MaybePlayspace = option{GetPlayspace()}
        set PowerManager.FloodPower.MaybePlayspace = option{GetPlayspace()}

        for(Collectable : XPCollectable):
            Collectable.CollectedEvent.Subscribe(AwardXpCollectable)

        # AwardCoins := Self.FindCreativeObjectsWithTag(CoinTag)
        # for(Coin : AwardCoins, CoinItem := collectible_object_device[Coin]):
        #     CoinItem.CollectedEvent.Subscribe(OnCoinCollected)

        DebugAvaliablePowersButton.InteractedWithEvent.Subscribe(DisplayPowers)
        DebugUsedPowerButton.InteractedWithEvent.Subscribe(DisplayUsedPowers)

        # IdleFlexCinematic.Play()
        PowerManager.AuraPower.AuraMutatorZone.AgentEntersEvent.Subscribe(EnteredAuraMutator)
        MinigameManager.CarGame.StopMutatorEvents()
        # TeamManager.ResetTeams(PlayersMap)

        for (PlayerSpawner : PlayerSpawners):
            PlayerSpawner.SpawnedEvent.Subscribe(OnPlayerSpawned)

        for (Collectible : CollectibleCoinManager.Collectibles):
            Collectible.CollectibleDevice.CollectedEvent.SubscribeAgent(OnCollectedPowerEvent, Collectible)
            Collectible.DespawnedEvent.Subscribe(OnCollectibleDespawned)

        for (Index -> Pinpad : PinpadTriggers):
            Pinpad.Button.InteractedWithEvent.SubscribeAgent(OnPinpadButtonInteracted, Index)

        MinigameManager.SharkGame.UnlockWeaponTrigger.TriggeredEvent.Subscribe(UnlockSharkWeapon)
        MinigameManager.CarGame.UnlockButton.InteractedWithEvent.Subscribe(UnlockBikeWeapon)
        MinigameManager.OrcaGame.UnlockButton.InteractedWithEvent.Subscribe(UnlockOrcaWeapon)

        # Init players who join mid way
        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerRemoved)
        GoldRemote.PrimarySignalEvent.Subscribe(OnPrimaryClick)
        StartGameTrigger.TriggeredEvent.Subscribe(StartGame)
        CollectibleCoinManager.ExoticTimer.SuccessEvent.Subscribe(OnExoticTimerSuccess)
        CollectibleCoinManager.MythicTimer.SuccessEvent.Subscribe(OnMythicTimerSuccess)
        Sleep(1.0)
        StartGameTrigger.Trigger()
        # TeamManager.CheckIfTeamsAreEqual()
        spawn. ResetBuildsLoop()

    UnlockSecretAndSave<public>(Player : player, Index : int):void=
        Print("UnlockSecretAndSave: {Index}")
        if (Agent := agent[Player], AgentData := AgentMap[Agent]):

            case(Index):
                0 => UnlockSwitch(Agent, Index) #Banana Gun                By Mid - Friday UNLOCK VIA CODE
                1 => # TeleportToPlaneGame(Agent) Croc Gun
                2 => # TeleportToForestGame(Agent) Deer Gun
                3 => # TeleportToGardenGame(Agent) Strawberry Gun
                4 => # 
                5 => MinigameManager.SharkGame.TeleportToMinigame(Agent) # Shark Gun              By Mid - Friday UNLOCK VIA SHOOT TRIGGER IN HAND
                6 => MinigameManager.OrcaGame.TeleportToMinigame(Agent) # Orca Gun            By Mid - Friday UNLOCK VIA BUTTON
                7 => MinigameManager.CarGame.TeleportToMinigame(Agent) # Biycle Gun                   By Mid - Friday UNLOCK VIA BUTTON
                8 => # 
                9 => PowerManager.FlyPower.ClassSelector.ChangeClass(Agent)
                10 => PowerManager.AimbotPower.AimerDevice.AddTo(Agent)

                _ => Print("")
            
    UnlockSwitch(Agent : agent, Index : int):void=
        if (not PinpadTriggers[Index].Switch.GetCurrentState[Agent]):
            # optional visuals per pinpad row
            if (Switch := PinpadTriggers[Index].Switch):
                Switch.TurnOn(Agent)
                Switch.SetState(Agent, true)
                Switch.SaveState(Agent)

    UnlockSharkWeapon(MaybeAgent : ?agent):void=
        if (Agent := MaybeAgent?, MinigameManager.SharkGame.GunChecker.IsHoldingItem[Agent]):
            UnlockSwitch(Agent, SHARK_GUN_INDEX)

    UnlockBikeWeapon(Agent : agent):void=
        UnlockSwitch(Agent, BIKE_GUN_INDEX)
    
    UnlockOrcaWeapon(Agent : agent):void=
        UnlockSwitch(Agent, ORCA_GUN_INDEX)

    OnPinpadButtonInteracted(Agent : agent, Index : int):void=
        if (Player := player[Agent], AgentData := AgentMap[Agent]):
            if (PinpadTriggers[Index].Switch.GetCurrentState[Agent]):
                if (ItemGranter := PinpadTriggers[Index].ItemGranter):
                    Print("Agent Got Granted Secret at Index {Index}")
                    ItemGranter.GrantItem(Agent)

    AwardXpCollectable(Agent : agent):void=
        CollectableAccolade.Award(Agent)

    SaveData(Player : player, AgentData : agent_data):void=
        block:
        # if(set PersistentAgentMap[Player] = AgentDataTmpToPersistent(AgentData)):

    StartGame(Agent : ?agent):void=
        Print("STARTING GAME")
        spawn. SpawnStartGame()

    SpawnStartGame()<suspends>:void=
        # TeamManager.ResetTeams(PlayersMap)
        MinigameManager.CarGame.StartMutatorEvents()
        spawn. StartSafeZone()

    DisplayPowers(Agent : agent):void=
        ValidateCatalogOnce()
        RunPowerInvariants(Agent)
        Print("Powers Lefts Normal Length : {AvailablePowerUps.Length}", ?Color := color{R := 1.0, G := 0.3, B := 0.8})
        Print("Powers Lefts Exotic Length : {AvailableExoticPowers.Length}", ?Color := color{R := 1.0, G := 0.0, B := 0.5})
        Print("Powers Lefts Mythic Length : {AvailableMythicPowers.Length}", ?Color := color{R := 1.0, G := 1.0, B := 0.0})

    DisplayUsedPowers(Agent : agent):void=
        Print(ArrayToString(UsedPowers))
        Print(ArrayToString(UsedExoticPowers))
        Print(ArrayToString(UsedMythicPowers))

    ValidateCatalogOnce():void=
        # Powers should be registered exactly once.
        var Seen:[int]logic = map{}
        for (Id -> Power : PowerCatalog):
            if (Seen[Id]):
                Print("Duplicate in catalog: {Id}", ?Color := color{R:=1.0,G:=0.2,B:=0.2})
            else:
                if (set Seen[Id] = true) {}

    ArrayToString(Ints:[]int):string =
        var Result:string = ""
        for (Index -> Value : Ints):
            if (Index > 0):
                set Result = "{Result}, "
            set Result = "{Result}{Value}"
        return "[{Result}]"

    # ResetUI(Player:player,AgentData : agent_data):void=
    #     if(PlayerUI := GetPlayerUI[Player], Canvas := AgentData.MaybeScreenCanvas?):
    #         PlayerUI.RemoveWidget(Canvas)
    #         NewCanvas := CreateScreenCanvas()
    #         PlayerUI.AddWidget(NewCanvas)
    #         set AgentData.MaybeScreenCanvas = option. NewCanvas

    GenerateStorm():void=
        SafeZone1.GenerateStorm()
        SafeZone2.GenerateStorm()

    DestroyStorm():void=
        SafeZone1.DestroyStorm()
        SafeZone2.DestroyStorm()
            
    StartSafeZone()<suspends>:void=
        loop:
            Sleep(1100.0)
            DestroyStorm()
            Sleep(0.1)
            GenerateStorm()

    ResetBuildsLoop()<suspends>:void=
        loop:
            Sleep(70.0)
            ResetBuildsExplosiveDeviceTrigger.Trigger()
            Sleep(0.1)
            ResetBuildsExplosiveDevice.Reset()
            ResetBuildsExplosiveDevice2.Reset()
            ResetBuildsExplosiveDevice3.Reset()
            ResetBuildsExplosiveDevice4.Reset()

    EnteredAuraMutator(Agent : agent):void=
        PowerManager.AuraPower.AuraSFX.Play(Agent)

    OnCollectibleDespawned(Obj : collectible):void =
        Print("Despawned: {Obj.PowerIndex}")
        AddPowerUpToArray(Obj.Type, Obj.PowerIndex, "Available")
        RemovePowerUpFromArray(Obj.Type, Obj.PowerIndex, "Used")

    ReturnCurrentPowerToPools(CP: CustomPlayer):void =
        Old := CP.GetPowerUp()
        if (Old > 0):
            T := DeterminePowerType(Old)
            AddPowerUpToArray(T, Old, "Available")
            RemovePowerUpFromArray(T, Old, "Used")  # if present

    GetRandomPowerUp(Type : PowerType) : int =
        #This ensures that no one has the same power
        var RandomPower : int = -1
        if (Array := GetAvailablePowerUpArray[Type]):
            if (Array.Length = 0) {}
            else:
                RandomIndex := GetRandomInt(0, Array.Length - 1)
                if (RandomPowerUp := Array[RandomIndex]):
                    set RandomPower = RandomPowerUp
                    if (New := Array.RemoveElement[RandomIndex]):
                        SetAvailablePowerUpArray(Type, New)
                        Print("Powers Left: {AvailablePowerUps.Length}", ?Color := color{R := 1.0, G := 0.0, B := 0.0})
        return RandomPower
        # if (Type = PowerType.Normal):
        #     RandomIndex := GetRandomInt(0, AvailablePowerUps.Length - 1)
        #     if(RandomPowerUp := AvailablePowerUps[RandomIndex]):
        #         set RandomPower = RandomPowerUp
        #         if(Available := AvailablePowerUps.RemoveElement[RandomIndex]):
        #             set AvailablePowerUps = Available
        #             Print("Powers Left: {AvailablePowerUps.Length}", ?Color := color{R := 1.0, G := 0.0, B := 0.0})
        # else if (Type = PowerType.Exotic):
        #     RandomIndex := GetRandomInt(0, AvailableExoticPowers.Length - 1)
        #     if(RandomPowerUp := AvailableExoticPowers[RandomIndex]):
        #         set RandomPower = RandomPowerUp
        #         if(Available := AvailableExoticPowers.RemoveElement[RandomIndex]):
        #             set AvailableExoticPowers = Available
        #             Print("Powers Left Exotic: {AvailableExoticPowers.Length}", ?Color := color{R := 1.0, G := 0.0, B := 0.0})
        # else if (Type = PowerType.Mythic):
        #     RandomIndex := GetRandomInt(0, AvailableMythicPowers.Length - 1)
        #     if(RandomPowerUp := AvailableMythicPowers[RandomIndex]):
        #         set RandomPower = RandomPowerUp
        #         if(Available := AvailableMythicPowers.RemoveElement[RandomIndex]):
        #             set AvailableMythicPowers = Available
        #             Print("Powers Left Mythic: {AvailableMythicPowers.Length}", ?Color := color{R := 1.0, G := 0.0, B := 0.0})

        # return RandomPower

    OnCollectedPowerEvent(Agent : agent, Collectible : collectible):void=
        Collectible.StopEvent.Signal()
        Collectible.CollectibleSFX.Play(Agent)

        #For the StatLeaderboard
        if(AgentData := AgentMap[Agent], Player := player[Agent]):
            set AgentData.Steals += 1
            if (set AgentData.StatValues["Steals"] = (AgentData.Steals * 1.0)){}
            UpdateSteal(Player, AgentData.Steals)
            SaveData(Player, AgentData)
            StatBoardManager.UpdateStatTableCanvas(AgentMap)

        NewPower := Collectible.PowerIndex
        if (CP := PlayersMap[Agent], NewPower <> -1):

            PreviousPowerUp := CP.GetPowerUp()
            PreviousPowerUpType := DeterminePowerType(PreviousPowerUp)
            Print("Player Old Power: {PreviousPowerUp}", ?Color := color{R := 1.0, G := 0.0, B := 0.0})
            Print("Player New Power: {NewPower}", ?Color := color{R := 0.0, G := 1.0, B := 0.0})

            
            # Add previous power-up to available array
            AddPowerUpToArray(PreviousPowerUpType, PreviousPowerUp, "Available")
            # Remove previous power-up from used array if player had one
            RemovePowerUpFromArray(PreviousPowerUpType, PreviousPowerUp, "Used")
    
            # Update player's power-up
            RemovePower(CP)
            CP.SetPowerUp(NewPower)
            AssignPowerup(Agent, NewPower)

            # Add new power-up to used array
            # AddPowerUpToArray(Collectible.Type, NewPower, "Used") #commented this because we add it tp the usedpower up array when it drops
            RemovePowerUpFromArray(Collectible.Type, NewPower, "Available")

            Print("Power Updated Correctly", ?Color := color{R := 0.0, G := 0.0, B := 1.0})
            CollectibleCoinManager.CollectedXP.Award(Agent)

    # Helper function to remove a power-up from the appropriate array
    RemovePowerUpFromArray(Type : PowerType, PowerUp : int, ArrayType : string):void=
        if(PowerUp > 0):
            if (ArrayType = "Available", Array := GetAvailablePowerUpArray[Type]):
                if (Index := Array.Find[PowerUp]):
                    if (NewArray := Array.RemoveElement[Index]):
                        case(Type):
                            PowerType.Normal => set AvailablePowerUps = NewArray
                            PowerType.Exotic => set AvailableExoticPowers = NewArray
                            PowerType.Mythic => set AvailableMythicPowers = NewArray
            else if (ArrayType = "Used", Array := GetUsedPowerUpArray[Type]):
                if (Index := Array.Find[PowerUp]):
                    if (NewArray := Array.RemoveElement[Index]):
                        case(Type):
                            PowerType.Normal => set UsedPowers = NewArray
                            PowerType.Exotic => set UsedExoticPowers = NewArray
                            PowerType.Mythic => set UsedMythicPowers = NewArray

    # Helper function to add a power-up to the appropriate array
    AddPowerUpToArray(Type : PowerType, PowerUp : int, ArrayType : string):void=
        if(PowerUp > 0):
            if (ArrayType = "Available", Array := GetAvailablePowerUpArray[Type]):
                SetAvailablePowerUpArray(Type, Array + array{PowerUp})
            else if (ArrayType = "Used", Array := GetUsedPowerUpArray[Type]):
                SetUsedPowerUpArray(Type, Array + array{PowerUp})

    # Helper function to get the appropriate available power-up array based on type
    GetAvailablePowerUpArray(Type : PowerType)<transacts><decides>:[]int =
        case(Type):
            PowerType.Normal => AvailablePowerUps
            PowerType.Exotic => AvailableExoticPowers
            PowerType.Mythic => AvailableMythicPowers
    
    # Helper function to set the appropriate available power-up array based on type
    SetAvailablePowerUpArray(Type : PowerType, NewArray : []int):void=
        case(Type):
            PowerType.Normal => set AvailablePowerUps = NewArray
            PowerType.Exotic => set AvailableExoticPowers = NewArray
            PowerType.Mythic => set AvailableMythicPowers = NewArray

    # Helper function to set the appropriate available power-up array based on type
    SetUsedPowerUpArray(Type : PowerType, NewArray : []int):void=
        case(Type):
            PowerType.Normal => set UsedPowers = NewArray
            PowerType.Exotic => set UsedExoticPowers = NewArray
            PowerType.Mythic => set UsedMythicPowers = NewArray

    # Helper function to get the appropriate power-up array based on type
    GetUsedPowerUpArray(Type : PowerType)<transacts><decides>:[]int =
        case(Type):
            PowerType.Normal => UsedPowers
            PowerType.Exotic => UsedExoticPowers
            PowerType.Mythic => UsedMythicPowers

    # FindPowerUpType(PowerUp : int):PowerType=
    #     if. UsedPowers.Find[PowerUp] then. return PowerType.Normal
    #     else if. UsedExoticPowers.Find[PowerUp] then. return PowerType.Exotic
    #     else if. UsedMythicPowers.Find[PowerUp] then. return PowerType.Mythic
    #     else. return PowerType.Normal

    OnExoticTimerSuccess(MaybeAgent : ?agent):void=
        RandomPowerUp := GetRandomPowerUp(PowerType.Exotic)
        RandomIndex := RandomPowerUp - 1
        if:
            RandomPowerUp > 0
            RandomIndex < CollectibleCoinManager.Collectibles.Length
            RandomCollectible := CollectibleCoinManager.Collectibles[RandomIndex] # PowerUps are 1 indexed, arrays are 0 indexed
            not UsedExoticPowers.Find[RandomPowerUp]
        then:
            Print("Found RandomPowerUp Exotic: {RandomPowerUp}")
            set UsedExoticPowers += array{RandomPowerUp}
            CollectibleCoinManager.TeleportAndDropFromSky(RandomCollectible)
        else:
            Print("Could not find Exotic power", ?Color := color{R := 1.0, G := 0.0, B := 0.0})


    OnMythicTimerSuccess(MaybeAgent : ?agent):void=
        RandomPowerUp := GetRandomPowerUp(PowerType.Mythic)
        RandomIndex := RandomPowerUp - 1
        if:
            RandomPowerUp > 0
            RandomIndex < CollectibleCoinManager.Collectibles.Length
            RandomCollectible := CollectibleCoinManager.Collectibles[RandomIndex] # PowerUps are 1 indexed, arrays are 0 indexed
            not UsedMythicPowers.Find[RandomPowerUp]
        then:
            Print("Found RandomPowerUp Mythic: {RandomPowerUp}")
            set UsedMythicPowers += array{RandomPowerUp}
            CollectibleCoinManager.TeleportAndDropFromSky(RandomCollectible)
        else:
            Print("Could not find Mythic power", ?Color := color{R := 1.0, G := 0.0, B := 0.0})

    GrantInventory(Agent : agent, IsRemotePower : logic, IsSpecialGunPower : logic):void=
        ShotgunGranter.CycleToRandomItem(Agent)
        ARGranter.CycleToRandomItem(Agent)
        if (IsRemotePower?):
            RemoteGranter.GrantItem(Agent)
        else if (IsSpecialGunPower?):
        else:
            SMGGranter.CycleToRandomItem(Agent)
        UtilsGranter.CycleToRandomItem(Agent)
        HealsGranter.CycleToRandomItem(Agent)

    ResetAllVFXFor(Agent : agent):void=
        ResetAllVFX.Pickup(Agent)
        ResetAllVFX2.Pickup(Agent)

    RegisterPower(Id : int, T : PowerType):void=
        # Fail fast if duplicate registration
        if (Existing := PowerCatalog[Id]):
            Print("Duplicate PowerCatalog entry for {Id}.", ?Color := color{R:=1.0,G:=0.2,B:=0.2})
        else:
            if (set PowerCatalog[Id] = T) {}

    InitPowerCatalog():void=
        # --- Normal Powers ---
        RegisterPower(PULL,            PowerType.Normal)
        RegisterPower(TELEPORT_BEHIND, PowerType.Normal)
        RegisterPower(FREEZE,          PowerType.Normal)
        RegisterPower(FLOOD,           PowerType.Normal)
        RegisterPower(AURA,            PowerType.Normal)
        RegisterPower(INVIS,           PowerType.Normal)
        RegisterPower(TIME_TRAVEL,     PowerType.Normal)
        RegisterPower(REWIND,          PowerType.Normal)
        RegisterPower(BULL,            PowerType.Normal)
        RegisterPower(BACKSTAB,        PowerType.Normal)
        RegisterPower(LIFESTEAL,       PowerType.Normal)
        RegisterPower(KNOCKBACK,       PowerType.Normal)
        RegisterPower(CIRCLE_BOMBS,    PowerType.Normal)
        RegisterPower(AGILITY,         PowerType.Normal)
        RegisterPower(DANCE,           PowerType.Normal)
        RegisterPower(SUPERCHARGED,    PowerType.Normal)
        RegisterPower(IMMUNE,          PowerType.Normal)
        RegisterPower(FASTERDAMAGE,    PowerType.Normal)
        RegisterPower(BUSH,            PowerType.Normal)
        RegisterPower(AIMBOT,          PowerType.Normal)
        RegisterPower(ANT,             PowerType.Normal)
        RegisterPower(ELECTRIC,        PowerType.Normal)
        RegisterPower(VOLLEY_BOMBS,    PowerType.Normal)
        RegisterPower(SPIDEY,          PowerType.Normal)
        RegisterPower(CHAR,            PowerType.Normal)
        RegisterPower(CHAIRPULL,       PowerType.Normal)
        RegisterPower(MISSILE,         PowerType.Normal)
        RegisterPower(CREEPER,         PowerType.Normal)
        RegisterPower(CHAR2,           PowerType.Normal)
        RegisterPower(JUMPSCARE,       PowerType.Normal)
        RegisterPower(BLIND,           PowerType.Normal)
        RegisterPower(PHONE_CALL_MUL,  PowerType.Normal)
        RegisterPower(PROPFOLLOW,      PowerType.Normal)
        RegisterPower(RAT_DANCE,       PowerType.Normal)
        RegisterPower(SALSA_ANIMATION, PowerType.Normal)
        RegisterPower(MUSTARD_ANIMATION,   PowerType.Normal)
        RegisterPower(SIXSEVEN_ANIMATION,  PowerType.Normal)
        RegisterPower(TRANSFORM,       PowerType.Normal)

        # --- Exotic Powers ---
        RegisterPower(ONESHOT,             PowerType.Exotic)
        RegisterPower(ASTRONAUT,           PowerType.Exotic)
        RegisterPower(SELFREVIVE,          PowerType.Exotic)
        RegisterPower(FINISHER2,           PowerType.Exotic)
        RegisterPower(WINTERARC_ANIMATION, PowerType.Exotic)

        # --- Mythic Powers ---
        RegisterPower(XRAY,               PowerType.Mythic)
        RegisterPower(SNAP,               PowerType.Mythic)
        RegisterPower(FLY,                PowerType.Mythic)
        RegisterPower(FINISHER3,          PowerType.Mythic)
        RegisterPower(ENGLISH_OR_SPANISH, PowerType.Mythic)

    RebuildPoolsFromCatalog():void=
        set AvailablePowerUps     = array{}
        set AvailableMythicPowers = array{}
        set AvailableExoticPowers = array{}
        set MythicPowersList      = array{}
        set ExoticPowersList      = array{}

        for (Id -> T : PowerCatalog):
            case(T):
                PowerType.Normal =>
                    set AvailablePowerUps += array{Id}
                PowerType.Mythic =>
                    set AvailableMythicPowers += array{Id}
                    set MythicPowersList      += array{Id}
                PowerType.Exotic =>
                    set AvailableExoticPowers += array{Id}
                    set ExoticPowersList      += array{Id}


    # Power Management
    # REVIEW POWERS FOR NEW FUNCTIONALITY AND GAME TYPE
    AssignPowerup(Agent : agent, PowerUp : int):void=
        #This is where you alter the player ex. class or apply strength
        if (CP : CustomPlayer = PlayersMap[Agent], Player := player[Agent], PlayerUI := GetPlayerUI[Player], CTimer := TimerMap[Agent], FortCharacter := Agent.GetFortCharacter[], AgentData := AgentMap[Agent]):
            #Clear Inventory First
            ResetAllVFXFor(Agent)
            DefaultClass.ChangeClass(Agent)
            ClearInventory.Remove(Agent)
            FortCharacter.Show()
            CP.SetPowerUp(PowerUp)
            UpdatePower(CP, Player, false)
            # TeamManager.CheckForTeamChange(CP)
            # MatsGranter.GrantItem(Agent)
            # AmmoGranter.GrantItem(Agent)
            Print("Agent has powerup {PowerUp}")

            # if(PowerUp = JUMP_EXPLODE):
            #     PowerManager.JumpExplodePower.PowerUI.Show(Agent)
            #     PowerManager.JumpExplodePower.Init(Agent)
            
            if(PowerUp = PULL):
                PowerManager.PullPower.PowerUI.Show(Agent)
                GrantInventory(Agent, false, true)
                PowerManager.PullPower.PullGranter.GrantItem(Agent)
                CTimer.HideTimer()
            
            else if(PowerUp = ONESHOT):
                PowerManager.OneShotPower.PowerUI.Show(Agent)
                GrantInventory(Agent, false, true)
                PowerManager.OneShotPower.OneShotItemGranter.GrantItem(Agent)
            
            else if(PowerUp = TELEPORT_BEHIND):
                PowerManager.TPBehindPower.PowerUI.Show(Agent)
                GrantInventory(Agent, true, false)
                CTimer.ShowTimer()
                spawn. PowerManager.TPBehindPower.PlayerInViewAsync(CP, PlayersMap, CTimer)
            
            else if(PowerUp = FREEZE):
                PowerManager.FreezePower.PowerUI.Show(Agent)
                GrantInventory(Agent, false, true)
                PowerManager.FreezePower.IceGranter.GrantItem(Agent)
                CTimer.ShowTimer()
            
            else if(PowerUp = FLOOD):
                PowerManager.FloodPower.PowerUI.Show(Agent)
                GrantInventory(Agent, true, false)
                CTimer.ShowTimer()
                spawn. PowerManager.FloodPower.PlayerInViewAsync(CP, PlayersMap, CTimer)
            
            else if(PowerUp = AURA):
                PowerManager.AuraPower.PowerUI.Show(Agent)
                PowerManager.AuraPower.Init(Agent)    
                GrantInventory(Agent, false, false)     
                CTimer.HideTimer()
            
            else if(PowerUp = INVIS):
                PowerManager.InvisPower.PowerUI.Show(Agent)
                GrantInventory(Agent, false, true)
                PowerManager.InvisPower.INVISPOWERGranter.GrantItem(Agent)
                spawn. PowerManager.InvisPower.Init(Agent, CTimer, DefaultClass)
            
            else if(PowerUp = TIME_TRAVEL):
                PowerManager.TimeTravelPower.PowerUI.Show(Agent)
                PowerManager.TimeTravelPower.Init(Agent)
                GrantInventory(Agent, true, false)
                CTimer.ShowTimer()
            
            else if(PowerUp = REWIND):
                PowerManager.RewindPower.PowerUI.Show(Agent)
                GrantInventory(Agent, true, false)
                CTimer.ShowTimer()
            
            else if(PowerUp = BULL):
                PowerManager.BullPower.PowerUI.Show(Agent)
                spawn. PowerManager.BullPower.Init(Agent)
                GrantInventory(Agent, false, false)
                CTimer.HideTimer()
            
            else if(PowerUp = BACKSTAB):
                PowerManager.BackstabPower.PowerUI.Show(Agent)
                PowerManager.BackstabPower.Init(Agent, CTimer)
                GrantInventory(Agent, false, false)
            
            else if(PowerUp = LIFESTEAL):
                PowerManager.LifeStealPower.PowerUI.Show(Agent)
                spawn. PowerManager.LifeStealPower.Init(CP, CTimer)
                GrantInventory(Agent, false, false)
            
            else if(PowerUp = ASTRONAUT):
                PowerManager.AstronautPower.PowerUI.Show(Agent)
                PowerManager.AstronautPower.Init(Agent, CTimer)
                GrantInventory(Agent, false, false)
            
            # else if(PowerUp = BOUNTY_HUNTER):
            #     PowerManager.BountyHunterPower.PowerUI.Show(Agent)
            #     spawn. PowerManager.BountyHunterPower.Init(CP, PlayersMap, CTimer)
            #     GrantInventory(Agent, false, false)
            
            else if(PowerUp = KNOCKBACK):
                PowerManager.KnockbackPower.PowerUI.Show(Agent)
                GrantInventory(Agent, false, false)
                CTimer.HideTimer()
            
            else if(PowerUp = CIRCLE_BOMBS):
                PowerManager.CircleBombsPower.PowerUI.Show(Agent)
                PowerManager.CircleBombsPower.Init(CTimer)
                GrantInventory(Agent, true, false)
                CTimer.ShowTimer()
            
            else if(PowerUp = VOLLEY_BOMBS):
                PowerManager.VolleyBombsPower.PowerUI.Show(Agent)
                PowerManager.VolleyBombsPower.WearableVFX.Pickup(Agent)
                GrantInventory(Agent, true, false)
                CTimer.ShowTimer()
            
            else if(PowerUp = XRAY):
                PowerManager.XrayPower.PowerUI.Show(Agent)
                # PowerManager.XrayPower.WearableVFX.Pickup(Agent)
                spawn. PowerManager.XrayPower.Init(CP, PlayersMap, CTimer)
                GrantInventory(Agent, false, false)
            
            else if(PowerUp = AGILITY):
                PowerManager.AgilityPower.PowerUI.Show(Agent)
                PowerManager.AgilityPower.Init(Agent, CTimer)
                GrantInventory(Agent, false, false)
            
            else if(PowerUp = DANCE):
                PowerManager.DancePower.PowerUI.Show(Agent)
                PowerManager.DancePower.Init(Agent, CTimer)
                GrantInventory(Agent, false, false)
            
            else if(PowerUp = SUPERCHARGED):
                PowerManager.SuperchargedPower.PowerUI.Show(Agent)
                PowerManager.SuperchargedPower.Init(CTimer)
                GrantInventory(Agent, false, false)
            
            else if(PowerUp = SELFREVIVE):
                PowerManager.SelfRevivePower.PowerUI.Show(Agent)
                spawn. PowerManager.SelfRevivePower.Init(Agent, CTimer)
                GrantInventory(Agent, false, false)
                CTimer.ShowTimer()
            
            else if(PowerUp = IMMUNE):
                PowerManager.ImmunePower.PowerUI.Show(Agent)
                GrantInventory(Agent, false, false)
                CTimer.ShowTimer()
            
            else if(PowerUp = FASTERDAMAGE):
                PowerManager.MoreSpeedFromDamagePower.PowerUI.Show(Agent)
                spawn. PowerManager.MoreSpeedFromDamagePower.Init(CTimer)
                GrantInventory(Agent, false, false)
                CTimer.ShowTimer()
            
            # else if(PowerUp = ONESHOTPICKAXE):
            #     PowerManager.OneShotPickaxePower.PowerUI.Show(Agent)
            #     CTimer.HideTimer()

            else if(PowerUp = BUSH):
                PowerManager.BushPower.PowerUI.Show(Agent)
                GrantInventory(Agent, true, false)
                CTimer.ShowTimer()

            else if(PowerUp = AIMBOT):
                PowerManager.AimbotPower.PowerUI.Show(Agent)
                PowerManager.AimbotPower.Init(Agent, CTimer)
                GrantInventory(Agent, false, false)
            
            else if(PowerUp = FINISHER2):
                PowerManager.LotsOfHealthPower.PowerUI.Show(Agent)
                PowerManager.LotsOfHealthPower.Init(Agent)
                GrantInventory(Agent, false, false)
                CTimer.ShowTimer()
            
            else if(PowerUp = FINISHER3):
                PowerManager.Teleport3PeoplePower.PowerUI.Show(Agent)
                PowerManager.Teleport3PeoplePower.Init(Agent, CTimer)
                GrantInventory(Agent, true, false)
                CTimer.ShowTimer()

            # else if(PowerUp = MOBILITY):
            #     PowerManager.MobilityPower.PowerUI.Show(Agent)
            #     PowerManager.MobilityPower.Init(Agent)
            
            else if(PowerUp = ANT):
                PowerManager.AntPower.PowerUI.Show(Agent)
                GrantInventory(Agent, true, false)
                CTimer.ShowTimer()

            else if(PowerUp = ELECTRIC):
                PowerManager.ElectricPower.PowerUI.Show(Agent)
                GrantInventory(Agent, false, false)
                CTimer.HideTimer()

            # else if(PowerUp = PHOENIX):
            #     PowerManager.PhoenixPower.PowerUI.Show(Agent)
            #     PowerManager.PhoenixPower.Init(Agent)
            #     CTimer.HideTimer()

            else if(PowerUp = SPIDEY):
                PowerManager.SpideyPower.PowerUI.Show(Agent)
                PowerManager.SpideyPower.Init(Agent)
                GrantInventory(Agent, false, false)
                CTimer.HideTimer()

            else if(PowerUp = CHAR):
                PowerManager.TurnIntoCharPower.PowerUI.Show(Agent)
                GrantInventory(Agent, false, false)
                PowerManager.TurnIntoCharPower.ActivateAbility(Agent)
                CTimer.ShowTimer()

            else if(PowerUp = CHAR2):
                PowerManager.TurnIntoCharPower2.PowerUI.Show(Agent)
                PowerManager.TurnIntoCharPower2.ActivateAbility(Agent)
                GrantInventory(Agent, false, false)
                CTimer.ShowTimer()

            else if(PowerUp = CHAIRPULL):
                PowerManager.ChairPullPower.PowerUI.Show(Agent)
                spawn. PowerManager.ChairPullPower.PlayerInViewAsync(CP, PlayersMap, CTimer)
                GrantInventory(Agent, true, false)
                CTimer.ShowTimer()

            else if(PowerUp = FLY):
                PowerManager.FlyPower.PowerUI.Show(Agent)
                spawn. PowerManager.FlyPower.Init(Agent)
                GrantInventory(Agent, false, false)
                CTimer.ShowTimer()

            else if(PowerUp = MISSILE):
                PowerManager.MissilePower.PowerUI.Show(Agent)
                GrantInventory(Agent, true, false)
                CTimer.ShowTimer()

            else if(PowerUp = ENGLISH_OR_SPANISH):
                PowerManager.EnglishOrSpanishPower.PowerUI.Show(Agent)
                GrantInventory(Agent, true, false)
                CTimer.ShowTimer()

            else if(PowerUp = CREEPER):
                PowerManager.CreeperPower.PowerUI.Show(Agent)
                GrantInventory(Agent, true, false)
                CTimer.ShowTimer()

            else if(PowerUp = TRANSFORM):
                PowerManager.TransformPower.PowerUI.Show(Agent)
                GrantInventory(Agent, false, true)
                PowerManager.TransformPower.ItemGranter.GrantItem(Agent)
                CTimer.ShowTimer()

            else if(PowerUp = JUMPSCARE):
                PowerManager.JumpscarePower.PowerUI.Show(Agent)
                spawn. PowerManager.JumpscarePower.PlayerInViewAsync(CP, PlayersMap, CTimer)
                GrantInventory(Agent, true, false)
                CTimer.ShowTimer()

            else if(PowerUp = BLIND):
                PowerManager.BlindPower.PowerUI.Show(Agent)
                GrantInventory(Agent, false, true)
                PowerManager.BlindPower.WeaponGranter.GrantItem(Agent)
                CTimer.ShowTimer()

            else if(PowerUp = PHONE_CALL_MUL):
                PowerManager.PhoneCallMulPower.PowerUI.Show(Agent)
                spawn. PowerManager.PhoneCallMulPower.PlayerInViewAsync(CP, PlayersMap, CTimer)
                GrantInventory(Agent, true, false)
                CTimer.ShowTimer()

            else if(PowerUp = PROPFOLLOW):
                PowerManager.PropFollowPower.PowerUI.Show(Agent)
                spawn. PowerManager.PropFollowPower.PlayerInViewAsync(CP, PlayersMap, CTimer)
                GrantInventory(Agent, true, false)
                CTimer.ShowTimer()

            # else if(PowerUp = SHOOT_PROP):
            #     PowerManager.ShootPropPower.PowerUI.Show(Agent)
            #     GrantInventory(Agent, true, false)
            #     CTimer.ShowTimer()

            else if(PowerUp = RAT_DANCE):
                PowerManager.ForceDancePower.PowerUI.Show(Agent)
                GrantInventory(Agent, false, true)
                PowerManager.ForceDancePower.ItemGranter.GrantItem(Agent)
                CTimer.ShowTimer()

            else if(PowerUp = SALSA_ANIMATION):
                PowerManager.SalsaAnimationPower.PowerUI.Show(Agent)
                GrantInventory(Agent, false, true)
                PowerManager.SalsaAnimationPower.WeaponGranter.GrantItem(Agent)
                CTimer.ShowTimer()

            else if(PowerUp = WINTERARC_ANIMATION):
                PowerManager.WinterArcAnimationPower.PowerUI.Show(Agent)
                GrantInventory(Agent, false, true)
                PowerManager.WinterArcAnimationPower.WeaponGranter.GrantItem(Agent)
                CTimer.ShowTimer()

            # else if(PowerUp = SLAP_COMP_ANIMATION):
            #     PowerManager.SlapCompAnimationPower.PowerUI.Show(Agent)
            #     GrantInventory(Agent, false, true)
            #     PowerManager.SlapCompAnimationPower.WeaponGranter.GrantItem(Agent)
            #     CTimer.ShowTimer()

            else if(PowerUp = MUSTARD_ANIMATION):
                PowerManager.MustardAnimationPower.PowerUI.Show(Agent)
                GrantInventory(Agent, false, true)
                PowerManager.MustardAnimationPower.WeaponGranter.GrantItem(Agent)
                CTimer.ShowTimer()

            else if(PowerUp = SIXSEVEN_ANIMATION):
                PowerManager.SixSevenAnimationPower.PowerUI.Show(Agent)
                GrantInventory(Agent, false, true)
                PowerManager.SixSevenAnimationPower.WeaponGranter.GrantItem(Agent)
                CTimer.ShowTimer()

            # else if(PowerUp = SUI_ANIMATION):
            #     PowerManager.SuiAnimationPower.PowerUI.Show(Agent)
            #     GrantInventory(Agent, false, true)
            #     PowerManager.SuiAnimationPower.WeaponGranter.GrantItem(Agent)
            #     CTimer.ShowTimer()

            # else if(PowerUp = KID_ON_BOAT_ANIMATION):
            #     PowerManager.KidOnBoatAnimationPower.PowerUI.Show(Agent)
            #     GrantInventory(Agent, false, true)
            #     PowerManager.KidOnBoatAnimationPower.WeaponGranter.GrantItem(Agent)
            #     CTimer.ShowTimer()

            # else if(PowerUp = ONE_POUND_FISH_ANIMATION):
            #     PowerManager.OnePoundFishAnimationPower.PowerUI.Show(Agent)
            #     GrantInventory(Agent, false, true)
            #     PowerManager.OnePoundFishAnimationPower.WeaponGranter.GrantItem(Agent)
            #     CTimer.ShowTimer()

            else if(PowerUp = SNAP):
                PowerManager.SnapPower.PowerUI.Show(Agent)
                GrantInventory(Agent, true, false)
                CTimer.ShowTimer()


    RemovePower<private>(CP: CustomPlayer):void =
        CPPowerIndex := CP.GetPowerUp()
        Agent := CP.MyAgentObj
        if(CPPowerIndex <> -1):
            Print("Removing Power index {CPPowerIndex}")

            if. CPPowerIndex = FLOOD then. PowerManager.FloodPower.Delete()
            if. CPPowerIndex = MISSILE then. PowerManager.MissilePower.MissileDevice.Delete()
            if. CPPowerIndex = TELEPORT_BEHIND then. PowerManager.TPBehindPower.Delete()
            if. CPPowerIndex = ONESHOT then. PowerManager.OneShotPower.Delete(Agent)
            if. CPPowerIndex = AURA then. PowerManager.AuraPower.Delete()
            if. CPPowerIndex = INVIS then. PowerManager.InvisPower.Delete()
            if. CPPowerIndex = TIME_TRAVEL then. PowerManager.TimeTravelPower.Delete()
            if. CPPowerIndex = BULL then. PowerManager.BullPower.Delete()
            if. CPPowerIndex = LIFESTEAL then. PowerManager.LifeStealPower.Delete()
            if. CPPowerIndex = ASTRONAUT then. PowerManager.AstronautPower.Delete()
            if. CPPowerIndex = CIRCLE_BOMBS then. PowerManager.CircleBombsPower.Delete()
            if. CPPowerIndex = XRAY then. PowerManager.XrayPower.Delete()
            if. CPPowerIndex = AGILITY then. PowerManager.AgilityPower.Delete()
            if. CPPowerIndex = DANCE then. PowerManager.DancePower.Delete()
            if. CPPowerIndex = SELFREVIVE then. PowerManager.SelfRevivePower.Delete()
            if. CPPowerIndex = FASTERDAMAGE then. PowerManager.MoreSpeedFromDamagePower.Delete(Agent)
            if. CPPowerIndex = BUSH then. PowerManager.BushPower.Delete()
            if. CPPowerIndex = AIMBOT then. PowerManager.AimbotPower.Delete()
            if. CPPowerIndex = ANT then. PowerManager.AntPower.Delete()
            if. CPPowerIndex = VOLLEY_BOMBS then. PowerManager.VolleyBombsPower.Delete()
            if. CPPowerIndex = SPIDEY then. PowerManager.SpideyPower.Delete()
            # if. CPPowerIndex = BOUNTY_HUNTER then. PowerManager.BountyHunterPower.Delete()
            if. CPPowerIndex = CHAR then. PowerManager.TurnIntoCharPower.Delete(Agent)
            if. CPPowerIndex = CHAR2 then. PowerManager.TurnIntoCharPower2.Delete(Agent)
            if. CPPowerIndex = CHAIRPULL then. PowerManager.ChairPullPower.Delete()
            if. CPPowerIndex = FINISHER3 then. PowerManager.Teleport3PeoplePower.Delete()
            if. CPPowerIndex = ENGLISH_OR_SPANISH then. PowerManager.EnglishOrSpanishPower.Delete()
            if. CPPowerIndex = CREEPER then. PowerManager.CreeperPower.Delete()
            if. CPPowerIndex = TRANSFORM then. PowerManager.TransformPower.Delete()
            if. CPPowerIndex = JUMPSCARE then. PowerManager.JumpscarePower.Delete()
            if. CPPowerIndex = BLIND then. PowerManager.BlindPower.Delete()
            if. CPPowerIndex = PHONE_CALL_MUL then. PowerManager.PhoneCallMulPower.Delete()
            if. CPPowerIndex = PROPFOLLOW then. PowerManager.PropFollowPower.Delete()
            if. CPPowerIndex = IMMUNE then. PowerManager.ImmunePower.Delete()

            CP.RemovePowerUp()
            # if. Player := player[CP.MyAgentObj] then. TeamManager.AddPlayerToDefaultTeam(Player)
            if(CTimer := TimerMap[CP.MyAgentObj]):
                CTimer.Stop()
                CTimer.HideTimer()
                CTimer.ResetText()
                ClearUI.Show(Agent)



    OnPrimaryClick(Agent : agent):void=
        if (CP := PlayersMap[Agent], Player := player[Agent], PlayerUI := GetPlayerUI[Player], CTimer := TimerMap[Agent]):
            CPPowerUp := CP.GetPowerUp()
            Milliseconds : float = 0.0
            #added spawns make sure to error check!
            
            if (CPPowerUp = FLOOD and not CTimer.IsActive?):
                CTimer.StartCountdown(PowerManager.FloodPower.AbilityCooldown)
                spawn. PowerManager.FloodPower.ActivateAbilty(CP, PlayersMap)

            else if (CPPowerUp = TELEPORT_BEHIND and not CTimer.IsActive?):
                CTimer.StartCountdown(PowerManager.TPBehindPower.AbilityCooldown)
                spawn. PowerManager.TPBehindPower.OnTeleportPower(CP, PlayersMap)

            else if (CPPowerUp = TIME_TRAVEL and not CTimer.IsActive?):
                CTimer.StartCountdown(PowerManager.TimeTravelPower.AbilityCooldown)
                spawn. PowerManager.TimeTravelPower.ActivatePowerup(Agent)

            else if (CPPowerUp = CIRCLE_BOMBS and not CTimer.IsActive?):
                CTimer.StartCountdown(PowerManager.CircleBombsPower.AbilityCooldown)   
                spawn. PowerManager.CircleBombsPower.ActivatePowerup(CP,PlayersMap)

            else if (CPPowerUp = VOLLEY_BOMBS and not CTimer.IsActive?):
                CTimer.StartCountdown(PowerManager.VolleyBombsPower.AbilityCooldown)
                spawn. PowerManager.VolleyBombsPower.ActivateAbility(Agent)

            else if (CPPowerUp = REWIND and not CTimer.IsActive?):
                spawn{PowerManager.RewindPower.ActivateAbility(CP,CTimer)}

            else if (CPPowerUp = FINISHER3 and not CTimer.IsActive?):
                CTimer.StartCountdown(PowerManager.Teleport3PeoplePower.AbilityCooldown)
                spawn. PowerManager.Teleport3PeoplePower.ActivateAbility(Agent,PlayersMap)

            else if (CPPowerUp = BUSH and not CTimer.IsActive?):
                CTimer.StartCountdown(PowerManager.BushPower.AbilityCooldown)
                spawn. PowerManager.BushPower.ActivatePowerup(Agent)

            else if (CPPowerUp = ANT and not CTimer.IsActive?):
                CTimer.StartCountdown(PowerManager.AntPower.AbilityDuration + PowerManager.AntPower.AbilityCooldown)
                spawn. PowerManager.AntPower.ActivatePowerup(CP, PlayersMap)

            else if (CPPowerUp = CHAIRPULL and not CTimer.IsActive?):
                CTimer.StartCountdown(PowerManager.ChairPullPower.AbilityCooldown)
                spawn. PowerManager.ChairPullPower.ActivatePowerup(CP, PlayersMap)

            else if (CPPowerUp = MISSILE and not CTimer.IsActive?):
                CTimer.StartCountdown(PowerManager.MissilePower.AbilityCooldown)
                spawn. PowerManager.MissilePower.ActivateAbility(Agent)

            else if (CPPowerUp = ENGLISH_OR_SPANISH and not CTimer.IsActive?):
                CTimer.StartCountdown(PowerManager.EnglishOrSpanishPower.AbilityCooldown)
                spawn. PowerManager.EnglishOrSpanishPower.ActivateAbility(PlayersMap, Agent)

            else if (CPPowerUp = CREEPER and not CTimer.IsActive?):
                CTimer.StartCountdown(PowerManager.CreeperPower.AbilityCooldown)
                spawn. PowerManager.CreeperPower.ActivateAbility(Agent)

            else if (CPPowerUp = JUMPSCARE and not CTimer.IsActive?):
                CTimer.StartCountdown(PowerManager.JumpscarePower.AbilityCooldown)
                spawn. PowerManager.JumpscarePower.ActivateAbility(CP, PlayersMap)

            else if (CPPowerUp = PHONE_CALL_MUL and not CTimer.IsActive?):
                CTimer.StartCountdown(PowerManager.PhoneCallMulPower.AbilityCooldown)
                spawn. PowerManager.PhoneCallMulPower.PhoneCallSpawner(CP, PlayersMap)

            else if (CPPowerUp = PROPFOLLOW and not CTimer.IsActive?):
                CTimer.StartCountdown(PowerManager.PropFollowPower.AbilityCooldown)
                spawn. PowerManager.PropFollowPower.ActivateAbility(CP, PlayersMap)

            # else if (CPPowerUp = SHOOT_PROP and not CP.UsedPower?):
            #     CTimer.StartCountdown(PowerManager.ShootPropPower.AbilityCooldown, Milliseconds)
            #     spawn. PowerManager.ShootPropPower.ActivateAbility()
            #     spawn. CP.UsedRemote(PowerManager.ShootPropPower.AbilityCooldown)

            else if (CPPowerUp = SNAP and not CTimer.IsActive?):
                CTimer.StartCountdown(PowerManager.SnapPower.AbilityCooldown)
                spawn. PowerManager.SnapPower.ActivateAbility(Agent, PlayersMap)

    OnPlayerDamage(DamageResult : damage_result):void=
        
        if (CustomCauser := custom_game_action_causer[DamageResult.Source?]):
            return

        Amount := DamageResult.Amount
        if (Instigator := DamageResult.Instigator?, InstigatorAgent := Instigator.GetInstigatorAgent[], CP : CustomPlayer = PlayersMap[InstigatorAgent], Target := fort_character[DamageResult.Target], 
        TargetAgent := Target.GetAgent[], TargetCP : CustomPlayer = PlayersMap[TargetAgent], InstigatorAgent <> TargetAgent,  CTimer := TimerMap[InstigatorAgent]):

            CPPowerUp := CP.GetPowerUp()
            TargetCPPowerUp := TargetCP.GetPowerUp()

            #Here is where you handle the powers via damage
            if(FortDidDamage := InstigatorAgent.GetFortCharacter[], FortTookDamage := TargetAgent.GetFortCharacter[]):
                CustomDamagedEvent(CP,CPPowerUp,FortDidDamage,TargetCP,TargetCPPowerUp,FortTookDamage,Amount,InstigatorAgent,TargetAgent)
    
            if (CPPowerUp = PULL):
                spawn. PowerManager.PullPower.ApplyImpulse(InstigatorAgent, TargetAgent)

            else if (CPPowerUp = KNOCKBACK):
                spawn. PowerManager.KnockbackPower.ApplyImpulse(InstigatorAgent, TargetAgent)

            else if (CPPowerUp = FREEZE and not CTimer.IsActive?):
                if(FortChar := InstigatorAgent.GetFortCharacter[],Location := FortChar.GetTransform(),PowerManager.FreezePower.IceItemChecker.IsHoldingItem[InstigatorAgent], TargetLocation := Target.GetTransform()):
                    CTimer.StartCountdown(PowerManager.FreezePower.AbilityCooldown)
                    spawn. PowerManager.FreezePower.ActivateAbility(InstigatorAgent, Target, TargetAgent)

            else if (CPPowerUp = ONESHOT):
                if(PowerManager.OneShotPower.OneShotConditional.IsHoldingItem[InstigatorAgent],FortDidDamage := InstigatorAgent.GetFortCharacter[]):
                    spawn. PowerManager.OneShotPower.OneShotTarget(Target, FortDidDamage)
                    PowerManager.OneShotPower.OneShotSFX.Play(InstigatorAgent)

            # else if (CPPowerUp = ONESHOTPICKAXE):
            #     spawn. PowerManager.OneShotPickaxePower.KillPlayer(InstigatorAgent, Target)

            # else if (CPPowerUp = PHOENIX):
            #     spawn. PowerManager.PhoenixPower.ActivateAbility(InstigatorAgent, TargetAgent)

            else if (CPPowerUp = ELECTRIC):
                spawn. PowerManager.ElectricPower.ActivateAbility(Target)

            else if (CPPowerUp = TRANSFORM and not CTimer.IsActive?):
                if(PowerManager.TransformPower.ItemChecker.IsHoldingItem[InstigatorAgent]):
                    CTimer.StartCountdown(PowerManager.TransformPower.AbilityCooldown)
                    spawn. PowerManager.TransformPower.ActivateAbility(InstigatorAgent, TargetAgent)

            else if (CPPowerUp = BLIND and not CTimer.IsActive?):
                if(PowerManager.BlindPower.WeaponHolder.IsHoldingItem[InstigatorAgent]):
                    CTimer.StartCountdown(PowerManager.BlindPower.AbilityCooldown)
                    spawn. PowerManager.BlindPower.ActivateAbility(InstigatorAgent, TargetAgent)

            else if (CPPowerUp = RAT_DANCE and not CTimer.IsActive?):
                if(PowerManager.ForceDancePower.ItemChecker.IsHoldingItem[InstigatorAgent]):
                    CTimer.StartCountdown(PowerManager.ForceDancePower.AbilityCooldown)
                    spawn. PowerManager.ForceDancePower.ActivateAbility(InstigatorAgent, Target)

            else if (CPPowerUp = SALSA_ANIMATION and not CTimer.IsActive?):
                if(PowerManager.SalsaAnimationPower.WeaponChecker.IsHoldingItem[InstigatorAgent]):
                    CTimer.StartCountdown(PowerManager.SalsaAnimationPower.AbilityCooldown)
                    spawn. PowerManager.SalsaAnimationPower.ActivateAbility(InstigatorAgent, TargetAgent)

            else if (CPPowerUp = WINTERARC_ANIMATION and not CTimer.IsActive?):
                if(PowerManager.WinterArcAnimationPower.WeaponChecker.IsHoldingItem[InstigatorAgent]):
                    CTimer.StartCountdown(PowerManager.WinterArcAnimationPower.AbilityCooldown)
                    spawn. PowerManager.WinterArcAnimationPower.ActivateAbility(InstigatorAgent, TargetAgent)

            # else if (CPPowerUp = SLAP_COMP_ANIMATION and not CP.UsedPower?):
            #     CTimer.StartCountdown(PowerManager.SlapCompAnimationPower.AbilityCooldown, 0.0)
            #     spawn. PowerManager.SlapCompAnimationPower.ActivateAbility(InstigatorAgent, TargetAgent)
            #     spawn. CP.UsedRemote(PowerManager.SlapCompAnimationPower.AbilityCooldown)

            else if (CPPowerUp = MUSTARD_ANIMATION and not CTimer.IsActive?):
                if(PowerManager.MustardAnimationPower.WeaponChecker.IsHoldingItem[InstigatorAgent]):
                    CTimer.StartCountdown(PowerManager.MustardAnimationPower.AbilityCooldown)
                    spawn. PowerManager.MustardAnimationPower.ActivateAbility(InstigatorAgent, TargetAgent)

            else if (CPPowerUp = SIXSEVEN_ANIMATION and not CTimer.IsActive?):
                if(PowerManager.SixSevenAnimationPower.WeaponChecker.IsHoldingItem[InstigatorAgent]):
                    CTimer.StartCountdown(PowerManager.SixSevenAnimationPower.AbilityCooldown)
                    spawn. PowerManager.SixSevenAnimationPower.ActivateAbility(InstigatorAgent, TargetAgent)

            # else if (CPPowerUp = SUI_ANIMATION and not CP.UsedPower?):
            #     CTimer.StartCountdown(PowerManager.SuiAnimationPower.AbilityCooldown, 0.0)
            #     spawn. PowerManager.SuiAnimationPower.ActivateAbility(InstigatorAgent)
            #     spawn. CP.UsedRemote(PowerManager.SuiAnimationPower.AbilityCooldown)

            # else if (CPPowerUp = KID_ON_BOAT_ANIMATION and not CP.UsedPower?):
            #     CTimer.StartCountdown(PowerManager.KidOnBoatAnimationPower.AbilityCooldown, 0.0)
            #     spawn. PowerManager.KidOnBoatAnimationPower.ActivateAbility(InstigatorAgent, TargetAgent)
            #     spawn. CP.UsedRemote(PowerManager.KidOnBoatAnimationPower.AbilityCooldown)

            # else if (CPPowerUp = ONE_POUND_FISH_ANIMATION and not CP.UsedPower?):
            #     CTimer.StartCountdown(PowerManager.OnePoundFishAnimationPower.AbilityCooldown, 0.0)
            #     spawn. PowerManager.OnePoundFishAnimationPower.ActivateAbility(InstigatorAgent, TargetAgent)
            #     spawn. CP.UsedRemote(PowerManager.OnePoundFishAnimationPower.AbilityCooldown)

            # else if (CPPowerUp = IMMUNE and not CP.UsedPower?):
            #     CTimer.StartCountdown(PowerManager.ImmunePower.AbilityCooldown,  0.0)
            #     spawn. PowerManager.ImmunePower.ActivateAbilty(TargetAgent)
            #     spawn. CP.UsedRemote(PowerManager.ImmunePower.AbilityCooldown)

    
    OnPlayerShieldDamage(DamageResult: damage_result):void=

        if (CustomCauser := custom_game_action_causer[DamageResult.Source?]):
            return

        Amount := DamageResult.Amount
        if (Instigator := DamageResult.Instigator?, InstigatorAgent := Instigator.GetInstigatorAgent[], CP : CustomPlayer = PlayersMap[InstigatorAgent], Target := fort_character[DamageResult.Target], 
        TargetAgent := Target.GetAgent[], TargetCP : CustomPlayer = PlayersMap[TargetAgent], InstigatorAgent <> TargetAgent, CTimer := TimerMap[InstigatorAgent]):

            TargetCPPowerUp := TargetCP.GetPowerUp()
            CPPowerUp := CP.GetPowerUp()

            if(FortDidDamage := InstigatorAgent.GetFortCharacter[], FortTookDamage := TargetAgent.GetFortCharacter[]):
                CustomDamagedEvent(CP,CPPowerUp,FortDidDamage,TargetCP,TargetCPPowerUp,FortTookDamage,Amount, InstigatorAgent,TargetAgent)
          
            if (CPPowerUp = PULL):
                spawn. PowerManager.PullPower.ApplyImpulse(InstigatorAgent, TargetAgent)

            else if (CPPowerUp = KNOCKBACK):
                spawn. PowerManager.KnockbackPower.ApplyImpulse(InstigatorAgent, TargetAgent)
                    
            else if (CPPowerUp = FREEZE and not CTimer.IsActive?):
                if:
                    FortChar := InstigatorAgent.GetFortCharacter[]
                    Location := FortChar.GetTransform()
                    PowerManager.FreezePower.IceItemChecker.IsHoldingItem[InstigatorAgent]
                    TargetLocation := Target.GetTransform()
                then:
                    CTimer.StartCountdown(PowerManager.FreezePower.AbilityCooldown)
                    spawn. PowerManager.FreezePower.ActivateAbility(InstigatorAgent, Target, TargetAgent)

            else if (CPPowerUp = ONESHOT):
                InstaKill : float = 999.0
                if(PowerManager.OneShotPower.OneShotConditional.IsHoldingItem[InstigatorAgent], FC := InstigatorAgent.GetFortCharacter[]):
                    spawn. PowerManager.OneShotPower.OneShotTarget(Target, FC)
                    PowerManager.OneShotPower.OneShotSFX.Play(InstigatorAgent)

            # else if (CPPowerUp = ONESHOTPICKAXE):
            #     spawn. PowerManager.OneShotPickaxePower.KillPlayer(InstigatorAgent, Target)

            # else if (CPPowerUp = PHOENIX):
            #     spawn. PowerManager.PhoenixPower.ActivateAbility(InstigatorAgent, TargetAgent)

            else if (CPPowerUp = ELECTRIC):
                spawn. PowerManager.ElectricPower.ActivateAbility(Target)

            else if (CPPowerUp = TRANSFORM and not CTimer.IsActive?):
                if(PowerManager.TransformPower.ItemChecker.IsHoldingItem[InstigatorAgent]):
                    CTimer.StartCountdown(PowerManager.TransformPower.AbilityCooldown)
                    spawn. PowerManager.TransformPower.ActivateAbility(InstigatorAgent, TargetAgent)

            else if (CPPowerUp = BLIND and not CTimer.IsActive?):
                if(PowerManager.BlindPower.WeaponHolder.IsHoldingItem[InstigatorAgent]):
                    CTimer.StartCountdown(PowerManager.BlindPower.AbilityCooldown)
                    spawn. PowerManager.BlindPower.ActivateAbility(InstigatorAgent, TargetAgent)

            else if (CPPowerUp = RAT_DANCE and not CTimer.IsActive?):
                if(PowerManager.ForceDancePower.ItemChecker.IsHoldingItem[InstigatorAgent]):
                    CTimer.StartCountdown(PowerManager.ForceDancePower.AbilityCooldown)
                    spawn. PowerManager.ForceDancePower.ActivateAbility(InstigatorAgent, Target)

            else if (CPPowerUp = SALSA_ANIMATION and not CTimer.IsActive?):
                if(PowerManager.SalsaAnimationPower.WeaponChecker.IsHoldingItem[InstigatorAgent]):
                    CTimer.StartCountdown(PowerManager.SalsaAnimationPower.AbilityCooldown)
                    spawn. PowerManager.SalsaAnimationPower.ActivateAbility(InstigatorAgent, TargetAgent)

            else if (CPPowerUp = WINTERARC_ANIMATION and not CTimer.IsActive?):
                if(PowerManager.WinterArcAnimationPower.WeaponChecker.IsHoldingItem[InstigatorAgent]):
                    CTimer.StartCountdown(PowerManager.WinterArcAnimationPower.AbilityCooldown)
                    spawn. PowerManager.WinterArcAnimationPower.ActivateAbility(InstigatorAgent, TargetAgent)

            # else if (CPPowerUp = SLAP_COMP_ANIMATION and not CP.UsedPower?):
            #     CTimer.StartCountdown(PowerManager.SlapCompAnimationPower.AbilityCooldown, 0.0)
            #     spawn. PowerManager.SlapCompAnimationPower.ActivateAbility(InstigatorAgent, TargetAgent)
            #     spawn. CP.UsedRemote(PowerManager.SlapCompAnimationPower.AbilityCooldown)

            else if (CPPowerUp = MUSTARD_ANIMATION and not CTimer.IsActive?):
                if(PowerManager.MustardAnimationPower.WeaponChecker.IsHoldingItem[InstigatorAgent]):
                    CTimer.StartCountdown(PowerManager.MustardAnimationPower.AbilityCooldown)
                    spawn. PowerManager.MustardAnimationPower.ActivateAbility(InstigatorAgent, TargetAgent)

            else if (CPPowerUp = SIXSEVEN_ANIMATION and not CTimer.IsActive?):
                if(PowerManager.SixSevenAnimationPower.WeaponChecker.IsHoldingItem[InstigatorAgent]):
                    CTimer.StartCountdown(PowerManager.SixSevenAnimationPower.AbilityCooldown)
                    spawn. PowerManager.SixSevenAnimationPower.ActivateAbility(InstigatorAgent, TargetAgent)

            # else if (CPPowerUp = SUI_ANIMATION and not CP.UsedPower?):
            #     CTimer.StartCountdown(PowerManager.SuiAnimationPower.AbilityCooldown, 0.0)
            #     spawn. PowerManager.SuiAnimationPower.ActivateAbility(InstigatorAgent)
            #     spawn. CP.UsedRemote(PowerManager.SuiAnimationPower.AbilityCooldown)

            # else if (CPPowerUp = KID_ON_BOAT_ANIMATION and not CP.UsedPower?):
            #     CTimer.StartCountdown(PowerManager.KidOnBoatAnimationPower.AbilityCooldown, 0.0)
            #     spawn. PowerManager.KidOnBoatAnimationPower.ActivateAbility(InstigatorAgent, TargetAgent)
            #     spawn. CP.UsedRemote(PowerManager.KidOnBoatAnimationPower.AbilityCooldown)

            # else if (CPPowerUp = ONE_POUND_FISH_ANIMATION and not CP.UsedPower?):
            #     CTimer.StartCountdown(PowerManager.OnePoundFishAnimationPower.AbilityCooldown, 0.0)
            #     spawn. PowerManager.OnePoundFishAnimationPower.ActivateAbility(InstigatorAgent, TargetAgent)
            #     spawn. CP.UsedRemote(PowerManager.OnePoundFishAnimationPower.AbilityCooldown)

            # else if (CPPowerUp = IMMUNE and not CP.UsedPower?):
            #     CTimer.StartCountdown(PowerManager.ImmunePower.AbilityCooldown,  0.0)
            #     spawn. PowerManager.ImmunePower.ActivateAbilty(TargetAgent)
            #     spawn. CP.UsedRemote(PowerManager.ImmunePower.AbilityCooldown)


    CustomDamagedEvent<private>(CPDidDamage:CustomPlayer,PowerIndex:int,FortDidDamage:fort_character, CPTookDamage:CustomPlayer,
    TookDamagePowerIndex:int,FortTookDamage:fort_character, Amount:float, InstigatorAgent : agent, TargetAgent : agent):void=
            Print("Custom Damaged Event")
            if. PowerIndex = BACKSTAB then. spawn. PowerManager.BackstabPower.BackstabEvent(FortDidDamage,FortTookDamage,Amount,true)
            if. PowerIndex = LIFESTEAL then. PowerManager.LifeStealPower.DamagedEvent(FortDidDamage,Amount)
            if. PowerIndex = ASTRONAUT then. spawn. PowerManager.AstronautPower.DamagedEvent(FortDidDamage,FortTookDamage,Amount)
            if. PowerIndex = DANCE then. PowerManager.DancePower.DamagedEvent(FortDidDamage, FortTookDamage)
            if. PowerIndex = SUPERCHARGED then. spawn. PowerManager.SuperchargedPower.DidDamageEvent(FortDidDamage,FortTookDamage,Amount)
            if. PowerIndex = FASTERDAMAGE then. spawn. PowerManager.MoreSpeedFromDamagePower.DamageEvent(FortDidDamage, Amount)
            else {}

            if. TookDamagePowerIndex = BACKSTAB then. spawn. PowerManager.BackstabPower.BackstabEvent(FortTookDamage,FortDidDamage,Amount,false)
            if. TookDamagePowerIndex = SUPERCHARGED then. spawn. PowerManager.SuperchargedPower.TookDamageEvent(FortTookDamage, Amount)
            if (CTimer := TimerMap[TargetAgent], TookDamagePowerIndex = IMMUNE and not CTimer.IsActive?):
                CTimer.StartCountdown(PowerManager.ImmunePower.AbilityCooldown)
                spawn. PowerManager.ImmunePower.ActivateAbilty(TargetAgent)
            else {}

            if(CPDidDamage.CurrentWeaponID <> -1):
                if (Weapon := SecretWeapons[CPDidDamage.CurrentWeaponID]):
                    spawn. Weapon.AnimationOnPlayerDamage(CPDidDamage, CPTookDamage, CPDidDamage.CurrentWeaponID)
            else{}


    # Player Functions
    OnPlayerSpawned(Agent : agent):void=
        Print("Player Spawned")
        InitPlayer(Agent)
        if (FC := Agent.GetFortCharacter[], Player := player[Agent]):
            FC.SetVulnerability(true)
            FC.SetVulnerability(false)
            FC.SetVulnerability(true)
            # TeamManager.AddPlayerToDefaultTeam(Player)
            # TeleportManager.AgentToLobby(Agent)
            GrantInventory(Agent, false, false)
            # DefaultClass.ChangeClass(Agent)
            if (CTimer := TimerMap[Agent]):
                CTimer.HideTimer()
        if(CP := PlayersMap[Agent]):
            set CP.IsRespawning = false
            if (CP.PowerUp > 0):
                ReturnCurrentPowerToPools(CP)
                RemovePower(CP)
            if (not CP.CustomWeaponVFXLoopActive?):
                spawn. CP.AttachCustomWeaponVFX()

    RespawnAgent(Agent : agent):void=
        if (FortChar := Agent.GetFortCharacter[], Player := player[Agent]):
            Center := GameCircleCenterProp.GetTransform().Translation
            Print("{Center}")
            Dest := RandomPointInCircle(Center, GameCircleRadius, Center.Z)
            
            Player.Respawn(Dest, FortChar.GetTransform().Rotation)
            Print("Teleported to: {Dest}")

    # --- Helper: uniform sample in a disk (r = R*sqrt(u), theta = 2πv) ---
    RandomPointInCircle(Center:vector3, R:float, Z:float):vector3 =
        Theta := GetRandomFloat(0.0, 6.283185307179586)         # 2π
        Rad   := R * Sqrt(GetRandomFloat(0.0, 1.0))            # sqrt(u) for uniform area
        OffsetX := Rad * Cos(Theta)
        OffsetY := Rad * Sin(Theta)
        return vector3{ X:= Center.X + OffsetX, Y:= Center.Y + OffsetY, Z:= Z }


    OnPlayerEliminated(EliminationResult : elimination_result):void=
        spawn. EliminatedPlayerLogic(EliminationResult)
        spawn. EliminatingPlayerLogic(EliminationResult)

    EliminatedPlayerLogic(EliminationResult : elimination_result)<suspends>:void=
        set DeathCounter += 1

        Print("Entering eliminated player logic")
        if:
            EliminatedAgent := EliminationResult.EliminatedCharacter.GetAgent[]
            EliminatedCP := PlayersMap[EliminatedAgent]
            EliminatedPlayer := player[EliminatedAgent]
            EliminatedFC := EliminatedAgent.GetFortCharacter[]
        then:
            if (DeathCounter = 1500):
                EndGameDevice.Enable()
                EndGameDevice.Activate(EliminatedAgent)
                return

            EliminatedPos := EliminationResult.EliminatedCharacter.GetTransform()
            # Get available powers from array that can be spawned in the game
            # Teleport that index in collectibles array to player
            # 1 in 30 chance to spawn xp collectible
            RandomXPChance := GetRandomInt(0, AvailablePowerUps.Length - 1 + CollectibleCoinManager.XPCoinDifficulty)
            if (RandomXPChance = 1):
                CollectibleCoinManager.TeleportXPCollectible(EliminatedAgent)
                # PreviousPowerUp := EliminatedCP.GetPowerUp()
                # if (EliminatedCP.HasPowerUp[]):
                #     Type := DeterminePowerType(PreviousPowerUp)
                #     AddPowerUpToArray(Type, PreviousPowerUp, "Available") 
                #     RemovePowerUpFromArray(Type, PreviousPowerUp, "Used")

            else:
                # Clear the eliminated players powers and put it back into arrays
                PreviousPowerUp := EliminatedCP.GetPowerUp()
                if (EliminatedCP.HasPowerUp[]):
                    Type := DeterminePowerType(PreviousPowerUp)
                    AddPowerUpToArray(Type, PreviousPowerUp, "Available") 
                    RemovePowerUpFromArray(Type, PreviousPowerUp, "Used")

                RandomPowerTypeChance := GetRandomInt(0, AvailablePowerUps.Length + CollectibleCoinManager.ExoticDifficulty)
                var RandomPowerType : PowerType = PowerType.Normal

                #Determine What Coin To Drop
                if (RandomPowerTypeChance = 1):
                    set RandomPowerType = PowerType.Exotic
                    RandomPowerUp := GetRandomPowerUp(RandomPowerType)
                    Print("Our Random Powerup: {RandomPowerUp}", ?Color := color{R := 0.0, G := 1.0, B := 0.0})
                    if (RandomPowerUp > 0):
                        RandomIndex := RandomPowerUp - 1
                        if:
                            RandomIndex < CollectibleCoinManager.Collectibles.Length
                            RandomCollectible := CollectibleCoinManager.Collectibles[RandomIndex] # PowerUps are 1 indexed, arrays are 0 indexed
                            not UsedExoticPowers.Find[RandomPowerUp]
                        then:
                            Print("Found Exotic RandomPowerIndex: {RandomIndex}")
                            set UsedExoticPowers += array{RandomPowerUp}
                            CollectibleCoinManager.TeleportAndDrop(EliminatedAgent, RandomCollectible)
                        else:
                            Print("Could Not Find Exotic Power RandomPowerIndex {RandomIndex}", ?Color := color{R := 1.0, G := 0.0, B := 0.0})
                    else:
                        Print("Could Not Find Exotic Power as RandomPowerUp was {RandomPowerUp}", ?Color := color{R := 1.0, G := 0.0, B := 0.0})
                else:
                    RandomPowerUp := GetRandomPowerUp(RandomPowerType)
                    Print("Our Random Powerup: {RandomPowerUp}", ?Color := color{R := 0.0, G := 1.0, B := 0.0})
                    if (RandomPowerUp > 0):
                        RandomIndex := RandomPowerUp - 1
                        if:
                            RandomIndex < CollectibleCoinManager.Collectibles.Length
                            RandomCollectible := CollectibleCoinManager.Collectibles[RandomIndex] # PowerUps are 1 indexed, arrays are 0 indexed
                            not UsedPowers.Find[RandomPowerUp]
                        then:
                            Print("Found Normal RandomPowerIndex: {RandomIndex}")
                            set UsedPowers += array{RandomPowerUp}
                            CollectibleCoinManager.TeleportAndDrop(EliminatedAgent, RandomCollectible)
                        else:
                            Print("Could Not Find Normal RandomPowerIndex {RandomIndex}", ?Color := color{R := 1.0, G := 0.0, B := 0.0})
                    else:
                        Print("Could Not Find Normal Power as RandomPowerUp was {RandomPowerUp}", ?Color := color{R := 1.0, G := 0.0, B := 0.0})

                #Debug Logs
                if. RandomPowerType = PowerType.Normal then. Print("Available Powers left: {AvailablePowerUps.Length}", ?Color := color{R := 0.0, G := 1.0, B := 0.0})
                else if. RandomPowerType = PowerType.Exotic then. Print("Available Exotic Powers left: {AvailableExoticPowers.Length}", ?Color := color{R := 0.0, G := 1.0, B := 0.0})
            
            # For the ELIMINATED player
            # spawn. DelayDeathHudSFX(EliminatedAgent)
            RemovePower(EliminatedCP)
            UpdatePower(EliminatedCP, EliminatedPlayer, true)
            # TeamManager.AddPlayerToDefaultTeam(EliminatedPlayer)

            # Updating Data And Respawn
            # if. EliminatedAgentData := AgentMap[EliminatedAgent] then. SaveData(EliminatedPlayer, EliminatedAgentData)
            # RespawnTrigger.Trigger(EliminatedAgent)  
            RespawnAgent(EliminatedAgent)

            # UpdateUIPersistent(EliminatedAgent)
            # LoseSFX.Play(EliminatedAgent)

    EliminatingPlayerLogic(EliminationResult : elimination_result)<suspends>:void=
        # -------------------------------------------------------------------------------------#
        # For the ELIMINATING player
        if:
            EliminatedAgent := EliminationResult.EliminatedCharacter.GetAgent[]
            EliminatingAgent := EliminationResult.EliminatingCharacter?.GetAgent[]
            EliminatingPos := EliminationResult.EliminatingCharacter?.GetTransform()
            EliminatorCP := PlayersMap[EliminatingAgent]
            EliminatingPlayer := player[EliminatingAgent]
        then:
            if(EliminatingAgent <> EliminatedAgent):
                # spawn. SpawnDeathItems(EliminatingPos)
                Rand := GetRandomInt(0,5)
                if (MyAudio := CustomElimSFX[0], Rand = 1):
                    MyAudio.Play(EliminatingAgent)
                EliminatedPos := EliminationResult.EliminatedCharacter.GetTransform()
                spawn. SpawnFX(DeathVFXs, EliminatedPos, 0)
                # DeathHUD.Show(EliminatedAgent)
            
            # -----------------------------POWER ELIM EVENTS---------------------------------- #
            PowerIndex := EliminatorCP.GetPowerUp()
            if(PowerIndex = SUPERCHARGED):
                PowerManager.SuperchargedPower.ElimEvent(EliminatingAgent)
            if(PowerIndex = FASTERDAMAGE):
                PowerManager.MoreSpeedFromDamagePower.ElimEvent(EliminatingAgent)
            # -------------------------------------------------------------------------------- #

            # Updating Data
            if. KillerAgentData := AgentMap[EliminatingAgent] then. SaveData(EliminatingPlayer, KillerAgentData)
            # AddGoldOnElim(EliminatingAgent)
            # UpdateUIPersistent(EliminatingAgent)

            #Update Stat Table
            if. KillerAgentData := AgentMap[EliminatingAgent] then. spawn. UpdateStats(EliminatingPlayer, EliminatingAgent, KillerAgentData)

    UpdateStats(EliminatingPlayer : player, EliminatingAgent : agent, KillerAgentData : agent_data)<suspends>:void=
        Sleep(2.0)
        set KillerAgentData.Currency = StatBoardManager.GoldChecker.GetItemCount(EliminatingAgent, 0)
        SaveData(EliminatingPlayer, KillerAgentData)
        #Update Our Map for the table
        if (set KillerAgentData.StatValues["Kills"] += 1.0){}
        if (set KillerAgentData.StatValues["Gold"] = (KillerAgentData.Currency * 1.0)){}
        StatBoardManager.UpdateStatTableCanvas(AgentMap)

    UpdateStats(Agent : agent, AgentData : agent_data):void=
        set AgentData.Currency = StatBoardManager.GoldChecker.GetItemCount(Agent, 0)
        if. Player := player[Agent] then. SaveData(Player, AgentData)
        #Update Our Map for the table
        if (set AgentData.StatValues["Kills"] = 0.0){}
        if (set AgentData.StatValues["Gold"] = (AgentData.Currency * 1.0)){}
        if: 
            Player := player[Agent]
            CurrentPlayerStats := PlayerStatsManager.GetPlayerStats[Player]
            CurrentSteal := CurrentPlayerStats.StealStat.CurrentValue
        then:
            set AgentData.Steals = CurrentSteal
            if (set AgentData.StatValues["Steals"] = (CurrentSteal * 1.0)){}
            
    SpawnDeathItems(EliminatingPos : transform)<suspends>:void=
        Print("Player eliminated")
        Print("Teleporting item drop spawner")
        # TeleportPos := vector3{X:=EliminatingPos.Translation.X + 20.0, Y:=EliminatingPos.Translation.Y, Z:=EliminatingPos.Translation.Z}
        if (EliminatedItemsDropMover.TeleportTo[EliminatingPos.Translation, EliminatingPos.Rotation]):
            EliminatedItemsDropSpawner.Enable()
            EliminatedItemsDropSpawner.SetTimeBetweenSpawns(0.0)
            EliminatedItemsDropSpawner.SetEnableRespawnTimer(true)
            Sleep(0.4)
            EliminatedItemsDropSpawner.SetEnableRespawnTimer(false)
            EliminatedItemsDropSpawner.Disable()

    DeterminePowerType(PowerUp : int):PowerType=
        if (T := PowerCatalog[PowerUp]):
            return T
        else:
            return PowerType.Normal

    DelayDeathHudSFX(EliminatedAgent : agent)<suspends>:void=
        Sleep(1.0)
        # DeathHUD.Show(EliminatedAgent)

    SpawnFX(PropAssets : []creative_prop_asset, Transform : transform, Lvl : int)<suspends>:void=
        Print("spawned players vfx")
        if (Prop := PropAssets[Lvl], SpawnedProp := SpawnProp(Prop, Transform)(0)?):
            Sleep(5.0)
            SpawnedProp.Dispose()
            Print("disposed vfx")

    InitPlayer(Agent : agent):void=
        AddToCustomPlayer(Agent)
        AddToTimerMap(Agent)
        AddToAgentDataMap(Agent)

    AddToCustomPlayer(Agent: agent):void=
        if (PlayerExists := PlayersMap[Agent]):
            return
        else:
            Print("Adding player to custom map (Game Manager)")
            if (FortCharacter := Agent.GetFortCharacter[]):
                FCDamagedEvent := FortCharacter.DamagedEvent().Subscribe(OnPlayerDamage)
                FCDamagedShieldEvent := FortCharacter.DamagedShieldEvent().Subscribe(OnPlayerShieldDamage)
                FCEliminatedEvent := FortCharacter.EliminatedEvent().Subscribe(OnPlayerEliminated)
            CP : CustomPlayer = CustomPlayer{
                MyAgentObj := Agent,
                SecretWeapons := SecretWeapons,
                PinpadTriggers := PinpadTriggers,
                ResetCustomWeaponVFX := ResetCustomWeaponVFX
            }
            for (Index -> Weapon : SecretWeapons):
                if. set CP.HasCustomWeaponVFX[Index] = false
            option. set PlayersMap[Agent] = CP

            # CP.Button1.OnClick().Subscribe(PowerSelected1)
            # CP.Button2.OnClick().Subscribe(PowerSelected2)
            # CP.Button3.OnClick().Subscribe(PowerSelected3)
            # CP.MythicalButton.OnClick().Subscribe(MythicalPowerSelected)
            # CP.ShuffleButton.OnClick().Subscribe(ShuffleSelected)
            # if. Player := player[Agent] then. TeamManager.AddPlayerToDefaultTeam(Player)

    AddToTimerMap(Agent : agent):void= 
         if (PlayerExists := TimerMap[Agent]):
            Print("Player already exists in custom map (Timer)")
        else:
            if(Player := player[Agent]):
                if (PlayerUI := GetPlayerUI[Player]):
                    NewTimer := Timer{}
                    NewTimer.InitUI(PlayerUI)
                    if (set TimerMap[Agent] = NewTimer):
                        NewTimer.HideTimer()
                       Print("Inited Timer in TimerMap")

    AddToAgentDataMap(Agent : agent):void=
        if(AgentData := AgentMap[Agent]):
            #do nothing
            return
        else:
            if(set AgentMap[Agent] = agent_data{}):
                if(AgentData := AgentMap[Agent]):
                    #Stat Table
                    for (StatBoardManager.Stat : StatBoardManager.Stats):
                        if (set AgentData.StatValues[Stat.StatName] = 0.0):

            StatTableCanvas := StatBoardManager.CreateStatTableCanvas()
            if(AgentData := AgentMap[Agent]):
                set AgentData.MaybeStatTableCanvas = option{ StatTableCanvas }
                UpdateStats(Agent, AgentData)
            if(Player := player[Agent], PlayerUI := GetPlayerUI[Player]):
                PlayerUI.AddWidget(StatTableCanvas)
                StatBoardManager.UpdateStatTableCanvas(AgentMap)
                    
            
    OnPlayerRemoved(OutPlayer : player):void=
        if(Agent := agent[OutPlayer], CP := PlayersMap[Agent]):
            UpdatePower(CP, OutPlayer, true)
            ReturnCurrentPowerToPools(CP)
            # remove from players map when player leaves game
            if (ActualPlayer := PlayersMap[Agent]):
                var TempAllPlayersMap:[agent]CustomPlayer = map{}
                for (Key -> Value : PlayersMap, Key <> Agent):
                    set TempAllPlayersMap = ConcatenateMaps(TempAllPlayersMap, map{Key => Value})

                set PlayersMap = TempAllPlayersMap

            if (ActualPlayer := TimerMap[Agent]):
                var TempAllPlayersMap:[agent]Timer = map{}
                for (Key -> Value : TimerMap, Key <> Agent):
                    set TempAllPlayersMap = ConcatenateMaps(TempAllPlayersMap, map{Key => Value})

                set TimerMap = TempAllPlayersMap

            if (ActualPlayer := AgentMap[Agent]):
                var TempAllPlayersMap:[agent]agent_data = map{}
                for (Key -> Value : AgentMap, Key <> Agent):
                    set TempAllPlayersMap = ConcatenateMaps(TempAllPlayersMap, map{Key => Value})

                set AgentMap = TempAllPlayersMap 


        StatBoardManager.UpdateStatTableCanvas(AgentMap)

    UpdatePower(CP:CustomPlayer, Player:player, Death : logic):void=
        if(not Death?):
            if: 
                CurrentPlayerStats := PlayerStatsManager.GetPlayerStats[Player]
                CurrentPower := CurrentPlayerStats.PowerStat.CurrentValue
                var Power : int = CP.PowerUp
            then:
                PlayerStatsManager.RecordPlayerStat(Player, DataType.PowerStat, ?Value := Power)
        else: 
            Print("Set Player power = -1")
            PlayerStatsManager.RecordPlayerStat(Player, DataType.PowerStat, ?Value := -1)

    UpdateSteal(Player : player, StealCount : int):void=
        if: 
            CurrentPlayerStats := PlayerStatsManager.GetPlayerStats[Player]
            CurrentSteal := CurrentPlayerStats.StealStat.CurrentValue
        then:
            PlayerStatsManager.RecordPlayerStat(Player, DataType.Steal, ?Value := StealCount)

    AgentDataToPersistentToTmp(PersistableAgentData : persitable_agent_data)<transacts>: agent_data = 
        return agent_data
        {
            UnlockablePowers := PersistableAgentData.UnlockablePowers,
            UnlockableSecrets := PersistableAgentData.UnlockableSecrets,
            Currency := PersistableAgentData.Currency,
            Steals := PersistableAgentData.Steals
        }

    AgentDataTmpToPersistent(Agent_Data : agent_data)<transacts>:persitable_agent_data=
        return persitable_agent_data
        {
            UnlockablePowers := Agent_Data.UnlockablePowers,
            UnlockableSecrets := Agent_Data.UnlockableSecrets,
            Currency := Agent_Data.Currency,
            Steals := Agent_Data.Steals
        }

    UpdateUIPersistent(Agent : agent):void=
        if(AgentData := AgentMap[Agent], ScreenCanvas := AgentData.MaybeScreenCanvas?):
            Print("Found Canvas")
            WinsTextBlockIndex := 3
            PlayersLeftBlockIndex := 4
            CurrencyBlockIndex := 5
            if(WinsTextBlock := text_block[ScreenCanvas.Slots[WinsTextBlockIndex].Widget]):
                # WinsTextBlock.SetText(S2M("{AgentData.Kills}"))

            if(PlayersLeftBlock := text_block[ScreenCanvas.Slots[PlayersLeftBlockIndex].Widget]):
                PlayersLeftBlock.SetText(S2M("Players: {PlayersInBoxFight}"))

            if(CurrencyBlock := text_block[ScreenCanvas.Slots[CurrencyBlockIndex].Widget]):
                CurrencyBlock.SetText(S2M("{AgentData.Currency}"))
        
    CreateScreenCanvas():canvas=
        var CustomCanvasSlots: []canvas_slot = array{}
        set CustomCanvasSlots += array
        {
            CanvasSlot0 := canvas_slot:
                Anchors := anchors{Minimum := vector2{ X:= 1.0, Y:= 0.5}, Maximum := vector2{ X:=1.0, Y := 0.5}}
                Offsets := margin{Top := -10.0, Left := -120.0, Right := 0.0, Bottom := 100.0}
                Alignment := vector2{X := 0.5, Y := 0.5 }
                SizeToContent := true
                ZOrder := 1
                Widget := texture_block{DefaultImage := CustomAssets.DisplayCrownText, DefaultDesiredSize := vector2{X:= 230.0, Y:= 220.0} }

            CanvasSlot1 := canvas_slot:
                Anchors := anchors{Minimum := vector2{ X:= 1.0, Y:= 0.5}, Maximum := vector2{ X:=1.0, Y := 0.5}}
                Offsets := margin{Top := -130.0, Left := -150.0, Right := 0.0, Bottom := 100.0}
                Alignment := vector2{X := 0.5, Y := 0.5 }
                SizeToContent := true
                ZOrder := 1
                Widget := texture_block{DefaultImage := CustomAssets.PlayerCounter, DefaultDesiredSize := vector2{X:= 300.0, Y:= 110.0} }

            CanvasSlot2 := canvas_slot:
                Anchors := anchors{Minimum := vector2{ X:= 1.0, Y:= 0.5}, Maximum := vector2{ X:=1.0, Y := 0.5}}
                Offsets := margin{Top := 100.0, Left := -120.0, Right := 0.0, Bottom := 100.0}
                Alignment := vector2{X := 0.5, Y := 0.5 }
                SizeToContent := true
                ZOrder := 1
                Widget := texture_block{DefaultImage := CustomAssets.DisplayCoinText, DefaultDesiredSize := vector2{X:= 230.0, Y:= 220.0} }
        }
        
        set CustomCanvasSlots += array
        {
            CanvasSlot3 := canvas_slot:
                Anchors := anchors{Minimum := vector2{ X:= 1.0, Y:= 0.5}, Maximum := vector2{ X:=1.0, Y := 0.5}}
                Offsets := margin{Top := -10.0, Left := -90.0, Right := 0.0, Bottom := 0.0}
                Alignment := vector2{X := 0.5, Y := 0.5 }
                SizeToContent := true
                ZOrder := 1
                Widget := text_block{DefaultText := S2M("Crown Wins"), DefaultTextColor := NamedColors.White, DefaultShadowColor := NamedColors.Black, 
                DefaultShadowOpacity := 1.0, DefaultShadowOffset := option{vector2{X := 1.5, Y := 1.5}}}

            CanvasSlot4 := canvas_slot:
                Anchors := anchors{Minimum := vector2{ X:= 1.0, Y:= 0.5}, Maximum := vector2{ X:= 1.0, Y := 0.5}}
                Offsets := margin{Top := -130.0, Left := -130.0, Right := 0.0, Bottom := 0.0}
                Alignment := vector2{X := 0.5, Y := 0.5 }
                SizeToContent := true
                ZOrder := 1
                Widget := text_block{DefaultText := S2M("Players: 0"), DefaultTextColor := NamedColors.White, DefaultShadowColor := NamedColors.Gray, 
                DefaultShadowOpacity := 0.5, DefaultShadowOffset := option{vector2{X := 1.5, Y := 1.5}}}

            CanvasSlot5 := canvas_slot:
                Anchors := anchors{Minimum := vector2{ X:= 1.0, Y:= 0.5}, Maximum := vector2{ X:= 1.0, Y := 0.5}}
                Offsets := margin{Top := 100.0, Left := -90.0, Right := 0.0, Bottom := 0.0}
                Alignment := vector2{X := 0.5, Y := 0.5 }
                SizeToContent := true
                ZOrder := 1
                Widget := text_block{DefaultText := S2M("Currency"), DefaultTextColor := NamedColors.White, DefaultShadowColor := NamedColors.Black, 
                DefaultShadowOpacity := 1.0, DefaultShadowOffset := option{vector2{X := 1.5, Y := 1.5}}}
        }

        CustomCanvas : canvas = canvas:
            Slots:= CustomCanvasSlots

        return CustomCanvas

