<?php
header('Content-Type: application/json');

// DB connection
include_once '../connection.php';

$user_id = $_POST['user_id'];


// Input
$username = $_POST['username'];
$email = $_POST['email'];
$card_number = $_POST['card_number'];
$cvc_number = $_POST['cvc_number'];
$expiry = $_POST['expiry'];

$update_sql = "UPDATE users SET `username`='$username', `email`='$email', `card_number`='$card_number', `cvc_number`='$cvc_number', `expiry`='$expiry'  WHERE id = '$user_id'";
if (mysqli_query($conn, $update_sql)) {
    echo json_encode(["message" => "Profile updated successfully"]);
} else {
    http_response_code(500);
    echo json_encode(["error" => "Failed to update", "details" => mysqli_error($conn)]);
}
?>
