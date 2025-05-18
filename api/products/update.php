<?php
header('Content-Type: application/json');

// DB connection
include_once '../connection.php';

$user_id = $_POST['user_id'];

// Input
$product_id = intval($_POST['product_id'] ?? 0);
$title = trim($_POST['title'] ?? '');
$description = trim($_POST['description'] ?? '');
$category_name = trim($_POST['category'] ?? '');
$price = floatval($_POST['price'] ?? 0);
$image_url = trim($_POST['image_url'] ?? '');

// Check product ownership
$check = mysqli_query($conn, "SELECT * FROM products WHERE id = '$product_id' AND user_id = '$user_id'");
if (mysqli_num_rows($check) === 0) {
    http_response_code(403);
    echo json_encode(["error" => "Unauthorized or product not found"]);
    exit;
}

// Ensure category exists or create it
$cat_check = mysqli_query($conn, "SELECT id FROM categories WHERE name = '$category_name'");
if (mysqli_num_rows($cat_check)) {
    $category_id = mysqli_fetch_assoc($cat_check)['id'];
} else {
    mysqli_query($conn, "INSERT INTO categories (name) VALUES ('$category_name')");
    $category_id = mysqli_insert_id($conn);
}

// Update product
$update = mysqli_query($conn, "
    UPDATE products SET
    title = '$title',
    description = '$description',
    category_id = '$category_id',
    price = '$price',
    image_url = '$image_url'
    WHERE id = '$product_id'
");

if ($update) {
    echo json_encode(["message" => "Product updated"]);
} else {
    http_response_code(500);
    echo json_encode(["error" => "Update failed", "details" => mysqli_error($conn)]);
}
?>
