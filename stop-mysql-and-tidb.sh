#!/bin/sh

systemctl stop mysqld.service
kill `cat tidb.pid`

rm -f tidb.pid