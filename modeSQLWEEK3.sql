-- Lesson 5 : GROUP BY
-- 1. 기본 GROUP BY 사용법
SELECT year,
       COUNT(*) AS count
FROM tutorial.aapl_historical_stock_price
GROUP BY year;
-- 특정 컬럼을 기준으로 그룹화하여 집계

-- 2. 여러 집계 함수 함께 사용
SELECT year,
       COUNT(*) AS count,
       AVG(high) AS avg_high,
       AVG(low) AS avg_low
FROM tutorial.aapl_historical_stock_price
GROUP BY year;

-- 3. 여러 컬럼으로 GROUP BY
SELECT year,
       month,
       COUNT(*) AS count
FROM tutorial.aapl_historical_stock_price
GROUP BY year, month;
-- year와 month의 조합별로 그룹화

-- 4. GROUP BY 순서 번호 사용 (컬럼 위치)
SELECT year,
       month,
       COUNT(*) AS count
FROM tutorial.aapl_historical_stock_price
GROUP BY 1, 2;
-- 1은 첫 번째 SELECT 컬럼(year), 2는 두 번째(month)

-- GROUP BY 주의사항:
-- SELECT 절에 집계 함수가 아닌 컬럼은 반드시 GROUP BY에 포함되어야 함
-- NULL 값도 하나의 그룹으로 취급됨


-- Lesson 6 : HAVING
-- 1. HAVING 기본 사용법 (그룹화된 결과 필터링)
SELECT year,
       month,
       MAX(high) AS month_high
FROM tutorial.aapl_historical_stock_price
GROUP BY year, month
HAVING MAX(high) > 400;
-- 월별 최고가가 400을 초과하는 그룹만 표시

-- 2. WHERE vs HAVING 차이
-- WHERE: 그룹화 전 개별 행 필터링
SELECT year,
       month,
       MAX(high) AS month_high
FROM tutorial.aapl_historical_stock_price
WHERE high > 400
GROUP BY year, month;

-- HAVING: 그룹화 후 집계 결과 필터링
SELECT year,
       month,
       MAX(high) AS month_high
FROM tutorial.aapl_historical_stock_price
GROUP BY year, month
HAVING MAX(high) > 400;

-- 3. WHERE와 HAVING 함께 사용
SELECT year,
       month,
       MAX(high) AS month_high
FROM tutorial.aapl_historical_stock_price
WHERE year >= 2010  -- 먼저 2010년 이후 데이터만 필터링
GROUP BY year, month
HAVING MAX(high) > 400;  -- 그 중 월별 최고가가 400 초과인 것만

-- 실행 순서:
-- FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY


-- Lesson 7 : CASE
-- 1. 기본 CASE 문법
SELECT player_name,
       year,
       CASE 
         WHEN year = 'SR' THEN 'Senior'
         WHEN year = 'JR' THEN 'Junior'
         WHEN year = 'SO' THEN 'Sophomore'
         WHEN year = 'FR' THEN 'Freshman'
         ELSE 'Unknown'
       END AS year_full
FROM benn.college_football_players;

-- 2. CASE와 집계 함수 결합
SELECT 
  CASE 
    WHEN year = 'FR' THEN 'Freshman'
    WHEN year = 'SO' THEN 'Sophomore'
    WHEN year = 'JR' THEN 'Junior'
    WHEN year = 'SR' THEN 'Senior'
    ELSE 'Unknown'
  END AS year_group,
  COUNT(*) AS count
FROM benn.college_football_players
GROUP BY year_group;

-- 3. 조건별 카운트 (열 피벗)
SELECT 
  COUNT(CASE WHEN year = 'FR' THEN 1 ELSE NULL END) AS fr_count,
  COUNT(CASE WHEN year = 'SO' THEN 1 ELSE NULL END) AS so_count,
  COUNT(CASE WHEN year = 'JR' THEN 1 ELSE NULL END) AS jr_count,
  COUNT(CASE WHEN year = 'SR' THEN 1 ELSE NULL END) AS sr_count
FROM benn.college_football_players;

-- 4. 숫자 범위로 그룹화
SELECT 
  CASE 
    WHEN weight < 200 THEN 'Under 200'
    WHEN weight BETWEEN 200 AND 250 THEN '200-250'
    WHEN weight > 250 THEN 'Over 250'
    ELSE 'Unknown'
  END AS weight_group,
  COUNT(*) AS count
FROM benn.college_football_players
GROUP BY weight_group;

-- CASE 주의사항:
-- ELSE를 생략하면 매칭되지 않는 값은 NULL 반환
-- 조건은 위에서부터 순서대로 평가됨 (첫 매칭에서 중단)


-- Lesson 8 : DISTINCT
-- 1. 기본 DISTINCT 사용법
SELECT DISTINCT month  -- 중복 제거된 월 값만 반환
FROM tutorial.aapl_historical_stock_price;

-- 2. 여러 컬럼에 DISTINCT 적용
SELECT DISTINCT year, month  -- year와 month 조합의 중복 제거
FROM tutorial.aapl_historical_stock_price;

-- 3. DISTINCT와 집계 함수
SELECT COUNT(DISTINCT month) AS unique_months  -- 고유한 월의 개수
FROM tutorial.aapl_historical_stock_price;

-- 4. DISTINCT vs GROUP BY (결과는 같지만 용도가 다름)
-- DISTINCT: 단순히 중복 제거
SELECT DISTINCT year
FROM tutorial.aapl_historical_stock_price;

-- GROUP BY: 집계 함수와 함께 사용
SELECT year,
       COUNT(*) AS count
FROM tutorial.aapl_historical_stock_price
GROUP BY year;

-- 5. 여러 컬럼의 고유값 개수 세기
SELECT 
  COUNT(DISTINCT year) AS years,
  COUNT(DISTINCT month) AS months,
  COUNT(DISTINCT year || month) AS year_month_combos
FROM tutorial.aapl_historical_stock_price;

-- DISTINCT 주의사항:
-- DISTINCT는 SELECT 바로 뒤에 위치
-- 성능에 영향을 줄 수 있으므로 필요한 경우만 사용
-- NULL도 하나의 고유값으로 취급됨
