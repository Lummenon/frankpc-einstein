<?php
/**
 * PLANTILLA de conexión a la base de datos.
 *
 * Copia este archivo como  config/db.php  y rellena tus datos.
 * El archivo db.php real está en .gitignore y nunca se sube al repo.
 *
 * Pasos para poner en marcha el proyecto:
 *   1. cp config/db.example.php config/db.php
 *   2. Edita db.php con tu usuario y contraseña
 *   3. Importa la BD: mariadb -u root -p < config/data_base_components.sql
 */

$host   = 'localhost';
$dbname = 'componentes_pc';
$user   = 'TU_USUARIO';   // ← cámbialo
$pass   = 'TU_PASSWORD';  // ← cámbialo

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8", $user, $pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    die("Error de conexión: " . $e->getMessage());
}

function getOptions($pdo, $table, $col, $pk) {
    try {
        $sql = "SELECT t.$pk as id, t.$col as nombre, r.nombre as tier
                FROM $table t
                JOIN ref_tier r ON t.id_tier = r.id_tier
                ORDER BY t.id_tier ASC, t.$col ASC";
        return $pdo->query($sql)->fetchAll(PDO::FETCH_ASSOC);
    } catch (Exception $e) { return []; }
}
