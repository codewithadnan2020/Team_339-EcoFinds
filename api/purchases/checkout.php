<?php
header('Content-Type: application/json');

// DB connection
include_once '../connection.php';

$user_id = $_POST['user_id'];

// Fetch cart items
$cart_items = mysqli_query($conn, "
    SELECT product_id FROM cart_items WHERE user_id = '$user_id'
");

if (mysqli_num_rows($cart_items) === 0) {
    http_response_code(400);
    echo json_encode(["error" => "Cart is empty"]);
    exit;
}

$success = 0;
while ($row = mysqli_fetch_assoc($cart_items)) {
    $product_id = $row['product_id'];
    // Insert into purchases
    mysqli_query($conn, "
        INSERT INTO purchases (user_id, product_id)
        VALUES ('$user_id', '$product_id')
    ");

    // Optional: mark product as sold (only if it's not already)
    mysqli_query($conn, "
        UPDATE products SET status = 'sold'
        WHERE id = '$product_id' AND status = 'available'
    ");

    // Remove from cart
    mysqli_query($conn, "
        DELETE FROM cart_items WHERE user_id = '$user_id' AND product_id = '$product_id'
    ");

    $success++;
}
echo json_encode([
    "message" => "$success product(s) purchased successfully"
]);
?>
