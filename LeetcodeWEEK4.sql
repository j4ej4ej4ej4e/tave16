-- 608. Tree Node
-- 목표: 트리 구조에서 각 노드의 타입(Root/Inner/Leaf) 분류
-- Root: 부모가 없는 노드 (p_id IS NULL)
-- Inner: 자식이 있는 노드 (다른 노드의 p_id로 존재)
-- Leaf: 자식이 없는 노드 (나머지)

SELECT
    id,
    CASE
        -- p_id가 NULL이면 Root (최상위 노드)
        WHEN p_id IS NULL THEN 'Root'
        
        -- 이 노드의 id가 다른 노드의 p_id로 존재하면 Inner (중간 노드)
        -- 즉, 자식이 있는 노드
        WHEN id IN (SELECT DISTINCT p_id FROM Tree WHERE p_id IS NOT NULL) THEN 'Inner'
        
        -- 나머지는 Leaf (말단 노드, 자식 없음)
        ELSE 'Leaf'
    END AS type
FROM Tree
ORDER BY id;

-- 626. Exchange Seats
-- 목표: 학생 좌석을 인접한 학생과 교환
-- 홀수 id는 다음 id와 교환, 짝수 id는 이전 id와 교환
-- 마지막 학생이 홀수 id면 그대로 유지

SELECT
    CASE
        -- 홀수 id이면서 마지막 학생인 경우 → 교환 불가, 그대로 유지
        WHEN id % 2 = 1 AND id = (SELECT MAX(id) FROM Seat) THEN id
        
        -- 홀수 id → 다음 학생(id+1)과 교환
        WHEN id % 2 = 1 THEN id + 1
        
        -- 짝수 id → 이전 학생(id-1)과 교환
        ELSE id - 1
    END AS id,
    student
FROM Seat
ORDER BY id;

-- 예시:
-- 원본: 1-Alice, 2-Bob, 3-Charlie, 4-David, 5-Eve
-- 결과: 1-Bob, 2-Alice, 3-David, 4-Charlie, 5-Eve


-- 1045. Customers Who Bought All Products
-- 목표: Product 테이블의 모든 제품을 구매한 고객 찾기
-- 전략: 고객별 구매한 distinct 제품 수가 전체 제품 수와 같은지 확인

SELECT customer_id
FROM Customer
GROUP BY customer_id
-- 이 고객이 구매한 서로 다른 제품의 개수가
-- 전체 제품 개수와 같으면 모든 제품을 구매한 것
HAVING COUNT(DISTINCT product_key) = (SELECT COUNT(*) FROM Product);

-- 예시:
-- Product: [1, 2, 3]
-- Customer A가 [1, 2, 3] 구매 → 포함
-- Customer B가 [1, 2] 구매 → 제외

-- 1158. Market Analysis I
-- 목표: 각 유저(구매자)의 2019년 주문 건수 조회
-- 주의: 2019년에 주문하지 않은 유저도 0으로 표시해야 함 (LEFT JOIN 사용)

SELECT 
    u.user_id AS buyer_id,
    u.join_date,
    -- 2019년 주문 건수 (없으면 0)
    COUNT(o.order_id) AS orders_in_2019
FROM 
    Users u
-- LEFT JOIN: 모든 유저를 포함하되, 2019년 주문만 매칭
LEFT JOIN 
    Orders o ON u.user_id = o.buyer_id 
    AND YEAR(o.order_date) = 2019  -- JOIN 조건에 연도 필터 포함
GROUP BY 
    u.user_id, u.join_date
ORDER BY 
    u.user_id;

-- 왜 WHERE가 아닌 JOIN 조건에 연도 필터를 넣는가?
-- WHERE YEAR(o.order_date) = 2019 사용 시:
--   → 2019년 주문이 없는 유저는 필터링되어 사라짐
-- JOIN 조건에 넣으면:
--   → 모든 유저가 포함되고, 2019년 주문만 카운트됨 (없으면 0)

-- 예시:
-- User 1: 2019년 3건, 2020년 2건 → orders_in_2019 = 3
-- User 2: 2020년만 1건 → orders_in_2019 = 0 (여전히 포함됨)
