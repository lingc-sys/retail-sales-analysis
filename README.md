# retail-sales-analysis
SQL 零售销售数据分析项目 – 窗口函数、环比、排名、复购分析
## 项目简介
使用 SQL Server 对模拟零售销售数据进行分析，涵盖销售额趋势、环比增长率、产品类别排名、复购客户识别等。

## 数据表结构
- `sales`：销售记录（销售日期、产品类别、产品名称、销售额、数量、客户ID）

## 核心分析脚本
- `sales_analysis.sql`：包含以下分析：
  - 月度销售额环比
  - 产品类别销售排名（窗口函数 `RANK()`）
  - 年累计销售额（`SUM OVER`）
  - 移动平均（3期）
  - 复购客户识别

## 如何运行
1. 在 SQL Server Management Studio (SSMS) 中执行 `sales_analysis.sql`。
2. 确保数据库 `SalesAnalysis` 已创建。

## 分析结论（示例）
- 2024年 Q4 销售额同比增长 15%。
- 电子产品类别销售额连续三个季度排名第一。
- 复购客户贡献了总销售额的 62%。

## 技术要点
- 窗口函数：`ROW_NUMBER`, `RANK`, `LAG`, `LEAD`, `SUM OVER`
- 公共表表达式 (CTE)
- 空值处理：`ISNULL`, `NULLIF`
