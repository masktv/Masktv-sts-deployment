#!/bin/bash
set -e

# Wait for MySQL to start
until mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "SELECT 1;" > /dev/null 2>&1; do
  echo "Waiting for MySQL to start..."
  sleep 5
done

# Check if MySQL is running in master mode
if [[ "$MYSQL_REPLICATION_MODE" == "master" ]]; then
  echo "Configuring MySQL as master..."

  # Create the application user if it doesn't exist (for your app)
  mysql -u root -p"$MYSQL_ROOT_PASSWORD" <<-EOSQL
    CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;
    CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
    GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';
    FLUSH PRIVILEGES;
EOSQL

  # Create the replication user if it doesn't exist (for replication purposes)
  mysql -u root -p"$MYSQL_ROOT_PASSWORD" <<-EOSQL
    CREATE USER IF NOT EXISTS 'replica_user'@'%' IDENTIFIED BY 'replica_password';
    GRANT REPLICATION SLAVE ON *.* TO 'replica_user'@'%';
    FLUSH PRIVILEGES;

    # Alter the replication user to use mysql_native_password
    ALTER USER 'replica_user'@'%' IDENTIFIED WITH mysql_native_password BY 'replica_password';
    FLUSH PRIVILEGES;
EOSQL

  # Enable binary logging
  mysql -u root -p"$MYSQL_ROOT_PASSWORD" <<-EOSQL
    SET GLOBAL log_bin = 'mysql-bin';
    SET GLOBAL binlog_do_db = '$MYSQL_DATABASE';
    SET GLOBAL log_slave_updates = 1;
    SET GLOBAL read_only = 0;
EOSQL

  # Output the master's binary log file and position for the slave to use
  MASTER_STATUS=$(mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "SHOW MASTER STATUS;" | tail -n 1)
  MASTER_LOG_FILE=$(echo $MASTER_STATUS | cut -d' ' -f1)
  MASTER_LOG_POS=$(echo $MASTER_STATUS | cut -d' ' -f2)

  # Write the binary log info to a file for slave pods
  echo "MASTER_LOG_FILE=$MASTER_LOG_FILE" > /tmp/master_log.txt
  echo "MASTER_LOG_POS=$MASTER_LOG_POS" >> /tmp/master_log.txt

  echo "Master setup completed."
fi

# Check if MySQL is running in slave mode
if [[ "$MYSQL_REPLICATION_MODE" == "slave" ]]; then
  echo "Configuring MySQL as slave..."

  # Read master log information (from master pod's init)
  MASTER_LOG_FILE=$(cat /tmp/master_log.txt | grep MASTER_LOG_FILE | cut -d'=' -f2)
  MASTER_LOG_POS=$(cat /tmp/master_log.txt | grep MASTER_LOG_POS | cut -d'=' -f2)

  # Configure the slave to start replication
  mysql -u root -p"$MYSQL_ROOT_PASSWORD" <<-EOSQL
    CHANGE MASTER TO
      MASTER_HOST = '$MYSQL_MASTER_HOST',
      MASTER_USER = 'replica_user',
      MASTER_PASSWORD = 'replica_password',
      MASTER_LOG_FILE = '$MASTER_LOG_FILE',
      MASTER_LOG_POS = $MASTER_LOG_POS;

    START SLAVE;
    SHOW SLAVE STATUS\G
EOSQL

  echo "Slave setup completed."
fi

# Keep the container running
tail -f /dev/null
