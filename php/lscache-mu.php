<?php
/*
Plugin Name: LiteSpeed Cache (MU)
Description: LiteSpeed Cache forced as a Must-Use plugin and auto-configured for Valkey.
Version: 1.4
Author: Dokploy Integration
*/

/**
 * Auto-configure LiteSpeed Cache for Valkey (Redis)
 * These constants override any settings in the database.
 *
 * IMPORTANT: Object cache (Valkey) is DISABLED by default.
 * Enabling it causes Elementor "Access Denied" and REST API meta update errors.
 *
 * To enable object cache (for high-traffic sites only), set in your .env:
 *   LITESPEED_CACHE_OBJECT_ENABLE=true
 */
if ( ! defined( 'LITESPEED_CONF' ) ) {
    define( 'LITESPEED_CONF', getenv('LITESPEED_CACHE_OBJECT_CONF') !== 'false' );
}

if ( defined('LITESPEED_CONF') && LITESPEED_CONF ) {
    // Object cache is OPT-IN: must explicitly set LITESPEED_CACHE_OBJECT_ENABLE=true
    if ( ! defined( 'LITESPEED_CONF__OBJECT' ) ) {
        define( 'LITESPEED_CONF__OBJECT', getenv('LITESPEED_CACHE_OBJECT_ENABLE') === 'true' );
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
// LiteSpeed Cache is no longer forced as a Must-Use plugin.
// You can now activate or deactivate it normally from the WordPress Plugins screen.
