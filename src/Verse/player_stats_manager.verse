using { /Verse.org/Simulation }
# Player Stat manager --------------------------------------------------------------------


 # Represents an abstract stat to update using RecordPlayerStat.
 # The class has the unique specifier to make instances of the class comparable.
 # The class has the computes specifier to be able to instantiate it at module-scope.
 # The class has the abstract specifier so it cannot be instantiated directly, and
 # requires subclasses to implement any non-initialized functions, like DebugString().
 stat_type := class<computes><abstract>:
    DebugString():string

# This uses instances of stat_type subclasses instead of the enum type
# so you can add more stat_types after the initial published version of the project.    
StatType := module:

    kill_stat<public> := class<computes>(stat_type):
        DebugString<override>():string =   "Kills"
    death_stat<public> := class<computes>(stat_type):
        DebugString<override>():string = "Deaths"    
    elo_stat<public> := class<computes>(stat_type):
        DebugString<override>():string = "Deaths"     
    version_stat<public> := class<computes>(stat_type):
        DebugString<override>():string = "Version"
    pistol_kill_stat<public> := class<computes>(stat_type):
        DebugString<override>():string = "PistolKills"
    shotgun_kill_stat<public> := class<computes>(stat_type):
        DebugString<override>():string = "ShotGunKills"
    rifle_kill_stat<public> := class<computes>(stat_type):
        DebugString<override>():string = "RifleKills"
    smg_kill_stat<public> := class<computes>(stat_type):
        DebugString<override>():string = "SmgKills"
    sniper_kill_stat<public> := class<computes>(stat_type):
        DebugString<override>():string = "SniperKills"
    melee_kill_stat<public> := class<computes>(stat_type):
        DebugString<override>():string = "MeleeKills"
    headshot_kill_stat<public> := class<computes>(stat_type):
        DebugString<override>():string = "HeadShotKills"
    jump_stat<public> := class<computes>(stat_type):
        DebugString<override>():string = "Jumps"
    run_stat<public> := class<computes>(stat_type):
        DebugString<override>():string = "Run"
    emote_stat<public> := class<computes>(stat_type):
        DebugString<override>():string = "Emote"
    trolling_stat<public> := class<computes>(stat_type):
        DebugString<override>():string = "Trolling"
    weapon_stat<public> := class<computes>(stat_type):
        DebugString<override>():string = "Weapon"    
    prestige_stat<public> := class<computes>(stat_type):
        DebugString<override>():string  = "Prestige"
    Day_To_Claim<public> := class<computes>(stat_type):
        DebugString<override>():string  = "Day_To_Claim"
    Total_Days_Claimed<public> := class<computes>(stat_type):
        DebugString<override>():string  = "Total_Days_Claimed"
    Last_Claim_Epoch_Seconds<public> := class<computes>(stat_type):
        DebugString<override>():string  = "LastClaimEpochSeconds"
    Days_Claimed<public> := class<computes>(stat_type):
        DebugString<override>():string  = "DaysClaimedChest" 
    #NEW
    power_stat<public> := class<computes>(stat_type):
        DebugString<override>():string  = "PowerPlayerHas"
    total_time_stat<public> := class<computes>(stat_type):
        DebugString<override>():string  = "PlayerTotalTimeOnMap"
    steal_stat<public> := class<computes>(stat_type):
        DebugString<override>():string  = "Steal"

    # The stat_type instances you can use in your experience.
    Kills<public>:kill_stat = kill_stat{}
    Deaths<public>:death_stat = death_stat{}
    Elo<public>:elo_stat = elo_stat{}
    Version<public>:version_stat = version_stat{}
    PistolKills<public>:pistol_kill_stat = pistol_kill_stat{}
    ShotGunKills<public>:shotgun_kill_stat = shotgun_kill_stat{}
    RifleKills<public>:rifle_kill_stat = rifle_kill_stat{}
    SmgKills<public>:smg_kill_stat = smg_kill_stat{}
    SniperKills<public>:sniper_kill_stat = sniper_kill_stat{}
    MeleeKills<public>:melee_kill_stat = melee_kill_stat{}
    HeadShotKills<public>:headshot_kill_stat = headshot_kill_stat{}
    Jumps<public>:jump_stat = jump_stat{}
    Run<public>:run_stat = run_stat{}
    Emote<public>:emote_stat = emote_stat{}
    Trolling<public>:trolling_stat = trolling_stat{}
    Weapon<public>:weapon_stat = weapon_stat{}
    Prestige<public>:prestige_stat = prestige_stat{}
    DayToClaim<public>:Day_To_Claim = Day_To_Claim{}
    TotalDaysClaimed<public>:Total_Days_Claimed = Total_Days_Claimed{}
    LastClaimEpochSeconds<public>:Last_Claim_Epoch_Seconds = Last_Claim_Epoch_Seconds{}
    DaysClaimedChest<public>:Days_Claimed = Days_Claimed{}
    #New
    PowerStat<public>:power_stat = power_stat{}
    TotalTimeStat<public>:total_time_stat = total_time_stat{}
    Steal<public>:steal_stat = steal_stat{}



player_stats_table := class<final><persistable>:
    # The version of the current stats table.
    Version: int = 1

    # The number of Kills for a player.
    Kills:player_stat = player_stat{}

    # The number of Deaths for a player.
    Deaths:player_stat = player_stat{}

    Elo: player_stat = player_stat{}

    PistolKills: player_stat = player_stat{}

    ShotGunKills: player_stat = player_stat{}

    RifleKills: player_stat = player_stat{}

    SmgKills: player_stat = player_stat{}

    SniperKills: player_stat = player_stat{}

    MeleeKills: player_stat = player_stat{}

    HeadShotKills: player_stat = player_stat{}

    Jumps: player_stat = player_stat{}

    Run: player_stat = player_stat{}

    Emote: player_stat = player_stat{}

    Trolling: player_stat = player_stat{}

    Weapon: player_stat = player_stat{}
    
    Prestige: player_stat = player_stat{}
    # The number of days the player has claimed   Resets every 100 days
    TotalDaysClaimed: player_stat = player_stat{}

    DaysClaimedChest: player_stat = player_stat{}

    # The current day the player can claim  Resets every 7 days
    CurrentDayToClaim: player_stat = player_stat{}

    # The last time the player claimed a reward
    LastClaimEpochSeconds: player_stat = player_stat{}

    #NEW
    PowerStat: player_stat = player_stat{}
    # Total time player has played on the map
    TotalTimeStat: player_stat = player_stat{}
    
    StealStat: player_stat = player_stat{}

    
player_stat := class<final><persistable>:
    # The current value of the player's stat.
    CurrentValue:int = 0

    # The highest value achieved so far.

    HighestValue: int = 0
    # Returns either the NewValue or HighestValue,
    # whichever is higher.
  
MakeUpdatedPlayerStat<constructor>(OldStats:player_stat, NewValue:int)<transacts> := player_stat:
    CurrentValue := NewValue
         
    # Maps players to a table of their player stats.    
MakePlayerStatsTable<constructor>(OldTable:player_stats_table)<transacts> := player_stats_table:
        Version := OldTable.Version
        Kills := OldTable.Kills
        Deaths := OldTable.Deaths
        Elo := OldTable.Elo
        PistolKills := OldTable.PistolKills
        ShotGunKills := OldTable.ShotGunKills
        RifleKills := OldTable.RifleKills
        SmgKills := OldTable.SmgKills
        SniperKills := OldTable.SniperKills
        MeleeKills := OldTable.MeleeKills
        HeadShotKills := OldTable.HeadShotKills
        Jumps := OldTable.Jumps
        Run := OldTable.Run
        Emote := OldTable.Emote
        Trolling := OldTable.Trolling
        Weapon := OldTable.Weapon
        Prestige := OldTable.Prestige
        TotalDaysClaimed := OldTable.TotalDaysClaimed
        CurrentDayToClaim := OldTable.CurrentDayToClaim
        LastClaimEpochSeconds := OldTable.LastClaimEpochSeconds
        DaysClaimedChest := OldTable.DaysClaimedChest
        #NEW
        PowerStat := OldTable.PowerStat
        TotalTimeStat := OldTable.TotalTimeStat
        StealStat := OldTable.StealStat
        
        
DataType := enum:
    Kills
    Deaths
    Elo
    PistolKills
    ShotGunKills
    RifleKills
    SmgKills
    SniperKills
    MeleeKills
    HeadShotKills
    Jumps
    Run
    Emote
    Trolling
    Weapon
    Prestige
    Version
    TotalDaysClaimed  
    CurrentDayToClaim 
    LastClaimEpochSeconds 
    DaysClaimedChest 
    #NEW
    PowerStat
    TotalTime
    Steal

# Manages and updates player_stat_tables for each player.
player_stats_manager := class():

    # Return the player_stats_table for the provided Agent.
    GetPlayerStats(Agent:agent)<decides><transacts>:player_stats_table=
        var PlayerStats:player_stats_table = player_stats_table{}
        if:
            Player := player[Agent]
            Player.IsActive[]
            PlayerStatsTable := PlayerStatsMap[Player]
            set PlayerStats = MakePlayerStatsTable(PlayerStatsTable)
        PlayerStats

    # Initialize stats for all current players.
    InitializeAllPlayers(Players:[]player):void =
        for (Player : Players):
            InitializePlayer(Player)

    # Initialize stats for the given player.
    InitializePlayer(Player:player):void=
        if:
            Player.IsActive[]
            not PlayerStatsMap[Player]
            set PlayerStatsMap[Player] = player_stats_table{}

    # Update the given stat for the given player by creating a new
    # player_stats_table and setting it in the PlayerStatsMap.
    RecordPlayerStat(Agent:agent, Stat:DataType, ?Value : int = 0 ):void=
        if:
            Player := player[Agent]
            Player.IsActive[]
            PlayerStatsTable := PlayerStatsMap[Player]
            if(Stat = DataType.Elo):
                EloStat := PlayerStatsTable.Elo
                # Create a new player_stats_table with the updated score,
                # then set that table in the PlayerStatsMap.
                set PlayerStatsMap[Player] = player_stats_table:
                    Elo := MakeUpdatedPlayerStat(EloStat, Value)
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
            else if(Stat = DataType.Kills):
                KillStat := PlayerStatsTable.Kills
                # Create a new player_stats_table with the updated wins,
                # then set that table in the PlayerStatsMap.
                set PlayerStatsMap[Player] = player_stats_table:
                    Kills := MakeUpdatedPlayerStat(KillStat, Value)
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
            else if(Stat = DataType.Deaths):
                DeathStat := PlayerStatsTable.Deaths
                # Create a new player_stats_table with the updated wins,
                # then set that table in the PlayerStatsMap.
                set PlayerStatsMap[Player] = player_stats_table:
                    Deaths := MakeUpdatedPlayerStat(DeathStat, Value)
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
            else if(Stat = DataType.Version):
                set PlayerStatsMap[Player] = player_stats_table:
                    Version := Value
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
            else if(Stat = DataType.PistolKills):
                PistolKillStat := PlayerStatsTable.PistolKills
                set PlayerStatsMap[Player] = player_stats_table:
                    PistolKills := MakeUpdatedPlayerStat(PistolKillStat, Value)
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
            else if(Stat = DataType.ShotGunKills):
                ShotGunKillStat := PlayerStatsTable.ShotGunKills
                set PlayerStatsMap[Player] = player_stats_table:
                    ShotGunKills := MakeUpdatedPlayerStat(ShotGunKillStat, Value)
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
            else if(Stat = DataType.RifleKills):
                RifleKillStat := PlayerStatsTable.RifleKills
                set PlayerStatsMap[Player] = player_stats_table:
                    RifleKills := MakeUpdatedPlayerStat(RifleKillStat, Value)
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
            else if(Stat = DataType.SmgKills):
                SmgKillStat := PlayerStatsTable.SmgKills
                set PlayerStatsMap[Player] = player_stats_table:
                    SmgKills := MakeUpdatedPlayerStat(SmgKillStat, Value)
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
            else if(Stat = DataType.SniperKills):
                SniperKillStat := PlayerStatsTable.SniperKills
                set PlayerStatsMap[Player] = player_stats_table:
                    SniperKills := MakeUpdatedPlayerStat(SniperKillStat, Value)
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
            else if(Stat = DataType.MeleeKills):
                MeleeKillStat := PlayerStatsTable.MeleeKills
                set PlayerStatsMap[Player] = player_stats_table:
                    MeleeKills := MakeUpdatedPlayerStat(MeleeKillStat, Value)
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
            else if(Stat = DataType.HeadShotKills):
                HeadShotKillStat := PlayerStatsTable.HeadShotKills
                set PlayerStatsMap[Player] = player_stats_table:
                    HeadShotKills := MakeUpdatedPlayerStat(HeadShotKillStat, Value)
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
            else if(Stat = DataType.Jumps):
                JumpStat := PlayerStatsTable.Jumps
                set PlayerStatsMap[Player] = player_stats_table:
                    Jumps := MakeUpdatedPlayerStat(JumpStat, Value)
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    
            else if(Stat = DataType.Run):
                RunStat := PlayerStatsTable.Run
                set PlayerStatsMap[Player] = player_stats_table:
                    Run := MakeUpdatedPlayerStat(RunStat, Value)
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    
            else if(Stat = DataType.Emote):
                EmoteStat := PlayerStatsTable.Emote
                set PlayerStatsMap[Player] = player_stats_table:
                    Emote := MakeUpdatedPlayerStat(EmoteStat, Value)
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    
            else if(Stat = DataType.Trolling):
                TrollingStat := PlayerStatsTable.Trolling
                set PlayerStatsMap[Player] = player_stats_table:
                    Trolling := MakeUpdatedPlayerStat(TrollingStat, Value)
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    
            else if(Stat = DataType.Weapon):
                WeaponStat := PlayerStatsTable.Weapon
                set PlayerStatsMap[Player] = player_stats_table:
                    Weapon := MakeUpdatedPlayerStat(WeaponStat, Value)
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    
            else if(Stat = DataType.Prestige):
                PrestigeStat := PlayerStatsTable.Prestige
                set PlayerStatsMap[Player] = player_stats_table:
                    Prestige := MakeUpdatedPlayerStat(PrestigeStat, Value)
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    
            else if(Stat = DataType.TotalDaysClaimed):
                TotalDaysClaimedStat := PlayerStatsTable.TotalDaysClaimed
                set PlayerStatsMap[Player] = player_stats_table:
                    TotalDaysClaimed := MakeUpdatedPlayerStat(TotalDaysClaimedStat, Value)
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    
            else if(Stat = DataType.CurrentDayToClaim):
                CurrentDayToClaimStat := PlayerStatsTable.CurrentDayToClaim
                set PlayerStatsMap[Player] = player_stats_table:
                    CurrentDayToClaim := MakeUpdatedPlayerStat(CurrentDayToClaimStat, Value)
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    
            else if(Stat = DataType.LastClaimEpochSeconds):
                LastClaimEpochSecondsStat := PlayerStatsTable.LastClaimEpochSeconds
                set PlayerStatsMap[Player] = player_stats_table:
                    LastClaimEpochSeconds := MakeUpdatedPlayerStat(LastClaimEpochSecondsStat, Value)
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                Print ("LastClaimEpochSecondsStat: {Value}  - Player Stats")
            else if(Stat = DataType.DaysClaimedChest):
                DaysClaimedChestStat := PlayerStatsTable.DaysClaimedChest
                set PlayerStatsMap[Player] = player_stats_table:
                    DaysClaimedChest := MakeUpdatedPlayerStat(DaysClaimedChestStat, Value)
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    
            #NEW
            else if(Stat = DataType.PowerStat):
                Power := PlayerStatsTable.PowerStat
                set PlayerStatsMap[Player] = player_stats_table:
                    PowerStat := MakeUpdatedPlayerStat(Power, Value)
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    
            else if(Stat = DataType.TotalTime):
                TotalTime := PlayerStatsTable.TotalTimeStat
                set PlayerStatsMap[Player] = player_stats_table:
                    TotalTimeStat := MakeUpdatedPlayerStat(TotalTime, Value)
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    
            else if(Stat = DataType.Steal):
                Steal := PlayerStatsTable.StealStat
                set PlayerStatsMap[Player] = player_stats_table:
                    StealStat := MakeUpdatedPlayerStat(Steal, Value)
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                  

                    
            else:
                Print("Stat type not recognized.") 
                    


var PlayerStatsMap:weak_map(player, player_stats_table) = map{}