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


--184번 
-- 단계별로 생각하기
SELECT 
    d.name AS Department,              -- 부서 이름
    e.name AS Employee,                -- 직원 이름  
    e.salary AS Salary                 -- 급여
FROM Employee e
JOIN Department d ON e.departmentId = d.id    -- 부서 정보 조인
WHERE e.salary = (                            -- 바깥 조건문은 해당 직원의 급여가 그 부서 안 최고 급여와 같을 떄
    SELECT MAX(salary)
    FROM Employee e2                          
    WHERE e2.departmentId = e.departmentId    -- 안쪽 조건문은 같은 부서 내에서
);

-- 185번 
SELECT Department, Employee, Salary
FROM (
    SELECT 
        d.name AS Department,
        e.name AS Employee,
        e.salary AS Salary,
        DENSE_RANK() OVER (                    -- 부서별로 순위 매기기
            PARTITION BY e.departmentId        -- 부서별로 나누어서  
            ORDER BY e.salary DESC             -- 급여 높은 순으로
        ) AS salary_rank
    FROM Employee e
    JOIN Department d ON e.departmentId = d.id
) ranked_employees
WHERE salary_rank <= 3;                       -- 상위 3등까지만
