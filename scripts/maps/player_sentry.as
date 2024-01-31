/* Player Sentry
    by Outerbeast
    extension for weapon_pipewrench that lets players create their own sentry gun
    custom weapon for deploying a disposable sentry
*/
#include "player_sentry/constants"
#include "player_sentry/callbacks"
#include "player_sentry/cvars"
//#include "player_sentry/upgrade"
#include "player_sentry/weapon"

namespace PLAYER_SENTRY
{

array<uint> I_SENTRIES_DEPLOYED( g_Engine.maxClients + 1 );
CScheduledFunction@ fnSentryThink, fnInit = g_Scheduler.SetTimeout( "Init", 0.0f );

bool PrecacheMonsterSentry()
{
    g_Game.PrecacheMonster( "monster_sentry", true );
    return true;
}

void Precache()
{
    PrecacheMonsterSentry();

    if( strSentryMdl != "" )
        g_Game.PrecacheModel( strSentryMdl );
}

void Setup(string strModel)
{
    strSentryMdl = strModel;
    Precache();
}

void Init()
{
    if( g_CustomEntityFuncs.IsCustomEntity( strSentryWeapon ) )
        return;

    switch( iSentryMoveBtn )
    {
        case IN_ATTACK:     break;
        case IN_ATTACK2:    break;
        case IN_RUN:        break;
        case IN_RELOAD:     break;
        case IN_ALT1:       break;

        default:
            iSentryMoveBtn = IN_USE;
            break;
    }

    switch( iSentryDeleteBtn )
    {
        case IN_ATTACK:     break;
        case IN_ATTACK2:    break;
        case IN_RUN:        break;
        case IN_RELOAD:     break;
        case IN_ALT1:       break;
        
        default:
            iSentryMoveBtn = IN_RELOAD;
            break;
    }
    // Crisis averted
    if( iSentryDeleteBtn == iSentryMoveBtn )
        iSentryDeleteBtn = IN_RELOAD;

    if( iSentryWeaponAttackType < 0 || iSentryWeaponAttackType > 2 )
        iSentryWeaponAttackType = Hooks::Weapon::WeaponTertiaryAttack;

    if( g_Hooks.RegisterHook( Hooks::Player::PlayerUse, PlayerUse ) &&
        g_Hooks.RegisterHook( Hooks::Player::ClientDisconnect, PlayerLeave ) &&
        g_Hooks.RegisterHook( iSentryWeaponAttackType, DeploySentryAttack ) )
    {
        g_EntityFuncs.CreateEntity( "trigger_script", {{ "targetname", "player_sentry_killed" }, { "m_iszScriptFunctionName", "PLAYER_SENTRY::SentryKilled" }, { "m_iMode", "1" }} );
        @fnSentryThink = g_Scheduler.SetInterval( "SentryThink", 0.0f, g_Scheduler.REPEAT_INFINITE_TIMES );
    }    
}

CBaseMonster@ PlayerSentry(EHandle hPlayer)
{
    if( !hPlayer )
        return null;

    return cast<CBaseMonster@>( g_EntityFuncs.Instance( I_SENTRIES_DEPLOYED[hPlayer.GetEntity().entindex()] ) );
}

CBasePlayer@ SentryOwner(EHandle hSentry)
{
    if( !hSentry )
        return null;

    return g_PlayerFuncs.FindPlayerByIndex( I_SENTRIES_DEPLOYED.find( hSentry.GetEntity().entindex() ) );
}
// FX is laggy
void DeployFX(EHandle hPlayer, EHandle hSentry)
{
    if( !blDeployFx || !hPlayer || !hSentry )
        return;

    CBaseEntity@ pPlayer = hPlayer.GetEntity(), pSentry = hSentry.GetEntity();

    NetworkMessage box( MSG_ONE, NetworkMessages::SVC_TEMPENTITY, pPlayer.edict() );
        box.WriteByte( TE_BOX );

        box.WriteCoord( pSentry.pev.absmin.x );
        box.WriteCoord( pSentry.pev.absmin.y );
        box.WriteCoord( pSentry.pev.absmin.z );

        box.WriteCoord( pSentry.pev.absmax.x );
        box.WriteCoord( pSentry.pev.absmax.y );
        box.WriteCoord( pSentry.pev.absmin.z );

        box.WriteShort( 8 );

        box.WriteByte( 0 );
        box.WriteByte( 255 );
        box.WriteByte( 0 );
    box.End();

    NetworkMessage line( MSG_ONE, NetworkMessages::SVC_TEMPENTITY, pPlayer.edict() );
        line.WriteByte( TE_LINE );

        line.WriteCoord( pPlayer.pev.origin.x );
        line.WriteCoord( pPlayer.pev.origin.y );
        line.WriteCoord( pPlayer.pev.origin.z );

        line.WriteCoord( pSentry.pev.origin.x );
        line.WriteCoord( pSentry.pev.origin.y );
        line.WriteCoord( pSentry.pev.origin.z );

        line.WriteShort( 8 );

        line.WriteByte( 0 );
        line.WriteByte( 255 );
        line.WriteByte( 0 );
    line.End();
}

void MoveFX(EHandle hPlayer, EHandle hSentry)
{
    if( !hPlayer || !hSentry )
        return;

    CBaseEntity@ pPlayer = hPlayer.GetEntity(), pSentry = hSentry.GetEntity();
    CSprite@ pFakeSentry = g_EntityFuncs.CreateSprite( string( pSentry.pev.model ), pSentry.pev.origin, false, 0.0f );
    pFakeSentry.pev.angles.y = hPlayer.GetEntity().pev.angles.y;
    pFakeSentry.SetTransparency( kRenderTransTexture, 255, 0, 0, 50, 0 );
    pFakeSentry.AnimateAndDie( 50.0f );

    if( !blMoveFx )
        return;

    NetworkMessage box( MSG_ONE, NetworkMessages::SVC_TEMPENTITY, pPlayer.edict() );
        box.WriteByte( TE_BOX );

        box.WriteCoord( pSentry.pev.absmin.x );
        box.WriteCoord( pSentry.pev.absmin.y );
        box.WriteCoord( pSentry.pev.absmin.z );

        box.WriteCoord( pSentry.pev.absmax.x );
        box.WriteCoord( pSentry.pev.absmax.y );
        box.WriteCoord( pSentry.pev.absmin.z );

        box.WriteShort( 1 );

        box.WriteByte( 255 );
        box.WriteByte( 0 );
        box.WriteByte( 0 );
    box.End();

    NetworkMessage line( MSG_ONE, NetworkMessages::SVC_TEMPENTITY, pPlayer.edict() );
        line.WriteByte( TE_LINE );

        line.WriteCoord( pPlayer.pev.origin.x );
        line.WriteCoord( pPlayer.pev.origin.y );
        line.WriteCoord( pPlayer.pev.origin.z );

        line.WriteCoord( pSentry.pev.origin.x );
        line.WriteCoord( pSentry.pev.origin.y );
        line.WriteCoord( pSentry.pev.origin.z );

        line.WriteShort( 1 );

        line.WriteByte( 255 );
        line.WriteByte( 0 );
        line.WriteByte( 0 );
    line.End();
}

void RemoveSentry(EHandle hPlayer, int iRemoveType = None)
{
    if( !hPlayer )
        return;
        
    hPlayer.GetEntity().GetUserData( "b_is_carrying_sentry" ) = false;
    PlayerSentry( hPlayer ).GetUserData( "i_reason_removed" ) = iRemoveType;
    g_EntityFuncs.Remove( PlayerSentry( hPlayer ) );
}

void PickUpSentry(EHandle hPlayer, EHandle hSentry)
{
    if( !hPlayer || !hSentry )
        return;

    CBaseEntity@ pPlayer = hPlayer.GetEntity(), pSentry = hSentry.GetEntity();

    if( pPlayer is null || pSentry is null || !pPlayer.pev.FlagBitSet( FL_ONGROUND ) || pPlayer.pev.FlagBitSet( FL_INWATER ) )
        return;

    pPlayer.GetUserData( "b_is_carrying_sentry" ) = true;
    g_EntityFuncs.DispatchKeyValue( pSentry.edict(), "attackrange", "1" );
    pSentry.pev.takedamage = DAMAGE_NO;
    pSentry.pev.effects |= EF_NODRAW;
    @pSentry.pev.owner = pPlayer.edict();
}

void PutDownSentry(EHandle hPlayer, EHandle hSentry)
{
    if( !hPlayer || !hSentry )
        return;

    CBaseEntity@ pPlayer = hPlayer.GetEntity(), pSentry = hSentry.GetEntity();

    if( pPlayer is null || pSentry is null || pSentry.Intersects( pPlayer ) )
        return;

    if( !pPlayer.pev.FlagBitSet( FL_ONGROUND ) || pPlayer.pev.FlagBitSet( FL_INWATER ) || !FInAllowedZone( pSentry ) || FInRestrictedZone( pSentry ) )
        return;

    pPlayer.GetUserData( "b_is_carrying_sentry" ) = false;
    g_EntityFuncs.DispatchKeyValue( pSentry.edict(), "attackrange", "" + flSentryAttackRange );
    pSentry.pev.angles.y = pPlayer.pev.angles.y;
    pSentry.pev.takedamage = DAMAGE_YES;
    pSentry.pev.effects &= ~EF_NODRAW;
    @pSentry.pev.owner = null;
    // Sentry is placed in a position thats daft
    if( g_EngineFuncs.DropToFloor( pSentry.edict() ) < 0 )
        RemoveSentry( pPlayer, Placement_Invalid );
}

bool FPlayerCarryingSentry(EHandle hPlayer)
{
    return hPlayer ? bool( hPlayer.GetEntity().GetUserData( "b_is_carrying_sentry" ) ) : false;
}

bool FInAllowedZone(EHandle hSentry)
{
    if( !hSentry )
        return false;

    CBaseEntity@ pZone;

    while( ( @pZone = g_EntityFuncs.FindEntityByTargetname( pZone, strAllowedZoneEntity ) ) !is null )
    {
        if( pZone is null )
            continue;

        if( !hSentry.GetEntity().Intersects( pZone ) )
        {
            g_EntityFuncs.FireTargets( pZone.pev.target, hSentry.GetEntity(), SentryOwner( hSentry ), USE_TOGGLE, 0.0f, 0.0f );
            return false;
        }
    }

    return true;
}

bool FInRestrictedZone(EHandle hSentry)
{
    if( !hSentry )
        return false;

    CBaseEntity@ pZone;

    while( ( @pZone = g_EntityFuncs.FindEntityByTargetname( pZone, strRestrictedZoneEntity ) ) !is null )
    {
        if( pZone is null )
            continue;

        if( hSentry.GetEntity().Intersects( pZone ) )
        {
            g_EntityFuncs.FireTargets( pZone.pev.target, hSentry.GetEntity(), SentryOwner( hSentry ), USE_TOGGLE, 0.0f, 0.0f );
            return true;
        }
    }

    return false;
}

Vector SetPosition(EHandle hPlayer)
{
    if( !hPlayer )
        return g_vecZero;

    TraceResult trForward, trReflect;
    Math.MakeVectors( hPlayer.GetEntity().pev.v_angle );
    const Vector 
        vecStart = hPlayer.GetEntity().GetOrigin() + hPlayer.GetEntity().pev.view_ofs,
        vecEnd = vecStart + g_Engine.v_forward * flSentryPosLength;
    g_Utility.TraceLine( vecStart, vecEnd, ignore_monsters, dont_ignore_glass, hPlayer.GetEntity().edict(), trForward );
    // If a player is carrying their sentry, ensure they don't clip it through a surface
    Vector vecFinalPos;
    if( PlayerSentry( hPlayer ) !is null )
    {
        g_Utility.TraceLine( trForward.vecEndPos, hPlayer.GetEntity().pev.origin, dont_ignore_monsters, dont_ignore_glass, PlayerSentry( hPlayer ).edict(), trReflect );
        vecFinalPos = trReflect.vecEndPos + ( ( trForward.vecEndPos - hPlayer.GetEntity().pev.origin ) * 0.5f );
    }
    else
        vecFinalPos = trForward.vecEndPos;
    // Prevent sentry clipping the floor
    if( vecFinalPos.z < hPlayer.GetEntity().pev.origin.z )
        vecFinalPos = vecFinalPos + vecGroundOffset;

    return vecFinalPos;
}

uint BuildSentry(EHandle hPlayer)
{
    if( !hPlayer )
        return 0;

    CBasePlayer@ pPlayer = cast<CBasePlayer@>( hPlayer.GetEntity() );

    if( pPlayer is null || !pPlayer.pev.FlagBitSet( FL_ONGROUND ) || pPlayer.pev.FlagBitSet( FL_INWATER ) )
        return 0;

    if( blUseArmourCost && pPlayer.pev.armorvalue < 10.0f )
        return 0;

    const Vector vecSentryDeployPos = SetPosition( pPlayer ) != g_vecZero ? SetPosition( pPlayer ) + vecGroundOffset : g_vecZero;

    if( vecSentryDeployPos == g_vecZero )
        return 0;

    CBaseMonster@ pSentry = cast<CBaseMonster@>( g_EntityFuncs.Create( strClassname, vecSentryDeployPos, Vector( 0, pPlayer.pev.angles.y, 0 ), true ) );

    if( pSentry is null || !pSentry.IsMonster() )
        return 0;
    // !-BUG-!: For a split second after moving a sentry, hudinfo shows the sentry as enemy before correcting itself
    pSentry.SetClassification( pPlayer.m_iClassSelection );
    pSentry.SetPlayerAllyDirect( true );
    pSentry.pev.spawnflags |= 1 << 5; //Autostart
    g_EntityFuncs.DispatchKeyValue( pSentry.edict(), "ondestroyfn", "PLAYER_SENTRY::SentryDestroyed" );
    pSentry.GetUserData()["i_reason_removed"] = None;

    if( flSentryAttackRange != 1200 )
        g_EntityFuncs.DispatchKeyValue( pSentry.edict(), "attackrange", "" + flSentryAttackRange );

    if( strSentryMdl != "" )
    {
        pSentry.pev.model = strSentryMdl;
        g_EntityFuncs.SetModel( pSentry, pSentry.pev.model );
    }
    
    if( g_EntityFuncs.DispatchSpawn( pSentry.edict() ) < 0 )
        return 0;

    DeployFX( pPlayer, pSentry );
    // Sentry has to exist in a sensible area
    if( g_EngineFuncs.DropToFloor( pSentry.edict() ) < 0 || pSentry.Intersects( pPlayer ) || !FInAllowedZone( pSentry ) || FInRestrictedZone( pSentry ) )
    {
        pSentry.GetUserData( "i_reason_removed" ) = Placement_Invalid;
        g_EntityFuncs.Remove( pSentry );
        return 0;
    }

    if( blUseArmourCost )
    {
        pSentry.pev.max_health = pSentry.pev.health = pPlayer.pev.armorvalue * ( flSentryHealthMultiplier > 0.0f ? flSentryHealthMultiplier : 1.0f );
        pPlayer.pev.armorvalue = 0.0f;
    }
    else
        pSentry.pev.max_health = pSentry.pev.health *= ( flSentryHealthMultiplier > 0.0f ? flSentryHealthMultiplier : 1.0f );

    pSentry.m_FormattedName = strDisplayName != "" ? "" + pPlayer.pev.netname + "'s " + strDisplayName : "Ally Sentry Turret";
    pSentry.pev.targetname = "player_sentry_PID" + pPlayer.entindex() + "_EID" + pSentry.entindex();
    pSentry.m_iTriggerCondition = 4;
    pSentry.m_iszTriggerTarget = "player_sentry_killed";
    pPlayer.GetUserData()["b_is_carrying_sentry"] = false;

    g_SoundSystem.EmitSound( pSentry.edict(), CHAN_VOICE, "weapons/mine_deploy.wav", 1.0f, ATTN_NORM );
    g_EntityFuncs.FireTargets( pSentry.pev.targetname, pPlayer, pSentry, USE_ON, 0.0f, 1.0f );
    // SentryBuiltEvent callback handler
    for( uint i = 0; i < FN_SENTRYBUILT.length(); i++ )
    {
        if( FN_SENTRYBUILT[i] is null )
            continue;

        FN_SENTRYBUILT[i]( pSentry, pPlayer );
    }

    g_EntityFuncs.FireTargets( "player_sentry_built", pPlayer, pSentry, USE_TOGGLE, 0.0f, 0.0f );
    
    return pSentry.entindex();
}

void SentryThink()
{
    for( uint i = 0; i < I_SENTRIES_DEPLOYED.length(); i++ )
    {
        if( I_SENTRIES_DEPLOYED[i] <= 0 )
            continue;

        CBaseMonster@ pSentry = PlayerSentry( g_PlayerFuncs.FindPlayerByIndex( i ) );
        CBasePlayer@ pSentryOwner = pSentry !is null ? SentryOwner( pSentry ) : null;

        if( pSentry is null || !pSentry.IsAlive() )
            continue;
        // Get rid of orphaned player sentrys
        if( pSentryOwner is null )
        {
            I_SENTRIES_DEPLOYED[i] = 0;
            continue;
        }
        // !-BUG-!: IsConnected() doesn't work? Have to resort to ClientDisconnected hook
        if( !pSentryOwner.IsConnected() ) 
        {
            RemoveSentry( pSentryOwner, Owner_Disconnect );
            continue;
        }

        if( pSentry.pev.origin == g_vecZero )
        {
            RemoveSentry( pSentryOwner, Placement_Invalid );
            continue;
        }
         
        if( pSentry.pev.FlagBitSet( FL_INWATER ) )
        {
            pSentry.Killed( g_EntityFuncs.Instance( 0 ).pev, 0 );
            continue;
        }

        if( FPlayerCarryingSentry( pSentryOwner ) )
        {
            g_EntityFuncs.SetOrigin( pSentry, SetPosition( pSentryOwner ) );
            MoveFX( pSentryOwner, pSentry );

            if( !pSentryOwner.m_hActiveItem || pSentryOwner.m_hActiveItem.GetEntity().GetClassname() != strSentryWeapon )
            {
                PutDownSentry( pSentryOwner, pSentry );
                continue;
            }

            if( !pSentryOwner.IsAlive() || pSentryOwner.m_afButtonPressed & iSentryDeleteBtn != 0 )
                RemoveSentry( pSentryOwner, Deletion );
        }
        // SentryThinkEvent callback handler
        for( uint j = 0; j < FN_SENTRYTHINK.length(); j++ )
        {
            if( FN_SENTRYTHINK[j] is null )
                continue;

            FN_SENTRYTHINK[j]( pSentry, pSentryOwner );
        }
    }
}

void SentryKilled(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
{
    CBaseMonster@ pSentry = cast<CBaseMonster@>( pActivator is null ? pCaller : pActivator );

    if( pSentry is null || pSentry.IsAlive() )
        return;
    // SentryKilledEvent callback handler
    for( uint i = 0; i < FN_SENTRYKILLED.length(); i++ )
    {
        if( FN_SENTRYKILLED[i] is null )
            continue;

        FN_SENTRYKILLED[i]( pSentry, SentryOwner( pSentry ) );
        pSentry.GetUserData( "i_reason_removed" ) = Death;
    }
}

void SentryDestroyed(CBaseEntity@ pEntity)
{
    if( pEntity is null || !pEntity.IsMonster() )
        return;

    CBaseMonster@ pSentry = cast<CBaseMonster@>( pEntity );

    if( pSentry is null )
        return;
    // SentryDestroyedEvent callback handler
    for( uint i = 0; i < FN_SENTRYDESTROYED.length(); i++ )
    {
        if( FN_SENTRYDESTROYED[i] is null )
            continue;

        FN_SENTRYDESTROYED[i]( pSentry, SentryOwner( pSentry ), int( pSentry.GetUserData( "i_reason_removed" ) ) );
    }

    g_EntityFuncs.FireTargets( "player_sentry_destroyed", pSentry, SentryOwner( pSentry ), USE_TOGGLE, 0.0f, 0.0f );

    if( I_SENTRIES_DEPLOYED.find( pSentry.entindex() ) >= 0 )
        I_SENTRIES_DEPLOYED[I_SENTRIES_DEPLOYED.find( pSentry.entindex() )] = 0;
}

HookReturnCode DeploySentryAttack(CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon)
{
    if( pPlayer is null || pWeapon is null || pWeapon.GetClassname() != strSentryWeapon || PlayerSentry( pPlayer ) !is null )
        return HOOK_CONTINUE;

    I_SENTRIES_DEPLOYED[pPlayer.entindex()] = BuildSentry( pPlayer );

    return HOOK_CONTINUE;
}

HookReturnCode PlayerUse(CBasePlayer@ pPlayer, uint& out uiFlags)
{
    if( pPlayer is null || I_SENTRIES_DEPLOYED[pPlayer.entindex()] <= 0 )
        return HOOK_CONTINUE;

    if( !pPlayer.m_hActiveItem || pPlayer.m_hActiveItem.GetEntity().GetClassname() != strSentryWeapon )
        return HOOK_CONTINUE;
    // Redundant, just to improve perfs
    if( !pPlayer.pev.FlagBitSet( FL_ONGROUND ) || pPlayer.pev.FlagBitSet( FL_INWATER ) )
        return HOOK_CONTINUE;

    CBaseMonster@ pDeployedSentry = PlayerSentry( pPlayer );

    if( pDeployedSentry is null || !pDeployedSentry.IsAlive() )
        return HOOK_CONTINUE;

    if( pPlayer.m_afButtonPressed & iSentryMoveBtn != 0 )
    {
        if( !FPlayerCarryingSentry( pPlayer ) )
        {
            if( g_Utility.FindEntityForward( pPlayer, 64.0f ) is pDeployedSentry && SentryOwner( pDeployedSentry ) is pPlayer )
            {
                PickUpSentry( pPlayer, pDeployedSentry );
                return HOOK_CONTINUE;
            }
        }
        else
            PutDownSentry( pPlayer, pDeployedSentry ); 
    }

    return HOOK_CONTINUE;
}

HookReturnCode PlayerLeave(CBasePlayer@ pPlayer)
{
    if( pPlayer is null )
        return HOOK_CONTINUE;

    RemoveSentry( pPlayer, Owner_Disconnect );

    return HOOK_CONTINUE;
}

void Disable()
{
    for( uint i = 0; i < I_SENTRIES_DEPLOYED.length(); i++ )
        RemoveSentry( g_PlayerFuncs.FindPlayerByIndex( i ) );

    I_SENTRIES_DEPLOYED = array<uint>( g_Engine.maxClients + 1, 0 );

    g_Hooks.RemoveHook( Hooks::Player::PlayerUse, PlayerUse );
    g_Hooks.RemoveHook( Hooks::Player::ClientDisconnect, PlayerLeave );
    g_Hooks.RemoveHook( iSentryWeaponAttackType, DeploySentryAttack );
    g_Scheduler.RemoveTimer( fnSentryThink );
}

}
