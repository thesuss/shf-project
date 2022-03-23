if [ "$(ls -A /var/postgres/data)" ]
then
     echo "Database already exists. No action taken."
else
    /usr/lib/postgresql/11/bin/initdb /var/postgres/data
    /usr/lib/postgresql/11/bin/pg_ctl -D /var/postgres/data start
    psql --username postgres --dbname postgres -c "CREATE USER root CREATEDB;"
    /usr/lib/postgresql/11/bin/pg_ctl -D /var/postgres/data stop    
    echo "Database created."
fi
