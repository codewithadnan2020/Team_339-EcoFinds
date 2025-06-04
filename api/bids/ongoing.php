<?php
header('Content-Type: application/json');

// DB connection
include_once '../connection.php';

$product_id = $_GET['product_id'];


$result = mysqli_query($conn, "SELECT * FROM `bids` WHERE `product_id`='$product_id' ORDER BY `bid_dt` DESC");
$bid = [];

while ($row = mysqli_fetch_assoc($result)) {
    $bid[] = $row;
}

echo json_encode($bid);