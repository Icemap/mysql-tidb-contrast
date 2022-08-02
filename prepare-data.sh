#!/bin/sh

MYSQL_PASSWORD=$1

echo "Schema Init"

# Schema Init - MySQL
mysql -u root -P 3306 -h 127.0.0.1 --password=${MYSQL_PASSWORD} < gharchive_dev.github_events-schema.sql

# Schema Init - TiDB
mysql -u root -P 4000 -h 127.0.0.1 < gharchive_dev.github_events-schema.sql
mysql -u root -P 4000 -h 127.0.0.1 -e 'ALTER TABLE `gharchive_dev`.`github_events` SET TIFLASH REPLICA 1;'

echo "Download data and unzip"

# Download data and unzip
wget -P data --no-clobber https://github.com/pingcap/ossinsight/releases/download/sample/sample5m.sql.zip;
unzip -o data/sample5m.sql.zip -d data

# Import - MySQL (About 20 minutes)
echo "MySQL import start"
mysql -u root -P 3306 -h 127.0.0.1 --password=${MYSQL_PASSWORD} --database="gharchive_dev" < data/sample5m.sql
echo "MySQL import done"

# Import - TiDB (About 20 minutes)
echo "TiDB import start"
mysql -u root -P 4000 -h 127.0.0.1 --database="gharchive_dev" < data/sample5m.sql
echo "TiDB import done"