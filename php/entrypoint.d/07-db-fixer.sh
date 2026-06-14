#!/bin/bash
# Reparador automático de base de datos
cat << 'EOF' > /var/www/html/fix-db.php
<?php
header("Cache-Control: no-store, no-cache");
require 'wp-load.php';
global $wpdb;

echo "<h1>🛠️ Reparando Base de Datos...</h1>";

// Reparar wp_postmeta (Añadir PRIMARY KEY y luego AUTO_INCREMENT)
$wpdb->query("ALTER TABLE {$wpdb->postmeta} ADD PRIMARY KEY (meta_id)");
$result1 = $wpdb->query("ALTER TABLE {$wpdb->postmeta} MODIFY COLUMN meta_id bigint(20) unsigned NOT NULL AUTO_INCREMENT");

if ($result1 !== false) {
    echo "✅ <b>wp_postmeta</b> reparada exitosamente (Llave Primaria y AUTO_INCREMENT añadidos).<br>";
} else {
    echo "❌ Error reparando wp_postmeta: " . $wpdb->last_error . "<br>";
}

// Reparar wp_usermeta
$wpdb->query("ALTER TABLE {$wpdb->usermeta} ADD PRIMARY KEY (umeta_id)");
$result2 = $wpdb->query("ALTER TABLE {$wpdb->usermeta} MODIFY COLUMN umeta_id bigint(20) unsigned NOT NULL AUTO_INCREMENT");

if ($result2 !== false) {
    echo "✅ <b>wp_usermeta</b> reparada exitosamente (Llave Primaria y AUTO_INCREMENT añadidos).<br>";
} else {
    echo "❌ Error reparando wp_usermeta: " . $wpdb->last_error . "<br>";
}

echo "<h2>¡Reparación Completa! Ahora ve a Elementor y prueba guardar.</h2>";
EOF
chown nobody:nogroup /var/www/html/fix-db.php
