<?php
// header('Content-Type: application/json');

// DB connection
include_once '../connection.php';

// Get input
$email = trim($_POST['email'] ?? '');
$password = trim($_POST['password'] ?? '');
$username = trim($_POST['username'] ?? '');

if (!$email || !$password || !$username) {
    http_response_code(400);
    echo json_encode(["error" => "All fields are required"]);
    exit;
}

// Check if user exists
$check = mysqli_query($conn, "SELECT id FROM users WHERE email = '$email'");
if (mysqli_num_rows($check) > 0) {
    http_response_code(409);
    echo json_encode(["error" => "Email already registered"]);
    exit;
}

// Register user
$hashed = password_hash($password, PASSWORD_BCRYPT);
$sql = "INSERT INTO users (email, password_hash, username) VALUES ('$email', '$hashed', '$username')";
if (mysqli_query($conn, $sql)) {
    $checkRegistration = mysqli_query($conn, "SELECT id FROM users WHERE email = '$email'");
    $user = mysqli_fetch_assoc($checkRegistration);
    $userId = $user['id'];
    echo json_encode(["message" => "Registration successful", "userId"=>$userId]);
} else {
    http_response_code(500);
    echo json_encode(["error" => "Error: " . mysqli_error($conn)]);
}
?>
