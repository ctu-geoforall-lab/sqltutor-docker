#!/bin/bash -e

### Inspired by https://git.savannah.gnu.org/cgit/sqltutor.git/tree/sqltutor-installer.sh

# installer variables
GIT_SQLTUTOR=./sqltutor
GIT_DATASETS=./datasets
EXTRA_DATASETS=./extra_datasets
BINDIR=/usr/local/apache2/cgi-bin/
INFODIR=/usr/share/info
SED_INPUT=/tmp/$$-sqltutor-installer-sed-input

function preconfigure() {
    echo
    echo Setting up configure files ...
    (cd $GIT_SQLTUTOR && rm -f configure && ./autogen.sh)
    (cd $GIT_DATASETS && rm -f configure && ./autogen.sh)
cat > $SED_INPUT <<EOF
s/^SQLTUTOR_DATABASE=.*/SQLTUTOR_DATABASE=$SQLTUTOR_DATABASE/
s/^SQLTUTOR_WWW_USER=.*/SQLTUTOR_WWW_USER=$SQLTUTOR_WWW_USER/
s/^SQLTUTOR_PASSWORD=.*/SQLTUTOR_PASSWORD=$SQLTUTOR_PASSWORD/
s/^SQLTUTOR_WWW_EXEC=.*/SQLTUTOR_WWW_EXEC=$SQLTUTOR_WWW_EXEC/
s/^SQLTUTOR_PASSEXEC=.*/SQLTUTOR_PASSEXEC=$SQLTUTOR_PASSEXEC/
EOF
    sed -i -f $SED_INPUT $GIT_SQLTUTOR/configure $GIT_DATASETS/configure
    rm -f $SED_INPUT
}

function create_user() {
    local user=$1
    local pass=$2
    echo Creating sqltutor user $user ...
    psql -h db -U postgres -c "CREATE ROLE $user LOGIN;"
    psql -h db -U postgres -c "ALTER USER $user WITH PASSWORD '$pass';"
}

DB_EXISTS=$(
    psql -h db -U postgres -tAc "SELECT 1 FROM pg_database WHERE datname='${SQLTUTOR_DATABASE}'"
)

if [[ "$DB_EXISTS" != "1" ]]; then
    createdb -h db -U postgres $SQLTUTOR_DATABASE
    echo
    (cd /tmp && create_user $SQLTUTOR_WWW_USER $SQLTUTOR_PASSWORD )
    (cd /tmp && create_user $SQLTUTOR_WWW_EXEC $SQLTUTOR_PASSEXEC )
fi

preconfigure

echo
echo Running $GIT_SQLTUTOR/configure --bindir=$BINDIR --infodir=$INFODIR
( cd $GIT_SQLTUTOR && ./configure --bindir=$BINDIR --infodir=$INFODIR )
echo

echo
( cd $GIT_SQLTUTOR && make clean install )
if [[ "$DB_EXISTS" != "1" ]]; then
    ( cd $GIT_SQLTUTOR/database && make clean install )

    echo Running $GIT_DATASETS/configure --bindir=$BINDIR --infodir=$INFODIR
    ( cd $GIT_DATASETS && ./configure --bindir=$BINDIR --infodir=$INFODIR)
    ( cd $GIT_DATASETS && make clean install )

    ### Additional datasets
    if test -d $EXTRA_DATASETS; then
        $EXTRA_DATASETS/install.sh
    fi
fi

exit 0
