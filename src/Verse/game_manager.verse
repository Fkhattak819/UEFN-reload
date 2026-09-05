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

