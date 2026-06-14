#!/bin/bash
# Reparador automático de base de datos
cat << 'EOF' > /var/www/html/fix-db.php
<?php
header("Cache-Control: no-store, no-cache");
require 'wp-load.php';
global $wpdb;

echo "<h1>🛠️ Reparando Base de Datos...</h1>";

// Reparar wp_postmeta
$result1 = $wpdb->query("ALTER TABLE {$wpdb->postmeta} MODIFY COLUMN meta_id bigint(20) unsigned NOT NULL AUTO_INCREMENT");
if ($result1 !== false) {
    echo "✅ <b>wp_postmeta</b> reparada exitosamente (AUTO_INCREMENT añadido).<br>";
} else {
    echo "❌ Error reparando wp_postmeta: " . $wpdb->last_error . "<br>";
}

// Reparar wp_usermeta
$result2 = $wpdb->query("ALTER TABLE {$wpdb->usermeta} MODIFY COLUMN umeta_id bigint(20) unsigned NOT NULL AUTO_INCREMENT");
if ($result2 !== false) {
    echo "✅ <b>wp_usermeta</b> reparada exitosamente (AUTO_INCREMENT añadido).<br>";
} else {
    echo "❌ Error reparando wp_usermeta: " . $wpdb->last_error . "<br>";
}

echo "<h2>¡Reparación Completa! Ahora ve a Elementor y prueba guardar.</h2>";
EOF
chown nobody:nogroup /var/www/html/fix-db.php
