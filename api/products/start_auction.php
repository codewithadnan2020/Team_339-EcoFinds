<?php
header('Content-Type: application/json');
// DB connection
include_once '../connection.php';

$user_id = $_POST['user_id'];
$end_time = $_POST['end_time'];

$product_id = intval($_POST['product_id'] ?? 0);

// Check ownership
$check = mysqli_query($conn, "SELECT id FROM products WHERE id = '$product_id' AND user_id = '$user_id'");
if (mysqli_num_rows($check) === 0) {
    http_response_code(403);
    echo json_encode(["error" => "Not your product or doesn't exist"]);
    exit;
}

// Delete
$delete = mysqli_query($conn, "UPDATE products SET `auction_end_time`='$end_time' WHERE id = '$product_id'");
if ($delete) {
    echo json_encode(["message" => "Product Updated"]);
} else {
    http_response_code(500);
    echo json_encode(["error" => "Update failed", "details" => mysqli_error($conn)]);
}
?>
