#!/bin/bash

set -e

# initialize database if not already initialized
if [ ! -d /var/lib/mysql/mysql ]; then
  INITIAL_ROOT_PASSWORD="${INITIAL_ROOT_PASSWORD:-9A4A8178-02C7-455E-B38E-06A5669C8EC4}"
  /usr/libexec/mariadb-prepare-db-dir
  /usr/bin/mysqld_safe --basedir=/usr &
  MYSQL_PID=$!
  /usr/libexec/mariadb-wait-ready $MYSQL_PID
  mysqladmin -u root password "$INITIAL_ROOT_PASSWORD"
  mysql -u root -p"$INITIAL_ROOT_PASSWORD" <<< "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${INITIAL_ROOT_PASSWORD}';"
  kill $(pgrep -P $MYSQL_PID)
  while pgrep -P $MYSQL_PID;do sleep 1;done
fi


rm -f /var/log/mariadb/mariadb.log
mkfifo /var/log/mariadb/mariadb.log
chown mysql: /var/log/mariadb/mariadb.log
/usr/bin/mysqld_safe --basedir=/usr &
MYSQL_PID=$!

trap "kill -SIGQUIT $MYSQL_PID" INT
tail -f /var/log/mariadb/mariadb.log
