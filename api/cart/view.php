<?php
header('Content-Type: application/json');

// DB connection
include_once '../connection.php';

$user_id = $_GET['user_id'];

// Get cart items
$sql = "
SELECT p.id, p.user_id, p.title, p.description, p.price, p.image_url, c.name AS category
FROM cart_items ci
JOIN products p ON ci.product_id = p.id
JOIN categories c ON p.category_id = c.id
WHERE ci.user_id = '$user_id'
";

$result = mysqli_query($conn, $sql);
$cart = [];

while ($row = mysqli_fetch_assoc($result)) {
    $cart[] = $row;
}

echo json_encode($cart);
?>
