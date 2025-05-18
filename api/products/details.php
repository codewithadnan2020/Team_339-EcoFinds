<?php
header('Content-Type: application/json');

// DB connection
include_once '../connection.php';


$product_id = intval($_GET['id'] ?? 0);

if ($product_id === 0) {
    http_response_code(400);
    echo json_encode(["error" => "Missing or invalid product ID"]);
    exit;
}

$sql = "
SELECT 
    p.id,
    p.title,
    p.description,
    p.price,
    p.image_url,
    c.name AS category,
    u.username AS seller,
    p.created_at,
    p.status
FROM products p
JOIN categories c ON p.category_id = c.id
JOIN users u ON p.user_id = u.id
WHERE p.id = '$product_id'
";

$result = mysqli_query($conn, $sql);

if (mysqli_num_rows($result) === 0) {
    http_response_code(404);
    echo json_encode(["error" => "Product not found"]);
    exit;
}

$product = mysqli_fetch_assoc($result);
echo json_encode($product);
?>
