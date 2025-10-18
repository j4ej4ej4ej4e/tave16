--1. LeetCode 1164. Product Price at a Given Date
-- 상품의 가격 변경 이력이 담긴 테이블->  날짜(2019-08-16) 기준으로 모든 상품의 가격을 조회
WITH RankedPrices AS (
    SELECT
        product_id,
        new_price,
        -- 각 제품별로 기준일 이전의 가장 최신 기록에 1을 부여
        RANK() OVER (
            PARTITION BY product_id
            ORDER BY change_date DESC
        ) AS rn
    FROM
        Products
    WHERE
        -- 기준일 또는 그 이전에 기록된 변경만 고려
        change_date <= '2019-08-16'
)
SELECT
    p.product_id,
    -- (1) 최신 가격이 있으면 해당 가격을 사용
    -- (2) 최신 가격이 없으면 (LEFT JOIN으로 NULL이 되면) 기본값 10을 사용
    COALESCE(rp.new_price, 10) AS price
FROM
    -- 모든 제품 ID 목록을 확보 (DISTINCT)
    (SELECT DISTINCT product_id FROM Products) AS p
LEFT JOIN
    RankedPrices rp ON p.product_id = rp.product_id AND rp.rn = 1
ORDER BY
    p.product_id;
----------------------------------------------------------------------------------------------------------------

--LeetCode 1174. Immediate Food Delivery II
WITH FirstOrders AS (
    SELECT
        customer_id,
        order_date,
        customer_pref_delivery_date,
        -- 고객별로 가장 빠른 주문에 순위 1을 부여
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY order_date ASC
        ) AS rn,
        -- 첫 주문이 즉시(immediate) 배송되었는지 플래그 (1이면 즉시, 0이면 아님)
        CASE WHEN order_date = customer_pref_delivery_date THEN 1 ELSE 0 END AS is_immediate
    FROM
        Delivery
)
SELECT
    -- 즉시 주문 건수 합 / 전체 고객 수 * 100
    ROUND(
        SUM(is_immediate) * 100.0 / COUNT(customer_id), 
        2
    ) AS immediate_percentage
FROM
    FirstOrders
WHERE
    rn = 1; -- 첫 주문만 대상으로 계산

----------------------------------------------------------------------------------------------------------------

--LeetCode 1193. Monthly Transactions I
SELECT
    -- 연월(YYYY-MM)로 그룹화
    DATE_FORMAT(trans_date, '%Y-%m') AS month,
    country,
    -- 해당 월의 총 거래 건수
    COUNT(id) AS trans_count,
    -- 해당 월의 승인된 거래 건수 (조건부 카운트)
    SUM(CASE WHEN state = 'approved' THEN 1 ELSE 0 END) AS approved_count,
    -- 해당 월의 총 거래 금액
    SUM(amount) AS trans_total_amount,
    -- 해당 월의 총 승인 금액 (조건부 합계)
    SUM(CASE WHEN state = 'approved' THEN amount ELSE 0 END) AS approved_total_amount
FROM
    Transactions
WHERE
    -- 2018년도 데이터만 필요 (문제 조건에 따라 필요)
    YEAR(trans_date) = 2018 
GROUP BY
    month, country;

----------------------------------------------------------------------------------------------------------------
-- LeetCode 1204. Last Person to Fit in the Elevator
WITH CumulativeWeight AS (
    SELECT
        person_name,
        weight,
        turn,
        -- 탑승 순서(turn)에 따른 누적 무게 계산
        SUM(weight) OVER (
            ORDER BY turn ASC
        ) AS total_weight
    FROM
        Queue
)
SELECT
    person_name
FROM
    CumulativeWeight
WHERE
    total_weight <= 1000 -- 엘리베이터에 탑승 가능한 조건
ORDER BY
    turn DESC -- 탑승 가능한 사람 중 turn이 가장 큰 사람 (마지막 사람)
LIMIT 1;

----------------------------------------------------------------------------------------------------------------

--LeetCode 1321. Restaurant Growth
WITH DailyData AS (
    -- 1. 일별 순매출액(daily_amount)만 집계
    SELECT
        visited_on,
        SUM(amount) AS daily_amount
    FROM
        Customer
    GROUP BY
        visited_on
),
RollingSum AS (
    SELECT
        visited_on,
        -- 2. 7일간의 매출 합계 (롤링 합계)
        SUM(daily_amount) OVER (
            ORDER BY visited_on ASC
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ) AS total_amount,
        -- 3. 7일간의 데이터가 모두 쌓였는지 확인하기 위한 누적 일수 카운트
        COUNT(visited_on) OVER (
            ORDER BY visited_on ASC
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ) AS days_count
    FROM
        DailyData
)
SELECT
    visited_on,
    -- OUTPUT FIELD: 7일간의 총 합계 (Expected output "amount")
    total_amount AS amount,
    -- OUTPUT FIELD: 7일간의 평균 매출액 (7일 합계 / 7)
    ROUND(total_amount / 7, 2) AS average_amount
FROM
    RollingSum
-- 4. 7일치 데이터가 모두 쌓인 날짜(days_count = 7)부터 결과 필터링
WHERE
    days_count = 7
ORDER BY
    visited_on;
