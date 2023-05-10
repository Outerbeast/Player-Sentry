# Installation
To install download the package from the "Releases" section on the right and extract into svencoop_addon

- Add this cvar in your map cfg: `map_script player_sentry`
OR
- Load this script via trigger_script entity in your map
```"classname" "trigger_script"```
```"m_iszScriptFile" "player_sentry"```
OR
- Add this in your map script header `#include "player_sentry"`

# Usage
- Equip the pipewrench then use Tertiary attack key to place your sentry. Creating a sentry will cost you your remaining armor for its base health.
- You need to have at least 10 armor to be able to create a sentry. Only one sentry can be deployed at a time. You cannot build a sentry in water or while you are in water (for safety reasons).
- If it appears that the sentry didn't spawn, the set position is likely not valid. Find a better place to put your sentry and try again.
- You can pick up and move the sentry to a new location: press USE while in front of your sentry then press it again to place it while the pipewrench is active. You can delete your sentry while carrying it by pressing Reload. If you die while carrying your sentry then the sentry will be destroyed.

## weapon_sentry
This script also allows you to use a disposable sentry via weapon_sentry. You should be familiar with weapon_tripmine already - this weapon is used just like that. You can build as many sentries so long as you can get ammo for the weapon_sentry. It will not cost armour to build, though the base health of the sentry will remain at 80 HP.
To enable, you need to create your own map script file and then register the weapon in MapInit, using the this function

```bool WeaponRegister(string strViewMdl = "", string strWorldMdl = "", string strPlayerMdl = "")```

This is done as follows:-
```
#include "player_sentry"

void MapInit()
{
    PLAYER_SENTRY::WeaponRegister();
}
```
Save the map script file as `<yourfilename>.as` and ensure you add this to your cfg.
The register function accepts custom view/world/player models which will override the default models used by weapon_sentry.

# Customisation
These CVar variables are available to be changed to customise how the sentry is used. You can add these to your map cfg.
CVars must be added in this format: `as_command ps_cvar`

| CVar                  | Description |
| :------------:        | :------------: |
|`ps_displayname`       |Set the sentry's hudinfo name prefix, `"Sentry"` is default.|
|`ps_weapon`            |Classname of the weapon used to spawn the sentry instead of the default weapon_pipewrench. It can be a custom weapon.|
|`ps_build_fx`          |Set whether building the sentry draws build effects|
|`ps_carry_fx`          |Set whether carrying the sentry draws carrying effects|
|`ps_use_armor_cost`    |Set whether building a sentry costs armour|
|`ps_build_button`      |Set the button used to build a sentry. Choices are `primary_attack`, `secondary_attack` and `tertiary_attack`|
|`ps_attack_range`      |Set a custom attack range for the sentry|
|`ps_health_multiplier` |Multiplier for sentry base health|
|`ps_attack_range`      |Set sentry attack range. Default is 1200.|

# Mapping
**Building restriction zones**
Specific building zones can be created to restrict where player can or can't build their sentry.
The zones can be made out of a brush entity like an invisible func_illusionary, and using any of the following names for this brush entity can allow for filtering behaviour:
- `player_sentry_allowed_zone` This will only permit sentries being built/placed inside any zone entities using this name.
- `player_sentry_restricted_zone` This will prevent sentries being built/placed inside any zone entities using this name.
The zone entities can use `target` key, which will trigger a target when a sentry is attempting to be built when not allowed.

**Special Targetnames**
Special targetnames exist that can be applied to entities to automatically trigger them when the associated event occurs:
- `player_sentry_built` is triggered when a player successfully builds a sentry
- `player_sentry_killed` is triggered when a sentry is killed
- `player_sentry_destroyed` is triggered when a sentry is destroyed

In all cases `!activator` is the player and `!caller` is the sentry itself.

**weapon_sentry**
weapon_sentry supports several keyvalues and flags to customise the weapon.
Load `weapon_sentry.fgd` into your map editor of choice so you are able to add weapon_sentry entities into your map.

These standard weapon keys and flags are usable, which you should already be familiar with. For further information visit https://wiki.svencoop.com/Weapons#Keyvalues

Keys
- `movetype`
- `wpn_v_model`
- `wpn_w_model`
- `wpn_p_model`
- `CustomSpriteDir`
- `IsNotAmmoItem`
- `m_flCustomRespawnTime`
- `exclusivehold`
- `target`
- `killtarget`
- `delay`

The custom weapon entity has these additional keys that are from monster_sentry that are settings for the sentry itself:
- `health`
- `displayname`
- `classify`
- `attackrange`

Flags
- `128` : TOUCH only
- `256` : USE only
- `512` : Can use w/o LoS
- `1024` : Disable respawn

# Scripting
Some functions and variables are available for further customisation of your sentry. 
All are included within the `PLAYER_SENTRY` namespace.

#### Variables
Modifiable variables are found in `constants.as`.
Names of each variable should be self explanatory what their purpose is, but if unsure check the variables' corresponding cvar description. 
For the purpose of keeping this guide brief, the usage for each variable will not be covered.

#### Event Callbacks
Callbacks are also supported for certain events such as sentry building, everytime a player sentry thinks or when a sentry is killed or destroyed.
If you know how to use hooks available from the SC AngelScript API, you should find this system very familiar.

To register a callback, use this function:
```bool SetSentryCallback(int iType, ref@ fn)```

`iEventType` refers to the event type that you are registering to:

| iEventType | Description |
| :------------: | :------------: |
|`Built`|Sentry built event|
|`Think`|Sentry think event|
|`Killed`|Sentry killed event|
|`Destroyed`|Sentry destroyed event|

`fn` is a handle to a function that you are registering to the selected callback, ensuring that the function is valid and the signature matches the required type. (Check the signatures section further down)

Example below registers a function `SentryIsBuilt` to `Built` callback:
```
bool blSentryIsBuilt = PLAYER_SENTRY::SetSentryCallback( PLAYER_SENTRY::Built, @SentryIsBuilt );

void SentryIsBuilt(CBaseMonster@ pSentry, CBasePlayer@ pOwner)
{
    if( pSentry is null || pOwner is null )
        return;

    g_PlayerFuncs.ShowMessage( pOwner, "You built a sentry." );
}
```
Delegates can be used to register methods, where `fn` is `SentryBuiltEvent( obj.Method )` as an example.

To remove a function registered to a callback, use this function:
```void RemoveSentryCallback(int iType, ref@ fn)```
Omitting the `fn` parameter will remove all existing callbacks of that `iType`.

**Signatures**
- *SentryBuiltEvent* `Built`
```void SentryBuilt(CBaseMonster@ pSentry, CBasePlayer@ pOwner)```
Called when a sentry is built successfully. pOwner is the player that built this pSentry.

- *SentryThinkEvent* `Think` 
```void SentryThink(CBaseMonster@ pSentry, CBasePlayer@ pOwner)```
Called while a sentry is alive. pOwner is the player that built this pSentry.
Note that this will not be called for any sentries built via weapon_sentry

- *SentryKilledEvent* `Killed` 
```void SentryKilled(CBaseMonster@ pSentry, CBasePlayer@ pOwner)```
Called when a sentry is killed. pOwner is the player that built this pSentry.

- *SentryDestroyedEvent* `Destroyed`
```void SentryDestroyed(CBaseMonster@ pSentry, CBasePlayer@ pOwner, int& in iReason)```
Called when a sentry is destroyed, which can happen for a number of reasons.
pOwner is the player that built this pSentry, however pOwner is not guaranteed to be valid at this point. Check if pOwner is valid first before using.
`iReason` returns a value corresponding to how the sentry was destroyed:

| iReason | Description |
| :------------: | :------------: |
|`Death`|Sentry selfdestruction upon being killed|
|`Deletion`|Player deletes the sentry when picked up (or player dies while carrying)|
|`Placement_Invalid`|Sentry is placed in a spot where its not supposed to exist|
|`Owner_Disconnect`|The player who owns this sentry leaves the game|

# Credits
- Zurd0- Models
- SV BOY- Sprites
- H2,  KernCore- Support
- AlexCorruptor- Testing
