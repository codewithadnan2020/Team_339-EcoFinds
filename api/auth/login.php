<?php
header('Content-Type: application/json');

// DB connection
include_once '../connection.php';

// Get input
$email = trim($_POST['email'] ?? '');
$password = trim($_POST['password'] ?? '');

if (!$email || !$password) {
    http_response_code(400);
    echo json_encode(["error" => "$email All fields are required"]);
    exit;
}

// Check if user exists
$check = mysqli_query($conn, "SELECT id FROM users WHERE email = '$email'");
if (mysqli_num_rows($check) > 0) {
    // Fetch user data
    $user = mysqli_fetch_assoc($check);
    $userId = $user['id'];

    // Verify password
    $passwordCheck = mysqli_query($conn, "SELECT password_hash FROM users WHERE id = '$userId'");
    $passwordData = mysqli_fetch_assoc($passwordCheck);
    
    if (password_verify($password, $passwordData['password_hash'])) {
        $statusUpdate = mysqli_query($conn, "UPDATE users SET login_status = '1' WHERE id = '$userId'");
        if ($statusUpdate) {
            echo json_encode(["message" => "Login successful", "userId" => $userId]);
        }else{
            http_response_code(500);
            echo json_encode(["error" => "Error: " . mysqli_error($conn)]);
        }
    } else {
        http_response_code(401);
        echo json_encode(["error" => "Invalid password"]);
        exit;
    }
}else{
    http_response_code(409);
    echo json_encode(["error" => "Email not registered"]);
    exit;
}
?>
