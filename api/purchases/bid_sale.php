<?php
header('Content-Type: application/json');

// DB connection
include_once '../connection.php';

$pay = $_POST['pay'];
$product_id = $_POST['product_id'];
// Insert into purchases
$bidQuery = mysqli_query($conn, "SELECT `user_id`, `bid_amount` FROM `bids` WHERE `product_id` = '$product_id' ORDER BY `bid_dt` DESC LIMIT 1 ");

if(mysqli_num_rows($bidQuery) > 0){
    $bidData = mysqli_fetch_array($bidQuery);
    $user_id = $bidData["user_id"];
    $bid_amount = $bidData["bid_amount"];
    if ($pay == '1') {
        mysqli_query($conn, "
        INSERT INTO purchases (user_id, product_id)
        VALUES ('$user_id', '$product_id')
        ");
        // Optional: mark product as sold (only if it's not already)
        mysqli_query($conn, "UPDATE `products` SET `status` = 'sold' AND `price`='$bid_amount' WHERE `id` = '$product_id' AND `status` = 'available'");
    }
    echo json_encode(array("type"=>"1", "msg"=>"$user_id:Have Won The bid."));
}else{
    echo json_encode(array("type"=>"2", "msg"=>"No Bid Found."));
}