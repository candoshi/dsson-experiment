<?php
// this path should point to your configuration file.
include('database_config.php');

$data_array = json_decode(file_get_contents('php://input'), true);
if(isset($data_array[0]['table'])){
  $table = $data_array[0]['table'];
}
  $uid = $data_array[0]['uid'];

try {
  $conn = new PDO("mysql:host=$servername;port=$port;dbname=$dbname", $username, $password);
  $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
  // First stage is to get all column names from the table and store
  // them in $col_names array.
  $stmt = $conn->prepare("SHOW COLUMNS FROM `$table`");
  $stmt->execute();
  $col_names = array();
  while($row = $stmt->fetchColumn()) {
    $col_names[] = $row;
  }

  $update_array = array_intersect_key($data_array[0],array_flip($col_names));
  $sql = "UPDATE $table ";
  $sql .= "SET ";
  $i = 0;
  foreach ($update_array as $key=>$value){
    $valuename = $key."_value";
    //echo "setting :$key=:$valuename\n";
    $sql .= "$key";
    $sql .= "=:$valuename";
    if($i != count($update_array)-1){
      $sql .= ", ";
    }
    $i = $i +1; 
  }
  $sql .= " WHERE uid=:uid_val ;";
  $insertstmt = $conn->prepare($sql);
  $insertstmt->bindValue(":uid_val", $uid);
  foreach($update_array as $key=>$value){
    $valuename = $key."_value";
    $insertstmt->bindValue(":$valuename", $value);
  }
  $insertstmt->execute();
  echo '{"success": true}';
} catch(PDOException $e) {
  echo '{"success": false, "message": ' . $e->getMessage();
}
$conn = null;
?>