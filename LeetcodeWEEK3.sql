-- 262번 (Hard) - Trips and Users
-- 문제: 2013-10-01부터 2013-10-03까지 밴 안된 유저들의 일별 취소율 계산
SELECT 
    request_at AS Day,
    ROUND(
        SUM(CASE WHEN status LIKE 'cancelled%' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS 'Cancellation Rate'
FROM Trips t
JOIN Users u1 ON t.client_id = u1.users_id AND u1.banned = 'No'     -- 밴 안된 고객만
JOIN Users u2 ON t.driver_id = u2.users_id AND u2.banned = 'No'     -- 밴 안된 드라이버만
WHERE request_at BETWEEN '2013-10-01' AND '2013-10-03'              -- 날짜 범위
GROUP BY request_at;


-- 550번 - Game Play Analysis IV
-- 문제: 첫 로그인 다음날 다시 로그인한 플레이어의 비율 계산
SELECT 
    ROUND(
        COUNT(DISTINCT a2.player_id) / COUNT(DISTINCT a1.player_id),
        2
    ) AS fraction
FROM (
    SELECT player_id, MIN(event_date) AS first_login    -- 각 플레이어의 첫 로그인 날짜
    FROM Activity
    GROUP BY player_id
) a1
LEFT JOIN Activity a2 
    ON a1.player_id = a2.player_id 
    AND a2.event_date = DATE_ADD(a1.first_login, INTERVAL 1 DAY);    -- 다음날 로그인했는지 확인


-- 570번 - Managers with at Least 5 Direct Reports
-- 문제: 최소 5명 이상의 직속 부하 직원을 가진 관리자 찾기
SELECT e1.name
FROM Employee e1
JOIN Employee e2 ON e1.id = e2.managerId    -- Self JOIN으로 관리자-직원 연결
GROUP BY e1.id, e1.name                     -- 관리자별로 그룹화
HAVING COUNT(e2.id) >= 5;                   -- 직원이 5명 이상인 관리자만


-- 585번 - Investments in 2016
-- 문제: tiv_2015는 다른 사람과 같지만, 위치(lat, lon)는 고유한 사람들의 tiv_2016 합계
SELECT ROUND(SUM(tiv_2016), 2) AS tiv_2016
FROM Insurance
WHERE tiv_2015 IN (                                      -- tiv_2015가 다른 사람과 같고
    SELECT tiv_2015
    FROM Insurance
    GROUP BY tiv_2015
    HAVING COUNT(*) > 1
)
AND (lat, lon) IN (                                      -- 위치는 고유해야 함
    SELECT lat, lon
    FROM Insurance
    GROUP BY lat, lon
    HAVING COUNT(*) = 1
);


-- 601번 (Hard) - Human Traffic of Stadium
-- 문제: people >= 100인 날이 3일 이상 연속으로 나타나는 모든 행 찾기
WITH Consecutive_People AS (
    SELECT
        *,
        -- 이전 1일의 people 수
        LAG(people, 1) OVER (ORDER BY id) AS prev_1_people,
        -- 이전 2일의 people 수
        LAG(people, 2) OVER (ORDER BY id) AS prev_2_people,
        -- 다음 1일의 people 수
        LEAD(people, 1) OVER (ORDER BY id) AS next_1_people,
        -- 다음 2일의 people 수
        LEAD(people, 2) OVER (ORDER BY id) AS next_2_people
    FROM Stadium
)
SELECT id, visit_date, people
FROM Consecutive_People
WHERE people >= 100 AND (
    (prev_1_people >= 100 AND prev_2_people >= 100) OR -- 2일 전, 1일 전, 현재
    (prev_1_people >= 100 AND next_1_people >= 100) OR -- 1일 전, 현재, 1일 후
    (next_1_people >= 100 AND next_2_people >= 100)    -- 현재, 1일 후, 2일 후
)
ORDER BY visit_date;

-- 602번 - Friend Requests II: Who Has the Most Friends
-- 문제: 가장 많은 친구를 가진 사람 찾기 (양방향 관계)
SELECT id, SUM(cnt) AS num
FROM (
    SELECT requester_id AS id, COUNT(*) AS cnt    -- 요청 보낸 사람
    FROM RequestAccepted
    GROUP BY requester_id
    
    UNION ALL                                      -- 합치기
    
    SELECT accepter_id AS id, COUNT(*) AS cnt     -- 요청 받은 사람
    FROM RequestAccepted
    GROUP BY accepter_id
) AS friends
GROUP BY id
ORDER BY num DESC
LIMIT 1; 
