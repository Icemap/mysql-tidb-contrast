#!/bin/sh

MYSQL_PASSWORD=$1

mysql_start=$(date +%s)
mysql -u root -h 127.0.0.1 -P 3306 -E --password=${MYSQL_PASSWORD} < query.sql
mysql_end=$(date +%s)
mysql_take=$(( mysql_end - mysql_start ))

tidb_start=$(date +%s)
mysql -u root -h 127.0.0.1 -P 4000 -E < query.sql
tidb_end=$(date +%s)
tidb_take=$(( tidb_end - tidb_start ))

echo "-------------- Result --------------"
echo "MySQL used ${mysql_take} seconds"
echo "TiDB used ${tidb_take} seconds"