funcdef void SentryBuiltEvent(CBaseMonster@, CBasePlayer@);
funcdef void SentryThinkEvent(CBaseMonster@, CBasePlayer@);
funcdef void SentryKilledEvent(CBaseMonster@, CBasePlayer@);
funcdef void SentryDestroyedEvent(CBaseMonster@, CBasePlayer@, int& in);

namespace PLAYER_SENTRY
{

array<SentryBuiltEvent@> FN_SENTRYBUILT;
array<SentryThinkEvent@> FN_SENTRYTHINK;
array<SentryKilledEvent@> FN_SENTRYKILLED;
array<SentryDestroyedEvent@> FN_SENTRYDESTROYED;
// Funcs for configuring optional callbacks
bool SetSentryCallback(int iEventType, ref@ fn)
{
    if( fn is null )
    {
        g_Log.PrintF( "PLAYER_SENTRY::SetSentryCallback: Function not found.\n" );
        return false;
    }

    switch( iEventType )
    {
        case Built:
        {
            auto fnSentryBuilt = cast<SentryBuiltEvent@>( fn );

            if( fnSentryBuilt is null )
            {
                g_Log.PrintF( "PLAYER_SENTRY::SetSentryCallback: Function is incompatible with event type PLAYER_SENTRY::Built!\n" );
                return false;
            }
            
            if( FN_SENTRYBUILT.findByRef( fnSentryBuilt ) >= 0 )
            {
                g_Log.PrintF( "PLAYER_SENTRY::SetSentryCallback: Function is already registered to event type PLAYER_SENTRY::Built.\n" );
                return true;
            }

            FN_SENTRYBUILT.insertLast( fnSentryBuilt );

            return FN_SENTRYBUILT.findByRef( fnSentryBuilt ) >= 0;
        }

        case Think:
        {
            auto fnSentryThink = cast<SentryThinkEvent@>( fn );

            if( fnSentryThink is null )
            {
                g_Log.PrintF( "PLAYER_SENTRY::SetSentryCallback: Function is incompatible with event type PLAYER_SENTRY::Think!\n" );
                return false;
            }
            
            if( FN_SENTRYTHINK.findByRef( fnSentryThink ) >= 0 )
            {
                g_Log.PrintF( "PLAYER_SENTRY::SetSentryCallback: Function is already registered to event type PLAYER_SENTRY::Think.\n" );
                return true;
            }

            FN_SENTRYTHINK.insertLast( fnSentryThink );

            return FN_SENTRYTHINK.findByRef( fnSentryThink ) >= 0;
        }

        case Killed:
        {
            auto fnSentryKilled = cast<SentryKilledEvent@>( fn );

            if( fnSentryKilled is null )
            {
                g_Log.PrintF( "PLAYER_SENTRY::SetSentryCallback: Function is incompatible with event type PLAYER_SENTRY::Killed!\n" );
                return false;
            }
            
            if( FN_SENTRYKILLED.findByRef( fnSentryKilled ) >= 0 )
            {
                g_Log.PrintF( "PLAYER_SENTRY::SetSentryCallback: Function is already registered to event type PLAYER_SENTRY::Killed.\n" );
                return true;
            }

            FN_SENTRYKILLED.insertLast( fnSentryKilled );

            return FN_SENTRYKILLED.findByRef( fnSentryKilled ) >= 0;
        }

        case Destroyed:
        {
            auto fnSentryDestroyed = cast<SentryDestroyedEvent@>( fn );

            if( fnSentryDestroyed is null )
            {
                g_Log.PrintF( "PLAYER_SENTRY::SetSentryCallback: Function is incompatible with event type PLAYER_SENTRY::Destroyed!\n" );
                return false;
            }
            
            if( FN_SENTRYDESTROYED.findByRef( fnSentryDestroyed ) >= 0 )
            {
                g_Log.PrintF( "PLAYER_SENTRY::SetSentryCallback: Function is already registered to event type PLAYER_SENTRY::Destroyed.\n" );
                return true;
            }

            FN_SENTRYDESTROYED.insertLast( fnSentryDestroyed );

            return FN_SENTRYDESTROYED.findByRef( fnSentryDestroyed ) >= 0;
        }

        default:
        {
            g_Log.PrintF( "PLAYER_SENTRY::SetSentryCallback: invalid iEventType!\n" );
            return false;
        }
    }
}

void RemoveSentryCallback(int iEventType, ref@ fn)
{
    if( fn is null )
    {
        g_Log.PrintF( "PLAYER_SENTRY::RemoveSentryCallback: Function not found.\n" );
        return;
    }

    switch( iEventType )
    {
        case Built:
        {
            auto fnSentryBuilt = cast<SentryBuiltEvent@>( fn );

            if( fnSentryBuilt is null )
            {
                g_Log.PrintF( "PLAYER_SENTRY::RemoveSentryCallback: Function is incompatible with event type PLAYER_SENTRY::Built!\n" );
                return;
            }
            
            if( FN_SENTRYBUILT.findByRef( fnSentryBuilt ) >= 0 )
                FN_SENTRYBUILT.removeAt( FN_SENTRYBUILT.findByRef( fnSentryBuilt ) );

            return;
        }

        case Think:
        {
            auto fnSentryThink = cast<SentryThinkEvent@>( fn );

            if( fnSentryThink is null )
            {
                g_Log.PrintF( "PLAYER_SENTRY::RemoveSentryCallback: Function is incompatible with event type PLAYER_SENTRY::Think!\n" );
                return;
            }
            
            if( FN_SENTRYTHINK.findByRef( fnSentryThink ) >= 0 )
                FN_SENTRYTHINK.removeAt( FN_SENTRYTHINK.findByRef( fnSentryThink ) );

            return;
        }

        case Killed:
        {
            auto fnSentryKilled = cast<SentryKilledEvent@>( fn );

            if( fnSentryKilled is null )
            {
                g_Log.PrintF( "PLAYER_SENTRY::RemoveSentryCallback: Function is incompatible with event type PLAYER_SENTRY::Killed!\n" );
                return;
            }
            
            if( FN_SENTRYKILLED.findByRef( fnSentryKilled ) >= 0 )
                FN_SENTRYKILLED.removeAt( FN_SENTRYKILLED.findByRef( fnSentryKilled ) );

            return;
        }

        case Destroyed:
        {
            auto fnSentryDestroyed = cast<SentryDestroyedEvent@>( fn );

            if( fnSentryDestroyed is null )
            {
                g_Log.PrintF( "PLAYER_SENTRY::RemoveSentryCallback: Function is incompatible with event type PLAYER_SENTRY::Destroyed!\n" );
                return;
            }
            
            if( FN_SENTRYDESTROYED.findByRef( fnSentryDestroyed ) >= 0 )
                FN_SENTRYDESTROYED.removeAt( FN_SENTRYDESTROYED.findByRef( fnSentryDestroyed ) );

            return;
        }

        default:
            g_Log.PrintF( "PLAYER_SENTRY::RemoveSentryCallback: invalid iEventType!\n" );
    }
}

void RemoveSentryCallback(int iEventType)
{
    switch( iEventType )
    {
        case Built: 
            FN_SENTRYBUILT.resize( 0 );
            return;

        case Think:
            FN_SENTRYTHINK.resize( 0 );
            return;

        case Killed:
            FN_SENTRYKILLED.resize( 0 );
            return;

        case Destroyed:
            FN_SENTRYDESTROYED.resize( 0 );
            return;

        default:
            g_Log.PrintF( "PLAYER_SENTRY::RemoveSentryCallback: invalid iEventType!\n" );
    }
}

}
