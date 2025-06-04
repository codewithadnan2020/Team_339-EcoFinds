<?php
header('Content-Type: application/json');

// DB connection
include_once '../connection.php';

$user_id = $_GET['user_id'];
$product_id = $_GET['product_id'];
$bidDetails = array();


$maxresult = mysqli_query($conn, "SELECT MAX(bid_amount) as bid_amount FROM `bids`");
while ($row = mysqli_fetch_assoc($maxresult)) {
    // array_push($bidDetails, $row["bid_amount"]);
    $bidDetails["max_amount"] =  $row["bid_amount"];
}
$myresult = mysqli_query($conn, "SELECT MAX(bid_amount) as bid_amount FROM `bids` WHERE user_id='$user_id'");
while ($myrow = mysqli_fetch_assoc($myresult)) {
    $bidDetails["my_amount"] =  $myrow["bid_amount"];
}

echo json_encode($bidDetails);