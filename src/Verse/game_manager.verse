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
