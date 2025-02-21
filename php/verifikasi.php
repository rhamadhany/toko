<?php

$host = '127.0.0.1';
$db = 'toko';
$user = 'admin';
$pass = '10toko00';
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $connect = mysqli_connect(hostname:$host,username: $user,password: $pass,database: $db);
    $username = $_POST['username'] ?? '';
    $token = $_POST['token'] ?? '';
    
    $query = 'SELECT token FROM toko.user WHERE username = ?';
    $stmt = mysqli_prepare($connect, $query);
    
    if ($stmt) {
        mysqli_stmt_bind_param($stmt, 's', $username);
        $result = mysqli_stmt_execute($stmt);
        if ($result) {
          mysqli_stmt_bind_result($stmt, $token_db);
          if (mysqli_stmt_fetch($stmt)) {
            if ($token_db === $token) {
              $out = array('status' => 'sukses', 'message' => 'Login berhasil!');
            } else {
              $out = array('status' => 'error', 'message' => 'Login gagal!');
            }
            echo json_encode($out);
          }
        }
        
        mysqli_stmt_close($stmt);
    }
    mysqli_close($connect);
}
?>

