<?php
header('Content-Type: application/json');

// DB connection
include_once '../connection.php';

$receiver_id = $_GET['receiver_id'];

$msgQuery = mysqli_query($conn, "SELECT * FROM `chat_ui` WHERE `receiver_id`='$receiver_id' ORDER BY `dt` ASC");
$arr = [];
if (mysqli_num_rows($msgQuery) > 0) {
    while($msg = mysqli_fetch_assoc($msgQuery)){
        $arr[] = $msg;
    }
}
echo json_encode($arr);