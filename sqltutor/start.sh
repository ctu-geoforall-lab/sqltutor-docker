#!/bin/bash -e

export PGPASSWORD=$POSTGRES_PASSWORD

# wait for DB
until psql -h db -U postgres -l > /dev/null 2>&1; do
    echo Waiting for database ...
    sleep 5
done

# install sqltutor
./sqltutor-installer.sh

# run Apache
rm -f /usr/local/apache2/logs/httpd.pid
exec httpd -DFOREGROUND
