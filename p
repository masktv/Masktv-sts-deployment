apiVersion: v1
kind: Pod
metadata:
  name: mysql-pod
spec:
  containers:
  - name: mysql-container
    image: masktv/masktv:mysql  # Replace with your actual Docker image
    env:
    - name: MYSQL_DATABASE
      value: "mydatabase"  # Replace with your desired database name
    - name: MYSQL_USER
      value: "myuser"      # Replace with your desired user
    - name: MYSQL_PASSWORD
      value: "mypassword" # Replace with your desired password
    - name: MYSQL_ROOT_PASSWORD
      value: "myrootpassword" # Replace with your desired root password
    ports:
      - containerPort: 3306
  restartPolicy: Always
