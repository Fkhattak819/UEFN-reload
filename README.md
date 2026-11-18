# One-v-One Reload

Verse gameplay code for a Fortnite Reload-style arena map built in UEFN (Unreal Editor for Fortnite). Each player holds one power at a time, no two players hold the same one, and eliminations drop powers back into the arena for someone else to grab.

This repository holds the Verse source only: about 9,000 lines in `src/Verse`. The map, its devices and its assets live in the UEFN project and are not included, so it will not build on its own. It is here to be read.

## How a round plays

`game_manager.verse` is the one creative device that runs the match.

1. **Startup.** `InitPowerCatalog` registers every power id with a rarity: 38 normal, 5 exotic and 5 mythic. `RebuildPoolsFromCatalog` derives the available pools from that catalog, so the catalog is the single source of truth. `OnBegin` then subscribes to spawners, collectibles, pin pads, minigame unlocks and the rarity timers.
2. **Spawning.** A player spawns with a random loadout and no power. Each player gets a `CustomPlayer` state object and their own cooldown `Timer` on the HUD.
3. **Getting a power.** Powers enter the arena as collectibles. An elimination drops one where the player fell, usually a normal power with a small chance of an exotic or an XP coin. Exotic and mythic powers also fall from the sky on timers. A collectible that nobody picks up despawns after 35 seconds and returns to its pool.
4. **Using a power.** Picking a collectible up calls `AssignPowerup`, which swaps the player's class, inventory and HUD for that power. From there a power fires in one of three ways:
   - passively, from the moment it is assigned (extra jumps, speed, x-ray);
   - from the remote item, where `OnPrimaryClick` checks the cooldown and spawns the power's async ability;
   - on hit, where `OnPlayerDamage` and `OnPlayerShieldDamage` dispatch for powers such as pull, knockback, freeze and lifesteal.
5. **Losing it.** When a player is eliminated or leaves, their power goes back to the available pool.

Because a power id must only ever be in one place (held by a player, lying in the world, or available), `ValidatePowerInvariants` walks every bucket and reports any id that appears twice. It is wired to a debug button in the map.

## Anatomy of a power

Every power is a `class<concrete>` in its own `zpower_*.verse` file, with its devices exposed as `@editable` fields:

```verse
freeze_power := class<concrete>(power_base):
    @editable IceSFX : audio_player_device = audio_player_device{}
    @editable VFX : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable AbilityCooldown : float = 10.0

    ActivateAbility(Agent : agent, TargetFort : fort_character, TargetAgent : agent)<suspends>:void=
        VFX.Pickup(TargetAgent)
        IceSFX.Play(TargetAgent)
        TargetFort.PutInStasis(stasis_args{})
        Sleep(4.0)
        TargetFort.ReleaseFromStasis()
```

(Trimmed from `zpower_freeze.verse`.)

There are three base classes in `power_base.verse` and `zpower_animation.verse`:

| Base | Used by | Adds |
| :-- | :-- | :-- |
| `power_base` | Most powers | The HUD message shown when the power is assigned. |
| `remote_power_base` | The 8 aimed powers | Aim tracking. A loop compares the player's view direction with the direction to each enemy using a dot product, and when one is within `AngleThreshold` degrees (14 by default) and 150 m it moves a beacon onto them and records them as the target. |
| `animation_power_base` | The emote powers | Shared logic with three variants: the emote plays on the user, on the target, or on both. |

`power_manager.verse` is a plain class with one `@editable` field per power. `game_manager` holds a single `power_manager`, so every power's devices show up nested under one device in the UEFN Details panel.

Adding a power takes four edits: the new `zpower_*.verse` class, a field in `power_manager`, an id constant and a `RegisterPower` call in `game_manager`, and a branch in `AssignPowerup` plus whichever trigger handler it uses.

## The rest of the code

| File | What it does |
| :-- | :-- |
| `custom_player.verse` | Per-player state: current power, lobby and respawn flags, and the loop that attaches VFX to a held secret weapon. |
| `timer.verse` | The per-player cooldown widget ("AVAILABLE IN: 3.2"). |
| `collectible_coin_manager.verse` | Power collectibles: the rarity enum, the despawn race, and dropping a collectible at a position or from the sky. |
| `secret_weapon_manager.verse` | Seven unlockable weapons. Each has a pluggable `secret_weapon_power` behavior chosen in the editor, so a new weapon is a new subclass and no change to the manager. |
| `pin_pad_manager.verse` | An on-screen pin pad built from Verse UI widgets. A correct code unlocks a secret weapon or sends the player to the minigame that earns it. |
| `custom_minigame_manager.verse` | Shark, orca and vehicle minigames that unlock weapons. |
| `player_stats_manager.verse` | Persistable per-player stat tables (kills, deaths, Elo, per-weapon kills and more). |
| `rank_ui_manager.verse` | Elo ranks: +5 per kill and -2 per death by default, 19 configurable thresholds, promotion and demotion sounds, and a rank HUD. |
| `stats_leaderboard_ui_manager.verse` | The in-match stat table for kills, gold and steals. |
| `out_of_bounds_manager.verse` | Clamps any teleport destination to the arena, using two corner props as the bounds. |
| `tick_rate_manager.verse` | A debug device that graphs server tick rate on screen. |
| `teleport_manager.verse`, `team_manager.verse`, `immunity_manager.verse`, `special_effects_manager.verse`, `utils.verse` | Lobby teleports, team balancing, brief invulnerability effects and small helpers. |

`index_book_manager.verse`, `live_event_manager.verse` and `vehicle_manager.verse` are empty placeholders.

## Built with

Verse · Unreal Editor for Fortnite

More of my Fortnite work is on [my portfolio](https://fahd-personal-website.vercel.app/my-work/game-developer).
