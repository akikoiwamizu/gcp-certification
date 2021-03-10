SELECT *
FROM `demos.average_speeds`
ORDER BY timestamp DESC
LIMIT 100;

SELECT
MAX(timestamp)
FROM
`demos.average_speeds`;

SELECT *
FROM `demos.average_speeds`
FOR SYSTEM_TIME AS OF TIMESTAMP_SUB(CURRENT_TIMESTAMP, INTERVAL 10 MINUTE)
ORDER BY timestamp DESC
LIMIT 100;