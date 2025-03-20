<?php
$proxysql_host = "proxysql.default.svc.cluster.local";
$proxysql_port = 6033;
$username = "myUser";
$password = "myUserPassword";
$dbname = "myDatabase";

// Create connection
$conn = new mysqli($proxysql_host, $username, $password, $dbname, $proxysql_port);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

try {
    // Start transaction
    $conn->begin_transaction();

    // Insert MySQL server hostname and ProxySQL connection port into test_routing
    $sql_insert = "INSERT INTO test_routing (value)
                    SELECT CONCAT(@@hostname, ':', $proxysql_port)";

    if (!$conn->query($sql_insert)) {
        throw new Exception("Insert failed: " . $conn->error);
    }

    // Get hostname of the server handling the write
    $result_write_host = $conn->query("SELECT @@hostname as write_hostname;");
    if ($result_write_host) {
        $row_write_host = $result_write_host->fetch_assoc();
        $write_hostname = $row_write_host['write_hostname'];
        $result_write_host->free();
        echo "Write request handled by server with hostname: " . $write_hostname . "<br>";
    } else {
        echo "Error fetching hostname for write operation: " . $conn->error . "<br>";
        throw new Exception("Error fetching hostname for write operation");
    }

    // Commit transaction
    $conn->commit();

    echo "Hostname and ProxySQL port inserted successfully into test_routing!<br>";

    // Verify insertion (Fetch last inserted row)
    $sql_select = "SELECT * FROM test_routing ORDER BY id DESC LIMIT 1";
    $result_read = $conn->query($sql_select);

    if ($result_read->num_rows > 0) {
        $row_read = $result_read->fetch_assoc();
        echo "Inserted Hostname:Port -> " . $row_read['value'] . "<br>";

        // Get hostname of the server handling the read
        $result_read_host = $conn->query("SELECT @@hostname as read_hostname;");
        if ($result_read_host) {
            $row_read_host = $result_read_host->fetch_assoc();
            $read_hostname = $row_read_host['read_hostname'];
            $result_read_host->free();
            echo "Read request handled by server with hostname: " . $read_hostname . "<br>";
        } else {
            echo "Error fetching hostname for read operation: " . $conn->error . "<br>";
        }
    } else {
        throw new Exception("Failed to retrieve inserted hostname and port.");
    }
} catch (Exception $e) {
    // Rollback transaction in case of error
    $conn->rollback();
    echo "Transaction failed: " . $e->getMessage();
}

// Close connection
$conn->close();
?>
