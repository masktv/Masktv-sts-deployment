
1. test with using secret for env adding in both slave and master
2. test by adding variable in init.sh for replica user and their pass
3. test with scalling replicas of in slave
4. test with using ebs csi driver --> test --> done
.....................................................................................................................

kubectl exec -it <proxysql-pod-name> -- /bin/bash   ------- ssh in to proxysql pod
before run below cmd first forward port on 6032 port
then    mysql -u admin -p -h 127.0.0.1 -P 6032 --> this connect with admin panel in proxysql

then  --> set  backend server

-- Add the master server
INSERT INTO mysql_servers (hostgroup_id, hostname, port) VALUES (0, 'masktv-mysql-master-service', 3306);
-- Add the slave server
INSERT INTO mysql_servers (hostgroup_id, hostname, port) VALUES (1, 'masktv-mysql-slave-service', 3306);
-- Add the application user
INSERT INTO mysql_users (username, password, default_hostgroup, transaction_persistent) 
VALUES ('myUser', 'myUserPassword', 0, 1);

-----> Configure Query Rules for Read-Write Splitting

-- Route READ queries to the slave
INSERT INTO mysql_query_rules (active, match_pattern, destination_hostgroup) 
VALUES (1, '^SELECT|^SHOW|^DESCRIBE|^EXPLAIN|^INFORMATION_SCHEMA', 1);
#INSERT INTO mysql_query_rules (active, match_pattern, destination_hostgroup) 
#VALUES (1, '^SELECT', 1);

-- Route INSERT, UPDATE, DELETE queries to the master
INSERT INTO mysql_query_rules (active, match_pattern, destination_hostgroup) 
VALUES (1, '^INSERT|^UPDATE|^DELETE|^REPLACE|^TRUNCATE|^CREATE|^ALTER|^DROP|^GRANT|^REVOKE|^LOCK|^UNLOCK|^RENAME|^OPTIMIZE|^ANALYZE', 0);
#INSERT INTO mysql_query_rules (active, match_pattern, destination_hostgroup) 
#VALUES (1, '^INSERT|^UPDATE|^DELETE', 0);

----> Load Configuration In Runtime

-- Load servers into runtime
LOAD MYSQL SERVERS TO RUNTIME;
-- Load users into runtime
LOAD MYSQL USERS TO RUNTIME;
-- Load query rules into runtime
LOAD MYSQL QUERY RULES TO RUNTIME;

-----> save Config to Disk 

-- Save servers to disk
SAVE MYSQL SERVERS TO DISK;
-- Save users to disk
SAVE MYSQL USERS TO DISK;
-- Save query rules to disk
SAVE MYSQL QUERY RULES TO DISK;

-- to connect from any host

UPDATE mysql_users
SET attributes = '{}'
WHERE username = 'myUser';

--  refresh
LOAD MYSQL USERS TO RUNTIME;
SAVE MYSQL USERS TO DISK;

---> Varify Configuration

SELECT * FROM mysql_servers;   --> check backend server -->  master slave service name
SELECT * FROM mysql_users;     --> application user
SELECT * FROM mysql_query_rules;  --> check query rule to check how proxysql route traffic on master slave 
..........................................................................................................
after check on master pod accesable from svc name of proxysql pod svc
mysql -u myUser -p -h proxysql.default.svc.cluster.local -P 6033    --> this should be accesseble

 
