-- пользователи пришедшие из какого источника совершили наибольшее число покупок

SELECT Source, COUNT(*)
FROM checks
LEFT JOIN 
(
    SELECT Source, DeviceID, UserID
    FROM installs
    JOIN devices USING(DeviceID)
    
) AS hui USING(UserID)

GROUP BY Source
ORDER BY COUNT(*) DESC
LIMIT 5

-- cамое время посмотреть на общую выручку, а также минимальный, максимальный и средний чек (по ресурсам)

SELECT Source, MAX(Rub), MIN(Rub), AVG(Rub), SUM(Rub)
FROM checks
LEFT JOIN (
    SELECT Source, UserID
    FROM installs
    JOIN devices USING(DeviceID)
    -- LIMIT 10
) AS hui USING(UserID)
GROUP BY Source
ORDER BY Source

-- id пользователей кто купил в октябре 2019
 
SELECT DeviceID
FROM checks
JOIN (
    
    SELECT DeviceID, UserID
    FROM installs
    JOIN devices USING(DeviceID)

) AS hu USING(UserID)
WHERE  toStartOfMonth(CAST(BuyDate as date)) = '2019-10-01'
ORDER BY DeviceID

-- в выборе жилья нас интересует только два параметра: наличие кухни (kitchen) и гибкой системы отмены (flexible), причем первый в приоритете
SELECT host_id,
        CASE
            WHEN 
                multiSearchAnyCaseInsensitive(amenities, ['kitchen']) = 1 
                AND
                cancellation_policy = 'flexible'
            THEN 'good'
            
            WHEN 
                multiSearchAnyCaseInsensitive(amenities, ['kitchen']) = 1 
            THEN 'ok'
            
            ELSE 'not ok'
        END AS filter_1
FROM listings
ORDER BY filter_1
LIMIT 5