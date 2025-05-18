<?php
header('Content-Type: application/json');

// DB connection
include_once '../connection.php';

$user_id = $_POST['user_id'];


// Input
$username = trim($_POST['username'] ?? '');
$profile_image = trim($_POST['profile_image'] ?? '');

$updates = [];

if ($username !== '') {
    $updates[] = "username = '" . mysqli_real_escape_string($conn, $username) . "'";
}

if ($profile_image !== '') {
    $updates[] = "profile_image = '" . mysqli_real_escape_string($conn, $profile_image) . "'";
}

if (empty($updates)) {
    http_response_code(400);
    echo json_encode(["error" => "No data to update"]);
    exit;
}

$update_sql = "UPDATE users SET " . implode(", ", $updates) . " WHERE id = '$user_id'";
if (mysqli_query($conn, $update_sql)) {
    echo json_encode(["message" => "Profile updated successfully"]);
} else {
    http_response_code(500);
    echo json_encode(["error" => "Failed to update", "details" => mysqli_error($conn)]);
}
?>
