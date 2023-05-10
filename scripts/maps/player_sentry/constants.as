namespace PLAYER_SENTRY
{

enum Event
{
    Built       = 0x0045,
    Think       = 0x01A4,
    Killed      = 0x013A,
    Destroyed   = 0x0539
};

enum sentrydestroyed_states
{
    None,
    Death,
    Deletion,
    Placement_Invalid,
    Owner_Disconnect
};

enum sentryweapon_anims
{
    SENTRY_IDLE = 0,
    SENTRY_FIDGET,
    SENTRY_DRAW,
    SENTRY_DROP
};

enum sentryweapon_mdlidx
{
    MDL_VIEW = 0,
    MDL_WORLD,
    MDL_PLAYER,
    SPR_HUD
};

string
    strSentryMdl,
    strClassname            = "monster_sentry",
    strDisplayName          = "Sentry",
    strSentryWeapon         = "weapon_pipewrench",
    strAllowedZoneEntity    = "player_sentry_allowed_zone",
    strRestrictedZoneEntity = "player_sentry_restricted_zone";

bool
    blPrecacheMonsterSentry = PrecacheMonsterSentry(),
    blDeployFx      = true,
    blMoveFx        = true,
    blUseArmourCost = true;

int
    iSentryWeaponAttackType = Hooks::Weapon::WeaponTertiaryAttack,
    iSentryMoveBtn          = IN_USE,
    iSentryDeleteBtn        = IN_RELOAD;

float
    flSentryHealthMultiplier    = 1.0f,
    flSentryAttackRange         = 1200.0f,// This is default, defined by game
    flSentryPosLength           = 96.0f;

Vector vecGroundOffset( 0, 0, 8 );

}
