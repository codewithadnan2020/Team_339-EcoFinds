<?php
header('Content-Type: application/json');
// DB connection
include_once '../connection.php';


$result = mysqli_query($conn, "SELECT * FROM `categories` ORDER BY `name` ASC");

if (mysqli_num_rows($result) === 0) {
    http_response_code(404);
    echo json_encode(["error" => "Product not found"]);
    exit;
}
$arr = array();
while ($product = mysqli_fetch_assoc($result)) {
    array_push($arr, $product['name']);
}

echo json_encode($arr);