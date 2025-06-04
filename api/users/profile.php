<?php
header('Content-Type: application/json');

include_once '../connection.php';

$user_id = $_POST['user_id'];

// Get user data
$result = mysqli_query($conn, "
    SELECT id, email, username, card_number, cvc_number,expiry, profile_image, login_status, created_at
    FROM users
    WHERE id = '$user_id'
");

if ($row = mysqli_fetch_assoc($result)) {
    echo json_encode($row);
} else {
    http_response_code(500);
    echo json_encode(["error" => "User not found"]);
}
?>
