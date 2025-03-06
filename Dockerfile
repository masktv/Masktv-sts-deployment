
FROM mysql:8.0

# Expose MySQL port
EXPOSE 3306

# Arguments for MySQL
ARG MYSQL_DATABASE
ARG MYSQL_USER
ARG MYSQL_PASSWORD
ARG MYSQL_ROOT_PASSWORD
ARG MYSQL_REPLICATION_MODE
ARG MYSQL_MASTER_HOST

# Set environment variables from arguments
ENV MYSQL_DATABASE=${MYSQL_DATABASE}
ENV MYSQL_USER=${MYSQL_USER}
ENV MYSQL_PASSWORD=${MYSQL_PASSWORD}
ENV MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
ENV MYSQL_REPLICATION_MODE=${MYSQL_REPLICATION_MODE}
ENV MYSQL_MASTER_HOST=${MYSQL_MASTER_HOST}

# Copy the initialization script
COPY ./init.sh /docker-entrypoint-initdb.d/

# Ensure the init script is executable
RUN chmod +x /docker-entrypoint-initdb.d/init.sh

# Use the default entrypoint for MySQL
ENTRYPOINT ["docker-entrypoint.sh"]

# Command to start MySQL server
CMD ["mysqld"]
