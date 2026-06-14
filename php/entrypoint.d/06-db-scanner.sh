#!/bin/bash
# Crear el escáner de base de datos automáticamente
cat << 'EOF' > /var/www/html/scan-db.php
<?php
header("Cache-Control: no-store, no-cache");
require 'wp-load.php';
global $wpdb;

echo "<h1>Reporte de Salud de Base de Datos WordPress</h1>";

// 1. Revisar AUTO_INCREMENT
echo "<h2>1. Verificación de AUTO_INCREMENT y Primary Keys</h2>";
$core_tables = [
    $wpdb->posts => 'ID',
    $wpdb->postmeta => 'meta_id',
    $wpdb->users => 'ID',
    $wpdb->usermeta => 'umeta_id',
    $wpdb->options => 'option_id',
];

echo "<table border='1' cellpadding='5' style='border-collapse:collapse; text-align:left; font-family:sans-serif;'>";
echo "<tr style='background:#eee;'><th>Tabla</th><th>PK</th><th>¿Tiene AUTO_INCREMENT?</th><th>Max ID Actual</th><th>Siguiente AUTO_INCREMENT</th><th>Estado</th></tr>";

foreach ($core_tables as $table => $pk) {
    $cols = $wpdb->get_results("SHOW COLUMNS FROM {$table}");
    $has_ai = false;
    foreach ($cols as $col) {
        if ($col->Field === $pk && strpos(strtolower($col->Extra), 'auto_increment') !== false) {
            $has_ai = true;
        }
    }

    $max_id = $wpdb->get_var("SELECT MAX({$pk}) FROM {$table}") ?: 0;
    $table_status = $wpdb->get_row("SHOW TABLE STATUS LIKE '{$table}'");
    $next_ai = $table_status->Auto_increment;

    $status = "✅ OK"; $color = "green";
    if (!$has_ai) { $status = "❌ FALTA AUTO_INCREMENT"; $color = "red"; }
    elseif ($next_ai <= $max_id && $max_id > 0) { $status = "❌ ROTO (Siguiente < Max)"; $color = "red"; }

    echo "<tr style='color:$color;'><td>{$table}</td><td>{$pk}</td><td>" . ($has_ai ? 'Sí' : 'NO') . "</td><td>{$max_id}</td><td>{$next_ai}</td><td><b>{$status}</b></td></tr>";
}
echo "</table>";
EOF
chown nobody:nogroup /var/www/html/scan-db.php
