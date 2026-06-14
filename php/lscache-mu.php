<?php
/*
Plugin Name: LiteSpeed Cache (MU)
Description: LiteSpeed Cache forced as a Must-Use plugin and auto-configured for Valkey.
Version: 1.3
Author: Dokploy Integration
*/

/**
 * Auto-configure LiteSpeed Cache for Valkey (Redis)
 * These constants override any settings in the database.
 *
 * Object cache is ENABLED for public visitors (fast page loads).
 * Nonces and user sessions are excluded from Valkey (non-persistent)
 * to prevent Elementor "Access Denied" errors for logged-in admins.
 */
if ( ! defined( 'LITESPEED_CONF' ) ) {
    define( 'LITESPEED_CONF', getenv('LITESPEED_CACHE_OBJECT_CONF') !== 'false' );
}

if ( defined('LITESPEED_CONF') && LITESPEED_CONF ) {
    if ( ! defined( 'LITESPEED_CONF__OBJECT' ) ) {
        // Object cache ON by default. Use LITESPEED_CACHE_OBJECT_ENABLE=false to disable.
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

/**
 * CRITICAL FIX: Exclude nonces and user session data from Valkey.
 *
 * WordPress stores nonces and session tokens in these cache groups.
 * If cached in Valkey, they become stale between requests, causing:
 *   - Elementor "Access Denied" on second save
 *   - REST API meta update failures
 *   - Block editor "Publication failed" errors
 *
 * Marking them as non-persistent forces WordPress to always read/write
 * these directly to the database, while everything else (posts, terms,
 * options) still benefits from Valkey caching.
 */
add_action( 'init', function() {
    if ( function_exists( 'wp_cache_add_non_persistent_groups' ) ) {
        wp_cache_add_non_persistent_groups( [
            'nonces',        // WordPress nonces (used by Elementor, REST API, admin)
            'users',         // User objects
            'user_meta',     // User meta including session_tokens (critical!)
            'useremail',     // User lookup by email
            'userlogins',    // User lookup by login
            'user_sessions', // Active login sessions
        ] );
    }
}, 1 ); // Priority 1 = runs as early as possible after init

if ( defined('WP_PLUGIN_DIR') && file_exists( WP_PLUGIN_DIR . '/litespeed-cache/litespeed-cache.php' ) ) {
    require_once WP_PLUGIN_DIR . '/litespeed-cache/litespeed-cache.php';
}
