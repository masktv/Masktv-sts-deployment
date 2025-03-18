
1. test with using secret for env adding in both slave and master
2. test by adding variable in init.sh for replica user and their pass
3. test with scalling replicas of in slave
4. test with using ebs csi driver --> test --> done
.....................................................................................................................
   -->  ssh in to proxysql pod
         1.  SELECT * FROM mysql_users LIMIT 1;
         2.  INSERT INTO mysql_users (username, password, active, default_hostgroup)
             VALUES ('admin', 'admin', 1, 0);
         3.  LOAD MYSQL USERS TO RUNTIME;
             SAVE MYSQL USERS TO DISK;
         4.  mysql -h proxysql-service -P 6033 -u admin -p
