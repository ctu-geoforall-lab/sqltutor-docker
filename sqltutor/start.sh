#!/bin/bash -e

export PGPASSWORD=$POSTGRES_PASSWORD

while true; do
    sleep 5
    psql -h db -U postgres -l
    if [[ $? -eq 0 ]] ; then
        break;
    fi
done

# install sqltutor
./sqltutor-installer.sh

# run Apache
rm -f /usr/local/apache2/logs/httpd.pid
exec httpd -DFOREGROUND -c "LoadModule cgid_module modules/mod_cgid.so"

exit 0
