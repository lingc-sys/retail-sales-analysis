-- ============================================
-- 1. 创建数据库和表
-- ============================================
CREATE DATABASE SalesAnalysis;
GO

USE SalesAnalysis;
GO

CREATE TABLE sales (
    sale_id INT IDENTITY(1,1) PRIMARY KEY,
    sale_date DATE NOT NULL,
    product_category NVARCHAR(50),
    product_name NVARCHAR(100),
    sales_amount DECIMAL(10,2),
    quantity INT,
    customer_id INT
);
GO

-- ============================================
-- 2. 插入模拟数据（500行）
-- ============================================
TRUNCATE TABLE sales;
GO

DECLARE @i INT = 1;
DECLARE @start_date DATE = '2023-01-01';
DECLARE @end_date DATE = '2025-12-31';
DECLARE @date_range INT = DATEDIFF(DAY, @start_date, @end_date);

DECLARE @products TABLE (category NVARCHAR(50), name NVARCHAR(100), min_price DECIMAL(10,2), max_price DECIMAL(10,2));
INSERT INTO @products VALUES 
('电子产品', '智能手机', 3000, 6000),
('电子产品', '蓝牙耳机', 150, 500),
('电子产品', '平板电脑', 2000, 4000),
('电子产品', '智能手表', 800, 2500),
('家居用品', '沙发', 1500, 4000),
('家居用品', '餐桌', 800, 3000),
('家居用品', '床垫', 1000, 5000),
('家居用品', '灯具', 100, 800),
('办公用品', '笔记本电脑', 4000, 8000),
('办公用品', '显示器', 800, 2000),
('办公用品', '键盘', 50, 300),
('办公用品', '鼠标', 20, 150),
('办公用品', '打印机', 500, 2000);

WHILE @i <= 500
BEGIN
    DECLARE @rand_days INT = ABS(CHECKSUM(NEWID())) % @date_range;
    DECLARE @sale_date DATE = DATEADD(DAY, @rand_days, @start_date);
    
    DECLARE @rand_product INT = ABS(CHECKSUM(NEWID())) % (SELECT COUNT(*) FROM @products) + 1;
    DECLARE @category NVARCHAR(50), @name NVARCHAR(100), @min_price DECIMAL(10,2), @max_price DECIMAL(10,2);
    SELECT @category = category, @name = name, @min_price = min_price, @max_price = max_price
    FROM (SELECT *, ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn FROM @products) AS p
    WHERE rn = @rand_product;
    
    DECLARE @quantity INT = ABS(CHECKSUM(NEWID())) % 5 + 1;
    DECLARE @unit_price DECIMAL(10,2) = @min_price + (ABS(CHECKSUM(NEWID())) % CAST((@max_price - @min_price) * 100 AS INT)) / 100.0;
    DECLARE @sales_amount DECIMAL(10,2) = @unit_price * @quantity;
    DECLARE @customer_id INT = ABS(CHECKSUM(NEWID())) % 401 + 100;
    
    INSERT INTO sales (sale_date, product_category, product_name, sales_amount, quantity, customer_id)
    VALUES (@sale_date, @category, @name, @sales_amount, @quantity, @customer_id);
    
    SET @i = @i + 1;
END;
GO

-- ============================================
-- 3. 月度销售额环比分析
-- ============================================
WITH monthly_sales AS (
    SELECT 
        YEAR(sale_date) AS sale_year,
        MONTH(sale_date) AS sale_month,
        SUM(sales_amount) AS total_sales
    FROM sales
    GROUP BY YEAR(sale_date), MONTH(sale_date)
)
SELECT 
    sale_year,
    sale_month,
    total_sales,
    LAG(total_sales) OVER (ORDER BY sale_year, sale_month) AS prev_month_sales,
    CAST(
        ISNULL(
            (total_sales - LAG(total_sales) OVER (ORDER BY sale_year, sale_month)) * 100.0 
            / NULLIF(LAG(total_sales) OVER (ORDER BY sale_year, sale_month), 0),
            0
        ) AS DECIMAL(10,2)
    ) AS growth_rate_percent
FROM monthly_sales
ORDER BY sale_year, sale_month;
GO