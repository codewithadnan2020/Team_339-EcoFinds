<?php
header('Content-Type: application/json');

// DB connection
include_once '../connection.php';

// Get input
$email = trim($_POST['email'] ?? '');

if (!$email) {
    http_response_code(400);
    echo json_encode(["error" => "Email Id is required"]);
    exit;
}

// Check if user exists
$check = mysqli_query($conn, "SELECT id FROM users WHERE email = '$email'");
if (mysqli_num_rows($check) > 0) {
    // Fetch user data
    $user = mysqli_fetch_assoc($check);
    $userId = $user['id'];
    $statusUpdate = mysqli_query($conn, "UPDATE users SET login_status = '' WHERE id = '$userId'");
    if ($statusUpdate) {
        echo json_encode(["message" => "Logout successful", "userId" => $userId]);
    }else{
        http_response_code(500);
        echo json_encode(["error" => "Error: " . mysqli_error($conn)]);
    }
}else{
    http_response_code(409);
    echo json_encode(["error" => "Email not registered"]);
    exit;
}
?>
