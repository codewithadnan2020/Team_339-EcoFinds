<?php
header('Content-Type: application/json');

// DB connection
include_once '../connection.php';

$user_id = $_GET['user_id'];
$receiver_id = $_GET['receiver_id'];
$msg = $_GET['msg'];

$msgQuery = mysqli_query($conn, "INSERT INTO `chat_ui`(`user_id`, `receiver_id`, `sent`, `datetime`, `dt`) VALUES ('$user_id','$receiver_id','$msg', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP())");

echo json_encode($msgQuery);