<?php
header('Content-Type: application/json');
// DB connection
include_once '../connection.php';

$user_id = $_POST['user_id'];

// Get request data
$title = trim($_POST['title'] ?? '');
$description = trim($_POST['description'] ?? '');
$category_name = trim($_POST['category'] ?? '');
$price = floatval($_POST['price'] ?? 0);
$image_url = trim($_POST['image_url'] ?? '');

if (!$title || !$category_name || $price <= 0) {
    http_response_code(400);
    echo json_encode(["error" => "Title, category, and valid price are required"]);
    exit;
}

// Check or insert category
$category_check = mysqli_query($conn, "SELECT id FROM categories WHERE name = '$category_name'");
if (mysqli_num_rows($category_check) > 0) {
    $category_row = mysqli_fetch_assoc($category_check);
    $category_id = $category_row['id'];
} else {
    mysqli_query($conn, "INSERT INTO categories (name) VALUES ('$category_name')");
    $category_id = mysqli_insert_id($conn);
}

// Insert product
$sql = "INSERT INTO products (user_id, title, description, category_id, price, image_url)
        VALUES ('$user_id', '$title', '$description', '$category_id', '$price', '$image_url')";

if (mysqli_query($conn, $sql)) {
    echo json_encode([
        "message" => "Product listed successfully",
        "product_id" => mysqli_insert_id($conn)
    ]);
} else {
    http_response_code(500);
    echo json_encode(["error" => "Failed to create product", "details" => mysqli_error($conn)]);
}
?>
