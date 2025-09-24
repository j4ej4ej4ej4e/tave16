-- Lesson 1 : count 함수 
-- 1. 전체 행 개수 세기
SELECT COUNT(*) -- 모든 행의 개수를 반환 (NULL 포함)
FROM tutorial.aapl_historical_stock_price;

-- COUNT(1)도 같은 결과 (개인 취향에 따라 선택)
SELECT COUNT(1)
FROM tutorial.aapl_historical_stock_price;

-- 2. 특정 컬럼의 NULL이 아닌 행 개수 세기
SELECT COUNT(high) -- high 컬럼에서 NULL이 아닌 값들만 카운트
FROM tutorial.aapl_historical_stock_price;

-- 3. 연습문제: low 컬럼의 NULL이 아닌 행 개수 세기
SELECT COUNT(low) -- low 컬럼에서 NULL이 아닌 값들만 카운트
FROM tutorial.aapl_historical_stock_price;

-- 4. 텍스트 컬럼도 카운트 가능
SELECT COUNT(date) -- 날짜 컬럼의 NULL이 아닌 값들 카운트
FROM tutorial.aapl_historical_stock_price;

-- 5. 컬럼 별칭(Alias) 사용하기
SELECT COUNT(date) AS count_of_date -- 결과 컬럼명을 'count_of_date'로 설정
FROM tutorial.aapl_historical_stock_price;

-- 공백이 포함된 별칭은 큰따옴표 사용
SELECT COUNT(date) AS "Count Of Date"
FROM tutorial.aapl_historical_stock_price;

-- Lesson 2 : Sum 함수
-- 1. 기본 SUM 함수 사용법
SELECT SUM(volume) -- volume 컬럼의 모든 값을 합계
FROM tutorial.aapl_historical_stock_price;

-- 주의사항: 
-- SUM은 숫자 컬럼에만 사용 가능
-- NULL 값은 0으로 처리됨

-- Lesson 3: MIN/MAX 함수
-- 1. MIN과 MAX 함수 동시 사용
SELECT MIN(volume) AS min_volume,  -- volume 컬럼의 최솟값
       MAX(volume) AS max_volume   -- volume 컬럼의 최댓값
FROM tutorial.aapl_historical_stock_price;

-- MIN/MAX 함수 특징:
-- 숫자: 최솟값/최댓값
-- 날짜: 가장 이른/늦은 날짜  
-- 텍스트: 알파벳 순서로 A에 가까운/Z에 가까운 값

Lesson 4: AVG 함수
-- 1. 기본 AVG 함수 사용법
SELECT AVG(high) -- high 컬럼의 평균값 계산
FROM tutorial.aapl_historical_stock_price;

-- 2. NULL 값이 있는 경우와 없는 경우 비교
-- 아래 두 쿼리는 동일한 결과를 반환 (AVG는 NULL을 자동으로 무시)
SELECT AVG(high)
FROM tutorial.aapl_historical_stock_price
WHERE high IS NOT NULL;

SELECT AVG(high)
FROM tutorial.aapl_historical_stock_price;

-- AVG 함수 특징:
-- 숫자 컬럼에만 사용 가능
-- NULL 값은 완전히 무시됨


