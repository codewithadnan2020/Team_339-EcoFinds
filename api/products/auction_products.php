<?php
header('Content-Type: application/json');
include_once '../connection.php';

$user_id = mysqli_real_escape_string($conn, $_GET['user_id'] ?? '');
$search = mysqli_real_escape_string($conn, $_GET['search'] ?? '');
$category = mysqli_real_escape_string($conn, $_GET['category'] ?? '');

$sql = "
SELECT p.user_id, p.id, p.title, p.description, p.price, p.image_url, c.name AS category, u.username, p.auction_end_time
FROM products p
JOIN categories c ON p.category_id = c.id
JOIN users u ON p.user_id = u.id
WHERE p.auction_end_time != ''
  AND STR_TO_DATE(p.auction_end_time, '%Y-%m-%d %H:%i') > NOW()";

if ($search !== '') {
    $sql .= " AND p.title LIKE '%$search%'";
}

if ($category !== '') {
    $sql .= " AND c.name = '$category'";
}

$sql .= " ORDER BY p.created_at DESC";

$result = mysqli_query($conn, $sql);

$products = [];
while ($row = mysqli_fetch_assoc($result)) {
    $products[] = $row;
}
echo json_encode($products);
?>