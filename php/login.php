<?php
$host = '127.0.0.1';
$db = 'toko';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $username = $_POST['username'];
    $password = $_POST['password'];

    try {

    
    $connect = mysqli_connect(hostname:$host, username:$username, password:$password, database:$db);

    if (!$connect) {
        $out = array('status' => 'error', 'message'=> 'Login gagal!' . mysqli_connect_error());
echo json_encode($out);

    } else {
      updateToken($connect, $username);

    }
} catch (Exception $e) {
    $out = array('status' => 'error', 'message'=> 'Login gagal!' . mysqli_connect_error() );
echo json_encode($out);


}

}

function updateToken($connect,$username) {
  
$token = generateToken();
$query = 'update toko.user set token = ? where username = ?';
$stmt = mysqli_prepare($connect, $query);
mysqli_stmt_bind_param($stmt, 'ss', $token, $username);
if (mysqli_stmt_execute($stmt)){
  $out = array(
    'status' => 'sukses', 'message' => "Login sebagai $username!", 'token' => $token
); 
} else {
  $out = array('status' => 'error', 'message'=> 'Login gagal!' . mysqli_connect_error() );
}
header('Content-Type: Application/json');

echo json_encode($out);
}

function generateToken() {
  return bin2hex(random_bytes(32));
}
?>