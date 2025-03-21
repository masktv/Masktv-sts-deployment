#!/bin/bash

# Wait for ProxySQL to start before running commands
echo "Waiting for ProxySQL to start..."
sleep 10

# Add the master server
echo "Adding master server..."
mysql -u $ADMIN_USER -p$ADMIN_USER_PASSWORD -h 127.0.0.1 -P 6032 -e "
INSERT INTO mysql_servers (hostgroup_id, hostname, port) VALUES ($MYSQL_HOSTGROUP_MASTER, '$MYSQL_MASTER_HOST', 3306);
"

# Add the slave server
echo "Adding slave server..."
mysql -u $ADMIN_USER -p$ADMIN_USER_PASSWORD -h 127.0.0.1 -P 6032 -e "
INSERT INTO mysql_servers (hostgroup_id, hostname, port) VALUES ($MYSQL_HOSTGROUP_SLAVE, '$MYSQL_SLAVE_HOST', 3306);
"

# Add the application user
echo "Adding application user..."
mysql -u $ADMIN_USER -p$ADMIN_USER_PASSWORD -h 127.0.0.1 -P 6032 -e "
INSERT INTO mysql_users (username, password, default_hostgroup, transaction_persistent) 
VALUES ('$MYSQL_USER', '$MYSQL_PASSWORD', $MYSQL_HOSTGROUP_MASTER, 1);
"

# Configure query rules
echo "Configuring query rules..."
mysql -u $ADMIN_USER -p$ADMIN_USER_PASSWORD -h 127.0.0.1 -P 6032 -e "
INSERT INTO mysql_query_rules (active, match_pattern, destination_hostgroup) 
VALUES (1, '^SELECT', $MYSQL_HOSTGROUP_SLAVE);
"
mysql -u $ADMIN_USER -p$ADMIN_USER_PASSWORD -h 127.0.0.1 -P 6032 -e "
INSERT INTO mysql_query_rules (active, match_pattern, destination_hostgroup) 
VALUES (1, '^INSERT|^UPDATE|^DELETE', $MYSQL_HOSTGROUP_MASTER);
"

# Load and save configuration
echo "Loading configuration..."
mysql -u $ADMIN_USER -p$ADMIN_USER_PASSWORD -h 127.0.0.1 -P 6032 -e "
LOAD MYSQL SERVERS TO RUNTIME;
LOAD MYSQL USERS TO RUNTIME;
LOAD MYSQL QUERY RULES TO RUNTIME;
SAVE MYSQL SERVERS TO DISK;
SAVE MYSQL USERS TO DISK;
SAVE MYSQL QUERY RULES TO DISK;
"

# Allow the application user to connect from any host
echo "Allowing application user to connect from any host..."
mysql -u $ADMIN_USER -p$ADMIN_USER_PASSWORD -h 127.0.0.1 -P 6032 -e "
UPDATE mysql_users SET attributes = '{}' WHERE username = '$MYSQL_USER';
"

# Refresh user configurations
echo "Refreshing user configuration..."
mysql -u $ADMIN_USER -p$ADMIN_USER_PASSWORD -h 127.0.0.1 -P 6032 -e "
LOAD MYSQL USERS TO RUNTIME;
SAVE MYSQL USERS TO DISK;
"

echo "ProxySQL setup complete."
