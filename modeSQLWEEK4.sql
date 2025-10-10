-- Lesson 9 : SQL Data Types

-- 1. 주요 데이터 타입 이해하기
-- VARCHAR(n): 가변 길이 문자열 (최대 n자)
-- TEXT: 무제한 길이 문자열
-- INTEGER/INT: 정수
-- NUMERIC/DECIMAL: 고정 소수점 숫자
-- FLOAT/DOUBLE: 부동 소수점 숫자
-- DATE: 날짜 (YYYY-MM-DD)
-- TIMESTAMP: 날짜 + 시간
-- BOOLEAN: TRUE/FALSE

-- 2. CAST를 이용한 데이터 타입 변환
SELECT CAST(funding_total_usd AS varchar) AS funding_string
FROM tutorial.crunchbase_companies_clean_date;
-- 숫자를 문자열로 변환

SELECT CAST(founded_at AS varchar) AS founded_string
FROM tutorial.crunchbase_companies_clean_date;
-- 날짜를 문자열로 변환

-- 3. :: 연산자를 이용한 타입 변환 (PostgreSQL)
SELECT funding_total_usd::varchar AS funding_string
FROM tutorial.crunchbase_companies_clean_date;
-- CAST 대신 :: 사용 (더 간결한 문법)

SELECT founded_at::varchar AS founded_string
FROM tutorial.crunchbase_companies_clean_date;

-- 4. 문자열을 숫자로 변환
SELECT CAST('100' AS integer) AS number_value;
-- 문자열 '100'을 정수 100으로 변환

SELECT '123.45'::numeric AS decimal_value;

-- 5. 날짜 타입 변환
SELECT CAST('2024-10-10' AS date) AS date_value;
SELECT '2024-10-10 14:30:00'::timestamp AS timestamp_value;

-- 데이터 타입 주의사항:
-- 적절한 타입 선택이 성능과 저장공간에 영향
-- 타입 변환 시 데이터 손실 가능성 확인 필요
-- 문자열→숫자 변환 시 형식이 맞지 않으면 에러 발생


-- Lesson 10 : SQL Date Format
-- 1. DATE_TRUNC: 날짜를 특정 단위로 자르기
SELECT DATE_TRUNC('year', occurred_at) AS year,
       COUNT(*) AS count
FROM tutorial.yammer_events
GROUP BY 1;
-- 연도 단위로 자르기 (2024-03-15 → 2024-01-01)

SELECT DATE_TRUNC('month', occurred_at) AS month,
       COUNT(*) AS count
FROM tutorial.yammer_events
GROUP BY 1;
-- 월 단위로 자르기 (2024-03-15 → 2024-03-01)

SELECT DATE_TRUNC('week', occurred_at) AS week,
       COUNT(*) AS count
FROM tutorial.yammer_events
GROUP BY 1;
-- 주 단위로 자르기 (월요일 기준)

SELECT DATE_TRUNC('day', occurred_at) AS day
FROM tutorial.yammer_events;
-- 일 단위 (시간 부분 제거)

-- 2. DATE_PART/EXTRACT: 날짜에서 특정 부분 추출
SELECT DATE_PART('year', occurred_at) AS year,
       COUNT(*) AS count
FROM tutorial.yammer_events
GROUP BY 1;
-- 연도만 숫자로 추출 (2024)

SELECT DATE_PART('month', occurred_at) AS month,
       COUNT(*) AS count
FROM tutorial.yammer_events
GROUP BY 1;
-- 월만 숫자로 추출 (1~12)

SELECT DATE_PART('day', occurred_at) AS day
FROM tutorial.yammer_events;
-- 일만 추출 (1~31)

SELECT DATE_PART('dow', occurred_at) AS day_of_week
FROM tutorial.yammer_events;
-- 요일 추출 (0=일요일, 6=토요일)

-- EXTRACT 사용 (DATE_PART와 동일한 기능)
SELECT EXTRACT(year FROM occurred_at) AS year
FROM tutorial.yammer_events;

-- 3. INTERVAL: 날짜 연산
SELECT occurred_at,
       occurred_at + INTERVAL '1 day' AS next_day,
       occurred_at - INTERVAL '1 week' AS last_week,
       occurred_at + INTERVAL '3 months' AS three_months_later
FROM tutorial.yammer_events;

SELECT occurred_at,
       occurred_at + INTERVAL '2 hours' AS two_hours_later
FROM tutorial.yammer_events;

-- 4. 현재 날짜/시간 함수
SELECT NOW() AS current_timestamp;  -- 현재 날짜와 시간
SELECT CURRENT_DATE AS today;       -- 오늘 날짜
SELECT CURRENT_TIME AS now_time;    -- 현재 시간

-- 5. 날짜 차이 계산
SELECT occurred_at,
       NOW() - occurred_at AS time_since_event
FROM tutorial.yammer_events;

-- DATE_TRUNC vs DATE_PART 차이:
-- DATE_TRUNC: 날짜 타입 반환 (2024-01-01)
-- DATE_PART: 숫자 타입 반환 (2024)


-- Lesson 11 : Writing Subqueries
-- 1. WHERE절의 서브쿼리
SELECT *
FROM tutorial.sf_crime_incidents_2014_01
WHERE Date = (SELECT MIN(Date) 
              FROM tutorial.sf_crime_incidents_2014_01);
-- 가장 이른 날짜의 범죄 기록만 조회

-- 2. IN을 사용한 서브쿼리
SELECT *
FROM tutorial.sf_crime_incidents_2014_01
WHERE Date IN (SELECT Date
               FROM tutorial.sf_crime_incidents_2014_01
               ORDER BY Date
               LIMIT 5);
-- 가장 이른 5개 날짜의 범죄 기록

-- 3. FROM절의 서브쿼리 (인라인 뷰)
SELECT sub.*
FROM (
  SELECT Date,
         COUNT(*) AS incident_count
  FROM tutorial.sf_crime_incidents_2014_01
  GROUP BY Date
) sub
WHERE sub.incident_count > 100;
-- 일일 범죄 건수가 100건 초과인 날짜만 조회

-- 4. JOIN과 서브쿼리 결합
SELECT incidents.*,
       sub.max_count
FROM tutorial.sf_crime_incidents_2014_01 incidents
JOIN (
  SELECT Date,
         MAX(IncidntNum) AS max_count
  FROM tutorial.sf_crime_incidents_2014_01
  GROUP BY Date
) sub
ON incidents.Date = sub.Date;

-- 5. 서브쿼리를 이용한 계산
SELECT *,
       incident_count - avg_count AS difference
FROM (
  SELECT Date,
         COUNT(*) AS incident_count,
         (SELECT AVG(count) 
          FROM (SELECT COUNT(*) AS count 
                FROM tutorial.sf_crime_incidents_2014_01 
                GROUP BY Date) sub2
         ) AS avg_count
  FROM tutorial.sf_crime_incidents_2014_01
  GROUP BY Date
) sub;

-- 6. EXISTS를 사용한 서브쿼리
SELECT *
FROM tutorial.sf_crime_incidents_2014_01 a
WHERE EXISTS (
  SELECT 1
  FROM tutorial.sf_crime_incidents_2014_01 b
  WHERE a.Category = b.Category
    AND a.Date <> b.Date
);
-- 같은 카테고리의 다른 날짜 기록이 있는 경우만 조회

-- 서브쿼리 주의사항:
-- FROM절 서브쿼리는 반드시 별칭(alias) 필요
-- 서브쿼리가 많으면 성능 저하 가능 (CTE 고려)
-- 스칼라 서브쿼리(단일 값)는 WHERE, SELECT에 사용 가능


-- Lesson 12 : Window Functions
-- 1. ROW_NUMBER(): 행 번호 부여
SELECT player_name,
       college,
       ROW_NUMBER() OVER(ORDER BY player_name) AS row_num
FROM benn.college_football_players;
-- 전체 데이터에 순서대로 번호 부여

SELECT player_name,
       college,
       ROW_NUMBER() OVER(PARTITION BY college ORDER BY player_name) AS row_num
FROM benn.college_football_players;
-- 대학별로 그룹화하여 각 그룹 내에서 번호 부여

-- 2. RANK(): 순위 부여 (동점 시 같은 순위, 다음 순위 건너뜀)
SELECT player_name,
       weight,
       RANK() OVER(ORDER BY weight DESC) AS rank
FROM benn.college_football_players;
-- 1, 2, 2, 4, 5... (동점이 2명이면 다음은 4등)

-- 3. DENSE_RANK(): 순위 부여 (동점 시 같은 순위, 다음 순위 이어짐)
SELECT player_name,
       weight,
       DENSE_RANK() OVER(ORDER BY weight DESC) AS dense_rank
FROM benn.college_football_players;
-- 1, 2, 2, 3, 4... (동점이 있어도 다음은 3등)

-- 4. PARTITION BY: 그룹별 윈도우 함수
SELECT player_name,
       college,
       weight,
       RANK() OVER(PARTITION BY college ORDER BY weight DESC) AS college_rank
FROM benn.college_football_players;
-- 각 대학 내에서의 체중 순위

-- 5. 집계 윈도우 함수 (SUM, AVG, COUNT)
SELECT player_name,
       college,
       weight,
       AVG(weight) OVER(PARTITION BY college) AS avg_college_weight
FROM benn.college_football_players;
-- 각 선수가 속한 대학의 평균 체중을 모든 행에 표시

SELECT player_name,
       college,
       weight,
       SUM(weight) OVER(PARTITION BY college) AS total_college_weight
FROM benn.college_football_players;
-- 각 대학의 총 체중

-- 6. ROWS BETWEEN: 윈도우 범위 지정
SELECT player_name,
       weight,
       AVG(weight) OVER(ORDER BY player_name 
                        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg
FROM benn.college_football_players;
-- 현재 행 기준 이전 2개 행까지의 이동 평균

-- 7. LAG/LEAD: 이전/다음 행 값 가져오기
SELECT player_name,
       weight,
       LAG(weight, 1) OVER(ORDER BY player_name) AS prev_weight,
       LEAD(weight, 1) OVER(ORDER BY player_name) AS next_weight
FROM benn.college_football_players;

-- 8. 누적 합계
SELECT player_name,
       weight,
       SUM(weight) OVER(ORDER BY player_name 
                        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_weight
FROM benn.college_football_players;

-- Window Function vs GROUP BY:
-- GROUP BY: 여러 행을 하나로 집계 (행 개수 감소)
-- Window Function: 원본 행 유지하면서 집계 값 추가 (행 개수 유지)

-- 윈도우 함수 구조:
-- 함수() OVER(PARTITION BY 그룹화컬럼 ORDER BY 정렬컬럼 ROWS BETWEEN 범위)
