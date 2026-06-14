<?php
/*
Plugin Name: Nonce & Admin Cache Guard (MU)
Description: Prevents WordPress nonces and logged-in user sessions from being
             served from the Valkey object cache, which causes Elementor and
             other tools to throw "Access Denied" on the second save.
Version: 1.0
Author: Dokploy Integration
*/

/**
 * PROBLEM: When LiteSpeed Cache uses Valkey as an object cache, WordPress
 * nonces get cached. After Elementor saves once and generates a new nonce
 * internally, the second save sends the new nonce — but Valkey still serves
 * the OLD cached nonce, causing a nonce verification failure (Access Denied).
 *
 * FIX: We hook into the WordPress object cache and tell it to NEVER cache
 * the nonce-related cache groups (nonces, user_meta for sessions, etc.)
 */

add_action('init', function() {
    // Tell the object cache to NOT cache these groups.
    // This forces WordPress to always read/write nonces directly to the DB.
    if (function_exists('wp_cache_add_non_persistent_groups')) {
        wp_cache_add_non_persistent_groups([
            'nonces',
            'users',
            'user_meta',
            'useremail',
            'userlogins',
            'user_sessions',
            'site-transient',
        ]);
    }
}, 1); // Priority 1 = runs as early as possible

/**
 * Also tell LiteSpeed Cache to never serve a cached page to logged-in users.
 * This prevents the page's embedded nonce from being served stale.
 */
add_filter('litespeed_is_forced_nocache', function($is_no_cache) {
    if (is_user_logged_in()) {
        return true;
    }
    return $is_no_cache;
});

/**
 * Prevent LiteSpeed from caching admin-ajax.php and REST API responses.
 * These endpoints handle all Elementor save operations.
 */
add_filter('litespeed_is_forced_nocache', function($is_no_cache) {
    $request_uri = $_SERVER['REQUEST_URI'] ?? '';
    if (
        str_contains($request_uri, 'admin-ajax.php') ||
        str_contains($request_uri, 'wp-json') ||
        str_contains($request_uri, 'wp-admin')
    ) {
        return true;
    }
    return $is_no_cache;
});
