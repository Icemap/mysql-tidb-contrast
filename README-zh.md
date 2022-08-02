# 对比 MySQL 与 TiDB 性能

中文 | [English](/README.md)

## 测试背景与依赖

本仓库为对比 MySQL 与 TiDB 性能而作，**请勿**在正式环境使用本仓库内的脚本。将安装服务后，添加测试数据，使用相同 SQL 对比性能。

测试参数：

- 测试服务器虚拟化平台：KVM
- 测试服务器系统：`CentOS Linux release 7.6.1810 (Core)`
- 测试服务器配置：8C 16G HDD
- [测试数据 Schema](/gharchive_dev.github_events-schema.sql)
- [测试数据地址](https://github.com/pingcap/ossinsight/releases/download/sample/sample5m.sql.zip)
- MySQL 版本：`5.7.38`
- TiDB 版本：`5.7.25-TiDB-v6.1.0`
- 数据量：单表 `3883887` 条
- 数据来源：`github_events`
- 部署方案：MySQL 与 TiDB 部署同一服务器，MySQL 使用 yum 安装，TiDB 使用 TiUP 安装。
- 客户端：服务器中安装 mysql-client，版本：`mysql  Ver 14.14 Distrib 5.7.38, for Linux (x86_64) using  EditLine wrapper`

## 测试环境准备

### 1. MySQL 与 TiDB 的安装

可使用 [install-start-mysql-tidb.sh](/install-start-mysql-tidb.sh) 安装并启动 MySQL 与 TiDB。MySQL 使用 RPM [添加源](/mysql57-community-release-el7-10.noarch.rpm)后，YUM 安装，systemctl 管理服务。TiDB 使用 TiUP 安装和管理服务。

```sh
./install-start-mysql-tidb.sh
```

### 2. MySQL 与 TiDB 的启动/停止脚本

[install-start-mysql-tidb.sh](/install-start-mysql-tidb.sh) 脚本将直接启动 MySQL 与 TiDB，无需重复调用启动服务脚本。

若需停止服务，可调用 [stop-mysql-and-tidb.sh](/stop-mysql-and-tidb.sh) 脚本：

```sh
./stop-mysql-and-tidb.sh
```

若需启动服务，可调用 [start-mysql-and-tidb.sh](/start-mysql-and-tidb.sh) 脚本：

```sh
./start-mysql-and-tidb.sh
```

### 3. 数据模式创建与数据导入

可调用 [prepare-data.sh](/prepare-data.sh) 脚本完成数据导入：

```sh
./prepare-data.sh {MySQL 密码}
```

此脚本将完成：

1. 创建 MySQL 与 TiDB 的数据模式（数据表）。
2. 下载 SQL 文件压缩包（已有下载文件时，不会重复下载）。
3. 解压 SQL 文件压缩包。
4. 导入 SQL 文件内的数据到 MySQL 与 TiDB。

## 测试 SQL

### 统计数据总条数

- MySQL: 
    
    ```sql
    SELECT COUNT(*) FROM `gharchive_dev`.`github_events`;
    +----------+
    | count(*) |
    +----------+
    |  3883887 |
    +----------+
    1 row in set (5.25 sec)
    ```

- TiDB:

    ```sql
    SELECT COUNT(*) FROM `gharchive_dev`.`github_events`;
    +----------+
    | count(*) |
    +----------+
    |  3883887 |
    +----------+
    1 row in set (0.17 sec)
    ```

### 分别统计每年的事件量

- MySQL: 
    
    ```sql
    SELECT `event_year`, COUNT(*) FROM gharchive_dev.github_events GROUP BY `event_year` ORDER BY `event_year`;
    +------------+----------+
    | event_year | COUNT(*) |
    +------------+----------+
    |       2011 |     5510 |
    |       2012 |    16712 |
    |       2013 |    52088 |
    |       2014 |   111136 |
    |       2015 |   199104 |
    |       2016 |   308213 |
    |       2017 |   342861 |
    |       2018 |   402244 |
    |       2019 |   561159 |
    |       2020 |   676108 |
    |       2021 |   770369 |
    |       2022 |   438383 |
    +------------+----------+
    12 rows in set (4.29 sec)
    ```

- TiDB:

    ```sql
    SELECT `event_year`, COUNT(*) FROM gharchive_dev.github_events GROUP BY `event_year` ORDER BY `event_year`;
    +------------+----------+
    | event_year | COUNT(*) |
    +------------+----------+
    |       2011 |     5510 |
    |       2012 |    16712 |
    |       2013 |    52088 |
    |       2014 |   111136 |
    |       2015 |   199104 |
    |       2016 |   308213 |
    |       2017 |   342861 |
    |       2018 |   402244 |
    |       2019 |   561159 |
    |       2020 |   676108 |
    |       2021 |   770369 |
    |       2022 |   438383 |
    +------------+----------+
    12 rows in set (0.15 sec)
    ```

### 事件最多的 5 个仓库

可复制的多行SQL：

```sql
SELECT
`repo_id`,
    MIN(`repo_name`),
    COUNT(*) as `repo_event_num` 
FROM
    `gharchive_dev`.`github_events` 
GROUP BY `repo_id`
ORDER BY `repo_event_num` DESC
LIMIT 5;
```

- MySQL: 
    
    ```sql
    SELECT
        -> `repo_id`,
        -> MIN(`repo_name`),
        -> COUNT(*) as `repo_event_num` 
        -> FROM
        -> `gharchive_dev`.`github_events` 
        -> GROUP BY `repo_id`
        -> ORDER BY `repo_event_num` DESC
        -> LIMIT 5;
    +----------+-----------------------+----------------+
    | repo_id  | MIN(`repo_name`)      | repo_event_num |
    +----------+-----------------------+----------------+
    | 16563587 | cockroach             |         492926 |
    |   507775 | elastic/              |         480849 |
    | 41986369 | pingcap/              |         285752 |
    | 60246359 | ClickHouse/ClickHouse |         141792 |
    |  6838921 | prometheus            |         105459 |
    +----------+-----------------------+----------------+
    5 rows in set (22.38 sec)
    ```

- TiDB:

    ```sql
    SELECT
        -> `repo_id`,
        ->     MIN(`repo_name`),
        ->     COUNT(*) as `repo_event_num` 
        -> FROM
        ->     `gharchive_dev`.`github_events` 
        -> GROUP BY `repo_id`
        -> ORDER BY `repo_event_num` DESC
        -> LIMIT 5;
    +----------+-----------------------+----------------+
    | repo_id  | MIN(`repo_name`)      | repo_event_num |
    +----------+-----------------------+----------------+
    | 16563587 | cockroach             |         492926 |
    |   507775 | elastic/              |         480849 |
    | 41986369 | pingcap/              |         285752 |
    | 60246359 | ClickHouse/ClickHouse |         141792 |
    |  6838921 | prometheus            |         105459 |
    +----------+-----------------------+----------------+
    5 rows in set (0.43 sec)
    ```

### 各类型事件的数量

- MySQL: 
        
    ```sql
    SELECT `action`, COUNT(*) AS `action_num` FROM gharchive_dev.github_events GROUP BY `action` ORDER BY `action_num` DESC;
    +-------------+------------+
    | action      | action_num |
    +-------------+------------+
    | created     |    1717209 |
    | started     |    1051344 |
    | opened      |     512258 |
    | closed      |     505183 |
    | NULL        |      78137 |
    | reopened    |       9981 |
    | synchronize |       9775 |
    +-------------+------------+
    7 rows in set (6.29 sec)
    ```

- TiDB:

    ```sql
    SELECT `action`, COUNT(*) AS `action_num` FROM gharchive_dev.github_events GROUP BY `action` ORDER BY `action_num` DESC;
    +-------------+------------+
    | action      | action_num |
    +-------------+------------+
    | created     |    1717209 |
    | started     |    1051344 |
    | opened      |     512258 |
    | closed      |     505183 |
    | NULL        |      78137 |
    | reopened    |       9981 |
    | synchronize |       9775 |
    +-------------+------------+
    7 rows in set (0.19 sec)
    ```

### 所有事件的 Comments 加起来有多少

- MySQL: 
    
    ```sql
    SELECT SUM(`comments`) FROM gharchive_dev.github_events;
    +-----------------+
    | SUM(`comments`) |
    +-----------------+
    |        11038804 |
    +-----------------+
    1 row in set (2.94 sec)
    ```

- TiDB:

    ```sql
    SELECT SUM(`comments`) FROM gharchive_dev.github_events;
    +-----------------+
    | SUM(`comments`) |
    +-----------------+
    |        11038804 |
    +-----------------+
    1 row in set (0.16 sec)
    ```

### 主键查询

- MySQL: 
    
    ```sql
    SELECT * FROM gharchive_dev.github_events WHERE id=11223035207;
    +-------------+-------------------+---------------------+---------+----------------+----------+-------------+----------------+----------+-----------+-----------+---------+--------+-----------+------------+-----------+--------+-------+-----------+----------+--------------+-----------+------------------+--------------------+----------------+------------+-------------+--------------------+------------+-----------+--------------------+
    | id          | type              | created_at          | repo_id | repo_name      | actor_id | actor_login | actor_location | language | additions | deletions | action  | number | commit_id | comment_id | org_login | org_id | state | closed_at | comments | pr_merged_at | pr_merged | pr_changed_files | pr_review_comments | pr_or_issue_id | event_day  | event_month | author_association | event_year | push_size | push_distinct_size |
    +-------------+-------------------+---------------------+---------+----------------+----------+-------------+----------------+----------+-----------+-----------+---------+--------+-----------+------------+-----------+--------+-------+-----------+----------+--------------+-----------+------------------+--------------------+----------------+------------+-------------+--------------------+------------+-----------+--------------------+
    | 11223035207 | IssueCommentEvent | 2020-01-07 21:38:04 | 8162715 | mirumee/saleor |  3480808 | mouchh      | NULL           | NULL     |      NULL |      NULL | created |   5137 | NULL      |  571784805 | mirumee   | 170574 | open  | NULL      |        3 | NULL         |      NULL |             NULL |               NULL |      545666763 | 2020-01-07 | 2020-01-01  | NONE               |       2020 |      NULL |               NULL |
    +-------------+-------------------+---------------------+---------+----------------+----------+-------------+----------------+----------+-----------+-----------+---------+--------+-----------+------------+-----------+--------+-------+-----------+----------+--------------+-----------+------------------+--------------------+----------------+------------+-------------+--------------------+------------+-----------+--------------------+
    1 row in set (0.02 sec)
    ```

- TiDB:

    ```sql
    SELECT * FROM gharchive_dev.github_events WHERE id=11223035207;
    +-------------+-------------------+---------------------+---------+----------------+----------+-------------+----------------+----------+-----------+-----------+---------+--------+-----------+------------+-----------+--------+-------+-----------+----------+--------------+-----------+------------------+--------------------+----------------+------------+-------------+--------------------+------------+-----------+--------------------+
    | id          | type              | created_at          | repo_id | repo_name      | actor_id | actor_login | actor_location | language | additions | deletions | action  | number | commit_id | comment_id | org_login | org_id | state | closed_at | comments | pr_merged_at | pr_merged | pr_changed_files | pr_review_comments | pr_or_issue_id | event_day  | event_month | author_association | event_year | push_size | push_distinct_size |
    +-------------+-------------------+---------------------+---------+----------------+----------+-------------+----------------+----------+-----------+-----------+---------+--------+-----------+------------+-----------+--------+-------+-----------+----------+--------------+-----------+------------------+--------------------+----------------+------------+-------------+--------------------+------------+-----------+--------------------+
    | 11223035207 | IssueCommentEvent | 2020-01-07 21:38:04 | 8162715 | mirumee/saleor |  3480808 | mouchh      | NULL           | NULL     |      NULL |      NULL | created |   5137 | NULL      |  571784805 | mirumee   | 170574 | open  | NULL      |        3 | NULL         |      NULL |             NULL |               NULL |      545666763 | 2020-01-07 | 2020-01-01  | NONE               |       2020 |      NULL |               NULL |
    +-------------+-------------------+---------------------+---------+----------------+----------+-------------+----------------+----------+-----------+-----------+---------+--------+-----------+------------+-----------+--------+-------+-----------+----------+--------------+-----------+------------------+--------------------+----------------+------------+-------------+--------------------+------------+-----------+--------------------+
    1 row in set (0.02 sec)
    ```

## 测试脚本

也可以直接使用脚本 [query-mysql-and-tidb.sh](/query-mysql-and-tidb.sh) 进行两个数据库的 SQL 测试：

```sh
./query-mysql-and-tidb.sh {MySQL 密码}
```

这个脚本将会分别在 MySQL 和 TiDB 上运行 [query.sql](/query.sql) 文件，随后比较运行时间。测试结果如下：

```sh
-------------- Result --------------
MySQL used 39 seconds
TiDB used 1 seconds
```