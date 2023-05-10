namespace PLAYER_SENTRY
{

array<string> SENTRY_WEAPON_MDLS =
{
    "models/v_sentrygun.mdl",
    "models/w_sentrygun.mdl",
    "models/p_sentrygun.mdl",
    "sprites/sentry/weapon_sentry.spr"
};

bool WeaponRegister(string strViewMdl = "", string strWorldMdl = "", string strPlayerMdl = "")
{
    strSentryWeapon = "weapon_sentry";
    strDisplayName = "";
    blDeployFx = blMoveFx = blUseArmourCost = false;
    flSentryPosLength = 48.0f;

    if( strViewMdl != "" )
        SENTRY_WEAPON_MDLS[MDL_VIEW] = strViewMdl;

    if( strWorldMdl != "" )
        SENTRY_WEAPON_MDLS[MDL_WORLD] = strWorldMdl;

    if( strPlayerMdl != "" )
        SENTRY_WEAPON_MDLS[MDL_PLAYER] = strPlayerMdl;

    g_CustomEntityFuncs.RegisterCustomEntity( "PLAYER_SENTRY::CSentryWeapon", strSentryWeapon );
    g_ItemRegistry.RegisterWeapon( strSentryWeapon, "sentry", strSentryWeapon );

    return g_CustomEntityFuncs.IsCustomEntity( strSentryWeapon );
}
// Class is not final and all members are public for use as baseclass for a constructing a more derived sentryweapon type
class CSentryWeapon : ScriptBasePlayerWeaponEntity
{
    float m_flAttackRange, flPlaceDelay = 0.53f;// Used by weapon_sentry for delay between primary attack and sentry placement
    string m_strDisplayName;
    CScheduledFunction@ fnPlaceSentry;

    CBasePlayer@ m_pPlayer
    {
        get { return cast<CBasePlayer@>( self.m_hPlayer.GetEntity() ); }
        set { self.m_hPlayer = EHandle( @value ); }
    }

    bool KeyValue(const string& in szKey, const string& in szValue)
    {
        if( szKey == "displayname" )
            m_strDisplayName = szValue;
        else if( szKey == "attackrange" )
            m_flAttackRange = atof( szValue );
        else if( szKey == "classify" )
            self.m_iClassSelection = atoi( szValue );
        else
            return BaseClass.KeyValue( szKey, szValue );

        return true;
    }

    bool GetItemInfo(ItemInfo& out info)
    {
        info.iId     	= g_ItemRegistry.GetIdForName( self.GetClassname() );
        info.iMaxAmmo1 	= 1;
        info.iMaxAmmo2 	= -1;
        info.iMaxClip 	= WEAPON_NOCLIP;
        info.iSlot 		= 4;
        info.iPosition 	= 6;
        info.iFlags 	= ITEM_FLAG_LIMITINWORLD | ITEM_FLAG_EXHAUSTIBLE;
        info.iWeight 	= 5;

        return info.iId == g_ItemRegistry.GetIdForName( self.GetClassname() );
    }

    void Precache()
    {
        PLAYER_SENTRY::Precache();
        self.PrecacheCustomModels();
        g_Game.PrecacheGeneric( "sprites/sentry/" + self.GetClassname() + ".txt" );
        
        for( uint i = 0; i < SENTRY_WEAPON_MDLS.length(); i++ )
            g_Game.PrecacheModel( SENTRY_WEAPON_MDLS[i] );

        BaseClass.Precache();
    }

    void Spawn()
    {
        self.Precache();
        self.m_iDefaultAmmo = 1;
        g_EntityFuncs.SetModel( self, self.GetW_Model( SENTRY_WEAPON_MDLS[MDL_WORLD] ) );
        self.FallInit();

        BaseClass.Spawn();
    }

    int PrimaryAmmoIndex()
    {
        return 1;
    }

    string pszName()
    {
        return self.GetClassname();
    }

    string pszAmmo1()
    {
        return self.GetClassname();
    }

    bool AddToPlayer(CBasePlayer@ pPlayer)
    {
        if( !BaseClass.AddToPlayer( pPlayer ) )
            return false;

        NetworkMessage weapon( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
            weapon.WriteLong( g_ItemRegistry.GetIdForName( self.GetClassname() ) );
        weapon.End();

        @m_pPlayer = pPlayer;

        return true;
    }

    CBasePlayerItem@ DropItem()
    {
        return self;
    }

    bool CanHaveDuplicates()
    {
        return true;
    }

    bool CanDeploy()
    {
        return m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) > 0;
    }

    bool Deploy()
    {
        return self.DefaultDeploy( self.GetV_Model( SENTRY_WEAPON_MDLS[MDL_VIEW] ), self.GetP_Model( SENTRY_WEAPON_MDLS[MDL_PLAYER] ), SENTRY_DRAW, "trip" );
    }

    bool IsEmpty()
    {
        return m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) < 1;
    }

    void DeductAmmo(int iAmmoAmt = 1)
    {
        if( iAmmoAmt == 0 )
            return;

        m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType, m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) - iAmmoAmt );
    }

    void Holster(int skipLocal = 0)
    {
        m_pPlayer.m_flNextAttack = g_Engine.time + 0.5f;
        BaseClass.Holster( skipLocal );
    }

    void PlaceSentry()
    {
        CBaseMonster@ pSentry = cast<CBaseMonster@>( g_EntityFuncs.Instance( BuildSentry( m_pPlayer ) ) );

        if( pSentry is null )
        {   // Not enough room. Try again!
            self.m_flTimeWeaponIdle = g_Engine.time + 0.01f;
            return;
        }

        if( self.pev.health != 0.0f )
            pSentry.pev.max_health = pSentry.pev.health = self.pev.health;

        if( m_strDisplayName != "" )
            pSentry.m_FormattedName = m_strDisplayName;

        if( self.m_iClassSelection > 0 )
            pSentry.SetClassification( self.m_iClassSelection );

        if( m_flAttackRange > 0.0f )
            g_EntityFuncs.DispatchKeyValue( pSentry.edict(), "attackrange", "" + m_flAttackRange );

        DeductAmmo();
        self.m_flTimeWeaponIdle = g_Engine.time + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 10, 15 );

        if( IsEmpty() )
        {
            self.RetireWeapon();// Not necessary, but just in case of cosmic rays
            self.DestroyItem();
            return;
        }
    }

    void WeaponIdle()
    {
        if( self.m_flTimeWeaponIdle > g_Engine.time )
            return;

        if( g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 0, 1 ) <= 0.25f )
        {
            self.SendWeaponAnim( SENTRY_FIDGET );
            self.m_flTimeWeaponIdle = g_Engine.time + 2.0f;
        }
        else
        {
            self.SendWeaponAnim( SENTRY_IDLE );
            self.m_flTimeWeaponIdle = g_Engine.time + 5.1f;
        }
    }

    void PrimaryAttack()
    {
        if( IsEmpty() )
			return;

        @fnPlaceSentry = g_Scheduler.SetTimeout( this, "PlaceSentry", flPlaceDelay );
        m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
        self.SendWeaponAnim( SENTRY_DROP );
        self.m_flNextPrimaryAttack = g_Engine.time + flPlaceDelay;
    }

    void UpdateOnRemove()
    {
        if( fnPlaceSentry !is null )
            g_Scheduler.RemoveTimer( fnPlaceSentry );
    }
};

}
