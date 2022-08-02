#!/bin/sh

# mysql57 install and run
systemctl restart mysqld.service

echo 'MySQL temporary password:'
grep "A temporary password" /var/log/mysqld.log

# tidb install and run
tiup playground --tiflash 1 > 'tidb.log' 2>&1 &
TIDB_PID=$!
sleep 5
echo "tiup playground (PID: ${TIDB_PID}) started"
echo ${TIDB_PID} > tidb.pid