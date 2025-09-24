-- 176번
-- 1. 서브쿼리 사용
SELECT 
    (SELECT DISTINCT salary          -- 중복 제거한 급여에서
     FROM Employee                   -- Employee 테이블에서
     ORDER BY salary DESC            -- 급여 높은 순으로 정렬하고
     LIMIT 1 OFFSET 1               -- 두 번째 값을 가져오기 (첫 번째 건너뛰고)
    ) AS SecondHighestSalary;

-- 2. 최고 급여보다 작은 것 중 최대값
SELECT MAX(salary) AS SecondHighestSalary
FROM Employee
WHERE salary < (SELECT MAX(salary) FROM Employee);  -- 최고 급여 제외하고 그 중 최대값 (근데 이건 딱 2등 출력할때만 사용가능함,,,,,,,)


-- 177번
CREATE FUNCTION getNthHighestSalary(N INT) RETURNS INT
BEGIN
    -- MySQL 제한사항: LIMIT/OFFSET에 직접 연산식 사용이 안된다요    
    DECLARE M INT;                    -- OFFSET 값을 저장할 변수 선언
    SET M = N - 1;                   -- N번째 = OFFSET은 N-1 (인덱스는 0부터 시작하기 때문에)
                                     -- 예: 2번째(N=2) → OFFSET=1
    
    RETURN (
        SELECT DISTINCT salary        -- 중복 급여 제거 (같은 급여 여러 명 가능)
        FROM Employee                 -- Employee 테이블에서
        ORDER BY salary DESC          -- 급여 높은 순으로 정렬 (내림차순)
        LIMIT 1 OFFSET M             -- 첫 번째 1개만, M개 건너뛰기
                                     -- 즉, M+1번째 값을 가져옴 = N번째 값
    );
END

--178번
SELECT 
    score,                                    -- 
    DENSE_RANK() OVER (                      -- 순위 매기기 (동점자 다음 순위 패스 안하고 1-1-2-3 이런식으로 )
        ORDER BY score DESC                   -- 점수 높은 순으로
    ) AS `rank`                              -- rank는 예약어 가능성 높아서 백틱하죠
FROM Scores
ORDER BY score DESC;

-- 180번
SELECT DISTINCT l1.num AS ConsecutiveNums
FROM Logs l1                           -- 첫 번째 테이블 -> 기준
JOIN Logs l2 ON l2.id = l1.id + 1     -- 다음
JOIN Logs l3 ON l3.id = l1.id + 2     -- 다다음 
WHERE l1.num = l2.num                  -- 첫 번째 = 두 번째
  AND l1.num = l3.num;                -- 첫 번째 = 세 번째

