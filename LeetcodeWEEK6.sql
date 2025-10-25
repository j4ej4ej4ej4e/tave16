-- 1. LeetCode 1341 - Movie Rating
-- UNION ALL: 두 개의 SELECT 결과를 합치기 (중복 제거 안함)  VS 그냥 UNION이랑 차이 구분하기
-- 첫 번째 쿼리: 가장 많은 영화를 평가한 사용자
(SELECT name AS results
FROM MovieRating 
JOIN Users USING(user_id)  -- USING: 두 테이블의 같은 이름의 컬럼으로 조인
GROUP BY user_id           -- GROUP BY: user_id로 그룹화
ORDER BY COUNT(*) DESC, name  -- ORDER BY: 평가 횟수 내림차순, 이름 오름차순
LIMIT 1)                   -- LIMIT: 상위 1개만 선택

UNION ALL

-- 두 번째 쿼리: 2020년 2월 평균 평점이 가장 높은 영화
(SELECT title AS results
FROM MovieRating 
JOIN Movies USING(movie_id)
WHERE created_at BETWEEN '2020-02-01' AND '2020-02-29'  -- BETWEEN: 날짜 범위 필터
GROUP BY movie_id
ORDER BY AVG(rating) DESC, title  -- AVG: 평균 계산
LIMIT 1);

-- 2. LeetCode 1393 - Capital Gain/Loss
SELECT 
    stock_name,
    -- CASE WHEN: 조건에 따라 다른 값 반환
    -- SUM: 합계 계산
    SUM(CASE 
        WHEN operation = 'Sell' THEN price      -- 판매는 양수
        WHEN operation = 'Buy' THEN -price      -- 구매는 음수
    END) AS capital_gain_loss
FROM Stocks
GROUP BY stock_name;  -- 주식별로 그룹화

--3. LeetCode 1907 - Count Salary Categories
-- 첫 번째 범주: Low Salary
SELECT 
    'Low Salary' AS category,  -- AS: 컬럼 별칭(alias) 지정
    COUNT(*) AS accounts_count -- COUNT(*): 행의 개수 세기
FROM Accounts
WHERE income < 20000           -- WHERE: 조건 필터링

UNION ALL  -- UNION ALL: 여러 결과를 하나로 합치기 (중복 제거 안함)

-- 두 번째 범주: Average Salary
SELECT 
    'Average Salary' AS category,
    COUNT(*) AS accounts_count
FROM Accounts
WHERE income BETWEEN 20000 AND 50000  -- BETWEEN: 범위 조건 (양 끝 포함)

UNION ALL

-- 세 번째 범주: High Salary
SELECT 
    'High Salary' AS category,
    COUNT(*) AS accounts_count
FROM Accounts
WHERE income > 50000;

-- 4. LeetCode 1934 - Confirmation Rate
SELECT 
    s.user_id,
    -- AVG: 평균 계산 (0과 1의 평균 = 비율)
    ROUND(AVG(CASE WHEN c.action = 'confirmed' THEN 1 ELSE 0 END), 2) 
    AS confirmation_rate
FROM Signups s
LEFT JOIN Confirmations c ON s.user_id = c.user_id
GROUP BY s.user_id;


--5. LeetCode 3220 - Odd and Even Transactions
SELECT 
    transaction_date,
    -- 홀수 금액의 합계
    SUM(CASE WHEN amount % 2 = 1 THEN amount ELSE 0 END) AS odd_sum,
    -- %: 나머지 연산자 (모듈로)
    -- amount % 2 = 1: 홀수 판별
    
    -- 짝수 금액의 합계
    SUM(CASE WHEN amount % 2 = 0 THEN amount ELSE 0 END) AS even_sum
    -- amount % 2 = 0: 짝수 판별
FROM transactions
GROUP BY transaction_date  -- 날짜별로 그룹화
ORDER BY transaction_date; -- 날짜순으로 정렬 (기본값: 오름차순 ASC)
