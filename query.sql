-- get count
SELECT COUNT(*) FROM `gharchive_dev`.`github_events`;

-- group by year
SELECT `event_year`, COUNT(*) FROM `gharchive_dev`.`github_events` GROUP BY `event_year`;

-- the top 5 event number repos
SELECT
`repo_id`,
    MIN(`repo_name`),
    COUNT(*) as `repo_event_num` 
FROM
    `gharchive_dev`.`github_events` 
GROUP BY `repo_id`
ORDER BY `repo_event_num` DESC
LIMIT 5;

-- count each action number
SELECT `action`, COUNT(*) AS `action_num` FROM gharchive_dev.github_events GROUP BY `action` ORDER BY `action_num` DESC;

-- sum all comments
SELECT SUM(`comments`) FROM gharchive_dev.github_events;

-- query by PK
SELECT * FROM gharchive_dev.github_events WHERE id=11223035207;