#!/bin/sh
set -v

# Create the 'pacsdb' and 'arrdb' databases, and 'pacs' and 'arr' DB users.
if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
    mysql -hmysql -uroot < $DCM4CHEE_HOME/create_dcm4chee_databases.sql
else
    mysql -hmysql -uroot --password="$MYSQL_ROOT_PASSWORD" < $DCM4CHEE_HOME/create_dcm4chee_databases.sql
fi

# Load the 'pacsdb' database schema
mysql -hmysql -upacs -ppacs pacsdb < $DCM_DIR/sql/create.mysql

# Load the 'arrdb' database schema
mysql -hmysql -uarr -parr arrdb < $ARR_DIR/sql/dcm4chee-arr-mysql.ddl
