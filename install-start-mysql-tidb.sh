#!/bin/sh

# mysql57 install and run
yum -y install mysql57-community-release-el7-10.noarch.rpm
yum -y install mysql-community-server
systemctl start mysqld.service
systemctl enable mysqld.service

echo 'MySQL temporary password:'
grep "A temporary password" /var/log/mysqld.log

# tidb install and run
curl --proto '=https' --tlsv1.2 -sSf https://tiup-mirrors.pingcap.com/install.sh | sh
source .bash_profile
tiup playground --tiflash 1 > 'tidb.log' 2>&1 &
