<?php
header('Content-Type: application/json');

// DB connection
include_once '../connection.php';

$user_id = $_POST['user_id'];

// Get input
$product_id = intval($_POST['product_id'] ?? 0);

// Check if product exists and not owned by user
$product_check = mysqli_query($conn, "SELECT id, user_id FROM products WHERE id = '$product_id'");
if (mysqli_num_rows($product_check) === 0) {
    http_response_code(404);
    echo json_encode(["error" => "Product not found"]);
    exit;
}
$product = mysqli_fetch_assoc($product_check);
if ($product['user_id'] == $user_id) {
    http_response_code(403);
    echo json_encode(["error" => "You can't add your own product to cart"]);
    exit;
}

// Prevent duplicate cart entries
$already = mysqli_query($conn, "SELECT id FROM cart_items WHERE user_id = '$user_id' AND product_id = '$product_id'");
if (mysqli_num_rows($already)) {
    echo json_encode(["message" => "Already in cart"]);
    exit;
}

// Add to cart
mysqli_query($conn, "INSERT INTO cart_items (user_id, product_id) VALUES ('$user_id', '$product_id')");
echo json_encode(["message" => "Product added to cart"]);
?>
