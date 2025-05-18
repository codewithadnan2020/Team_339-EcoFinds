<?php
header('Content-Type: application/json');
include_once '../connection.php';

$user_id = $_POST['user_id'];

// Get purchase history
$sql = "
SELECT p.id AS product_id, p.title, p.description, p.price, p.image_url, c.name AS category, pur.purchased_at
FROM purchases pur
JOIN products p ON pur.product_id = p.id
JOIN categories c ON p.category_id = c.id
WHERE pur.user_id = '$user_id'
ORDER BY pur.purchased_at DESC
";

$result = mysqli_query($conn, $sql);
$purchases = [];

while ($row = mysqli_fetch_assoc($result)) {
    $purchases[] = $row;
}

echo json_encode($purchases);
?>
