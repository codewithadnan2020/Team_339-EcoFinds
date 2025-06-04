
<?php
header('Content-Type: application/json');
include_once '../connection.php';

$user_id = $_POST['user_id'] ?? '';
$title = trim($_POST['title'] ?? '');
$description = trim($_POST['description'] ?? '');
$category_name = trim($_POST['category'] ?? '');
$price = floatval($_POST['price'] ?? 0);

if (!$title || !$category_name || $price <= 0) {
    http_response_code(400);
    echo json_encode(["error" => "Title, category, and valid price are required"]);
    exit;
}

// Handle image upload
$image_url = '';
if (isset($_FILES['image']) && $_FILES['image']['error'] === UPLOAD_ERR_OK) {
    $uploads_dir = __DIR__ . '/uploads';
    if (!is_dir($uploads_dir)) {
        mkdir($uploads_dir, 0777, true);
    }
    $tmp_name = $_FILES['image']['tmp_name'];
    $basename = basename($_FILES['image']['name']);
    $ext = pathinfo($basename, PATHINFO_EXTENSION);
    $filename = uniqid('img_', true) . '.' . $ext;
    $target_path = $uploads_dir . '/' . $filename;
    if (move_uploaded_file($tmp_name, $target_path)) {
        $image_url = 'uploads/' . $filename;
    } else {
        http_response_code(500);
        echo json_encode([
            "error" => "Failed to upload image",
            "tmp_name" => $tmp_name,
            "target_path" => $target_path,
            "php_error" => $_FILES['image']['error'],
            "is_uploaded" => is_uploaded_file($tmp_name)
        ]);
        exit;
    }
} else {
    http_response_code(400);
    echo json_encode([
        "error" => "Image is required or upload error",
        "php_error" => $_FILES['image']['error'] ?? 'no file'
    ]);
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