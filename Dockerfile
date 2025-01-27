
FROM mysql:latest

# Expose the MySQL port
EXPOSE 3306

# Argument to hold env value from docker build cammand
ARG MYSQL_DATABASE
ARG MYSQL_USER
ARG MYSQL_PASSWORD
ARG MYSQL_ROOT_PASSWORD

# env value from argument
ENV MYSQL_DATABASE=${MYSQL_DATABASE}
ENV MYSQL_USER=${MYSQL_USER}
ENV MYSQL_PASSWORD=${MYSQL_PASSWORD}
ENV MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}

# Copy init.sql script file to allow dbuser on database to connect from any host.
COPY ./init.sql /docker-entrypoint-initdb.d/

# Use ENTRYPOINT to set the entrypoint script
ENTRYPOINT ["docker-entrypoint.sh"]

# Specify CMD to start MySQL server
CMD ["mysqld"]
