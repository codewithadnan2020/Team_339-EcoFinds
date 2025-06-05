<?php
header('Content-Type: application/json');

// DB connection
include_once '../connection.php';

$user_id = $_GET['user_id'];
$receiver_id = $_GET['receiver_id'];

$msgQuery = mysqli_query($conn, "SELECT * FROM `chat_ui` WHERE (`user_id`='$user_id' AND `receiver_id`='$receiver_id') OR (`user_id`='$receiver_id' AND `receiver_id`='$user_id') ORDER BY `dt` ASC");
$arr = [];
if (mysqli_num_rows($msgQuery) > 0) {
    while($msg = mysqli_fetch_assoc($msgQuery)){
        $arr[] = $msg;
    }
}
echo json_encode($arr);