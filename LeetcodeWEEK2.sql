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

