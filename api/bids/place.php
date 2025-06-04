<?php
header('Content-Type: application/json');

// DB connection
include_once '../connection.php';

$user_id = $_POST['user_id'];
$product_id = $_POST['product_id'];
$amount = $_POST['amount'];


$result = mysqli_query($conn, "INSERT INTO `bids`(`user_id`, `product_id`, `bid_amount`, `bid_dt`, `dt`) VALUES ('$user_id','$product_id','$amount',CURRENT_TIMESTAMP(),CURRENT_TIMESTAMP())");
echo json_encode(["message" => "Bid placed successfully."]);