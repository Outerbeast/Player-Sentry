namespace PLAYER_SENTRY
{

array<CCVar@> CFG_SETTINGS =
{
    CCVar( "ps_displayname", strDisplayName, "Set the sentry's hudinfo name", ConCommandFlag::AdminOnly, ApplyCFGSetting ),
    CCVar( "ps_weapon", strSentryWeapon, "Classname of the weapon used to spawn the sentry", ConCommandFlag::AdminOnly, ApplyCFGSetting ),
    CCVar( "ps_build_fx", blDeployFx ? 1.0f : 0.0f, "Set whether building the sentry draws build effects", ConCommandFlag::AdminOnly, ApplyCFGSetting ),
    CCVar( "ps_carry_fx", blMoveFx ? 1.0f : 0.0f, "Set whether carrying the sentry draws carrying effects", ConCommandFlag::AdminOnly, ApplyCFGSetting ),
    CCVar( "ps_use_armor_cost", blUseArmourCost ? 1.0f : 0.0f, "Set whether building a sentry costs armour", ConCommandFlag::AdminOnly, ApplyCFGSetting ),
    CCVar( "ps_build_button", float( iSentryWeaponAttackType ), "Set the button used to build a sentry", ConCommandFlag::AdminOnly, ApplyCFGSetting ),
    CCVar( "ps_health_multiplier", flSentryHealthMultiplier, "Multiplier for sentry base health", ConCommandFlag::AdminOnly, ApplyCFGSetting ),
    CCVar( "ps_attack_range", flSentryAttackRange, "Set sentry attack range. Default is 1200.", ConCommandFlag::AdminOnly, ApplyCFGSetting )
};

void ApplyCFGSetting(CCVar@ cvar, const string& in szOldValue, float flOldValue)
{
    if( g_CustomEntityFuncs.IsCustomEntity( strSentryWeapon ) )
    {
        @CFG_SETTINGS[CFG_SETTINGS.findByRef( cvar )] = null;
        return;
    }

    if( cvar is null )
        return;

    const string strCVar = cvar.GetName();

    if( strCVar == "ps_displayname" )
        strDisplayName = cvar.GetString();
    else if( strCVar == "ps_weapon" )
        strSentryWeapon = cvar.GetString();
    else if( strCVar == "ps_build_fx" )
        blDeployFx = cvar.GetBool();
    else if( strCVar == "ps_move_fx" )
        blMoveFx = cvar.GetBool();
    else if( strCVar == "ps_use_armor_cost" )
        blUseArmourCost = cvar.GetBool();
    else if( strCVar == "ps_build_button" )
    {
        if( cvar.GetString() == "secondary_attack" )
            iSentryWeaponAttackType = Hooks::Weapon::WeaponSecondaryAttack;
        else if( cvar.GetString() == "primary_attack" )
            iSentryWeaponAttackType = Hooks::Weapon::WeaponPrimaryAttack;
        else
            iSentryWeaponAttackType = Hooks::Weapon::WeaponTertiaryAttack;
    }
    else if( strCVar == "ps_health_multiplier" )
        flSentryHealthMultiplier = cvar.GetFloat();
    else if( strCVar == "ps_attack_range" )
        flSentryAttackRange = cvar.GetFloat();

    g_Log.PrintF( "PLAYER_SENTRY: CVar set '%1 %2'\n", strCVar, cvar.GetString() );
    @CFG_SETTINGS[CFG_SETTINGS.findByRef( cvar )] = null;
}

}
