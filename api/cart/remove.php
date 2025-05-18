<?php
header('Content-Type: application/json');

// DB connection
include_once '../connection.php';

$user_id = $_POST['user_id'];

// Input
$product_id = intval($_POST['product_id'] ?? 0);

$del = mysqli_query($conn, "DELETE FROM cart_items WHERE user_id = '$user_id' AND product_id = '$product_id'");
if ($del) {
    echo json_encode(["message" => "Product removed from cart"]);
} else {
    http_response_code(500);
    echo json_encode(["error" => "Failed to remove from cart"]);
}
?>
