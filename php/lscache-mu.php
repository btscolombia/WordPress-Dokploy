<?php
/*
Plugin Name: LiteSpeed Cache (MU)
Description: LiteSpeed Cache forced as a Must-Use plugin and auto-configured for Valkey.
Version: 1.1
Author: Dokploy Integration
*/

/**
 * Auto-configure LiteSpeed Cache for Valkey (Redis)
 * These constants override any settings in the database.
 */
if ( ! defined( 'LITESPEED_CONF' ) ) {
    define( 'LITESPEED_CONF', getenv('LITESPEED_CACHE_OBJECT_CONF') !== 'false' );
}

if ( defined('LITESPEED_CONF') && LITESPEED_CONF ) {
    if ( ! defined( 'LITESPEED_CONF__OBJECT' ) ) {
        define( 'LITESPEED_CONF__OBJECT', getenv('LITESPEED_CACHE_OBJECT_ENABLE') !== 'false' );
    }
    if ( ! defined( 'LITESPEED_CONF__OBJECT__KIND' ) ) {
        define( 'LITESPEED_CONF__OBJECT__KIND', (int)(getenv('LITESPEED_CACHE_OBJECT_KIND') ?: 1) ); // 1 = Redis
    }
    if ( ! defined( 'LITESPEED_CONF__OBJECT__HOST' ) ) {
        define( 'LITESPEED_CONF__OBJECT__HOST', getenv('VALKEY_HOST') ?: 'valkey' );
    }
    if ( ! defined( 'LITESPEED_CONF__OBJECT__PORT' ) ) {
        define( 'LITESPEED_CONF__OBJECT__PORT', (int)(getenv('VALKEY_PORT') ?: 6379) );
    }
}

// The require_once for litespeed-cache has been removed.
// The constants above will still auto-configure Valkey for you,
// but you must now install and activate LiteSpeed Cache manually from the Plugins screen.
// This allows you to update the plugin normally and have full control.
