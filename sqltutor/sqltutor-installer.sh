#!/bin/bash -e

### Inspired by https://git.savannah.gnu.org/cgit/sqltutor.git/tree/sqltutor-installer.sh

# installer variables
GIT_SQLTUTOR=./sqltutor
GIT_DATASETS=./datasets
BINDIR=/usr/local/apache2/cgi-bin/
INFODIR=/usr/share/info
SED_INPUT=/tmp/$$-sqltutor-installer-sed-input
PSQL="psql -h db -U postgres -v ON_ERROR_STOP=1 -tA"

# credentials end up in sed expressions, configure, Makefiles, SQL and
# C++ sources, so only allow characters that are safe everywhere
function check_credentials() {
    local name
    for name in SQLTUTOR_DATABASE SQLTUTOR_WWW_USER SQLTUTOR_WWW_EXEC; do
        if [[ ! ${!name} =~ ^[a-z_][a-z0-9_]*$ ]]; then
            echo "ERROR: $name must match [a-z_][a-z0-9_]*" >&2
            exit 1
        fi
    done
    for name in SQLTUTOR_PASSWORD SQLTUTOR_PASSEXEC; do
        if [[ ! ${!name} =~ ^[A-Za-z0-9_.-]+$ ]]; then
            echo "ERROR: $name must match [A-Za-z0-9_.-]+" >&2
            exit 1
        fi
    done
}

function preconfigure() {
    echo
    echo Setting up configure files ...
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
    $PSQL -c "DO \$\$ BEGIN
                IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '$user') THEN
                  CREATE ROLE $user LOGIN;
                END IF;
              END \$\$;"
    $PSQL -c "ALTER ROLE $user WITH PASSWORD '$pass';"
}

if [[ -x $BINDIR/sqltutor ]]; then
    echo SQLtutor already installed in $BINDIR, skipping installation
    exit 0
fi

check_credentials

if [[ -z $($PSQL -c "SELECT 1 FROM pg_database WHERE datname = '$SQLTUTOR_DATABASE'") ]]; then
    createdb -h db -U postgres "$SQLTUTOR_DATABASE"
fi
# installing the database part drops and recreates the sqltutor schemas,
# so only do it when the schema does not exist yet
if [[ -z $($PSQL -d "$SQLTUTOR_DATABASE" -c "SELECT 1 FROM pg_namespace WHERE nspname = 'sqltutor'") ]]; then
    INSTALL_DB=1
fi
echo
create_user "$SQLTUTOR_WWW_USER" "$SQLTUTOR_PASSWORD"
create_user "$SQLTUTOR_WWW_EXEC" "$SQLTUTOR_PASSEXEC"

preconfigure

echo
echo Running $GIT_SQLTUTOR/configure --bindir=$BINDIR --infodir=$INFODIR
( cd $GIT_SQLTUTOR && ./configure --bindir=$BINDIR --infodir=$INFODIR )

echo
if [[ -n $INSTALL_DB ]]; then
    echo Running $GIT_DATASETS/configure --bindir=$BINDIR --infodir=$INFODIR
    ( cd $GIT_DATASETS && ./configure --bindir=$BINDIR --infodir=$INFODIR )
    echo
    ( cd $GIT_SQLTUTOR && make clean install )
    ( cd $GIT_DATASETS && make clean install )
else
    echo Database $SQLTUTOR_DATABASE already initialized, installing CGI only
    ( cd $GIT_SQLTUTOR/cgi.cpp && make clean install )
fi

exit 0
