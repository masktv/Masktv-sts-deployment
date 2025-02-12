
FROM mysql:latest

# Expose the MySQL port
EXPOSE 3306

# Argument to hold env value from docker build command
ARG MYSQL_DATABASE
ARG MYSQL_USER
ARG MYSQL_PASSWORD
ARG MYSQL_ROOT_PASSWORD

# Set environment variables from the arguments
ENV MYSQL_DATABASE=${MYSQL_DATABASE}
ENV MYSQL_USER=${MYSQL_USER}
ENV MYSQL_PASSWORD=${MYSQL_PASSWORD}
ENV MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}

# Copy init.sql script file to the initdb directory
COPY ./init.sql /docker-entrypoint-initdb.d/

# Use the default entrypoint for MySQL
ENTRYPOINT ["docker-entrypoint.sh"]

# Specify CMD to start MySQL server
CMD ["mysqld"]
