DROP TABLE IF EXISTS [projctd_dmnd_weekly_buckets];

CREATE TABLE [projctd_dmnd_weekly_buckets]
  (
    [item_id]      VARCHAR(54)
   ,[line_code]    VARCHAR(54)
   ,[class_code]   VARCHAR(54)
   ,[pop_code]     VARCHAR(54)
   ,[top_customer] VARCHAR(54)
   ,[1_wk_out]     INT
   ,[2_wk_out]     INT
   ,[3_wk_out]     INT
   ,[4_wk_out]     INT
   ,[gross_1_wk_out] NUMERIC(18,2)
   ,[gross_2_wk_out] NUMERIC(18,2)
   ,[gross_3_wk_out] NUMERIC(18,2)
   ,[gross_4_wk_out] NUMERIC(18,2)
   ,PRIMARY KEY ([item_id], [top_customer])
);

WITH [cte_date_raw]
  ( [date_trim]
   ,[item_id]
   ,[top_customer]
   ,[p40]
   ,[p50]
   ,[p60]
   ,[p70]
   ,[p80]
  )
 AS 
(
SELECT
   CONVERT(VARCHAR(11), [date], 20)
  ,[item_id]
  ,[top_customer]
  ,SUM( CAST (ROUND ([p40], 0) AS INT) )
  ,SUM( CAST (ROUND ([p50], 0) AS INT) )
  ,SUM( CAST (ROUND ([p60], 0) AS INT) )
  ,SUM( CAST (ROUND ([p70], 0) AS INT) )
  ,SUM( CAST (ROUND ([p80], 0) AS INT) )
FROM [1.1.2021_exp_merged]
GROUP BY
    CONVERT(VARCHAR(11), [date], 20)
  ,[item_id]
  ,[top_customer]
)
,
[cte_bucket]
  ( 
   [date_trim]
  ,[item_id]
  ,[top_customer]
  ,[1_wk_out]
  ,[2_wk_out]
  ,[3_wk_out]
  ,[4_wk_out]
  )
 AS 
(
SELECT
   [date_trim]
  ,[item_id]
  ,[top_customer]
  ,CASE WHEN [date_trim] = '2021-01-03' THEN SUM(ISNULL([p70], 0))
        ELSE 0
        END
  ,CASE WHEN [date_trim] = '2021-01-10' THEN SUM(ISNULL([p70], 0))
        ELSE 0
        END
  ,CASE WHEN [date_trim] = '2021-01-17' THEN SUM(ISNULL([p70], 0))
        ELSE 0
        END
  ,CASE WHEN [date_trim] = '2021-01-24' THEN SUM(ISNULL([p70], 0))
        ELSE 0
        END
FROM [cte_date_raw]
GROUP BY
   [date_trim]
  ,[item_id]
  ,[top_customer]
)
,
[cte_gross_$]
  ( 
   [date_trim]
  ,[item_id]
  ,[top_customer]
   ,[gross_1_wk_out]
   ,[gross_2_wk_out]
   ,[gross_3_wk_out]
   ,[gross_4_wk_out]
  )
 AS 
(
SELECT
   [cte_bucket].[date_trim]
  ,[cte_bucket].[item_id]
  ,[cte_bucket].[top_customer]
  ,SUM([cte_bucket].[1_wk_out]) * SUM([avg_wholesale_price].[avg_price])
  ,SUM([cte_bucket].[2_wk_out]) * SUM([avg_wholesale_price].[avg_price])
  ,SUM([cte_bucket].[3_wk_out]) * SUM([avg_wholesale_price].[avg_price])
  ,SUM([cte_bucket].[4_wk_out]) * SUM([avg_wholesale_price].[avg_price])
FROM [cte_bucket]
JOIN [avg_wholesale_price]
  ON [cte_bucket].[item_id] = [avg_wholesale_price].[item_id]
GROUP BY
   [cte_bucket].[date_trim]
  ,[cte_bucket].[item_id]
  ,[cte_bucket].[top_customer]
) 

INSERT INTO [projctd_dmnd_weekly_buckets]
  ( 
    [item_id]
   ,[line_code]
   ,[class_code]
   ,[pop_code]
   ,[top_customer]
   ,[1_wk_out]
   ,[2_wk_out]
   ,[3_wk_out]
   ,[4_wk_out]
  -- ,[gross_1_wk_out]
   --,[gross_2_wk_out]
   --,[gross_3_wk_out]
   --,[gross_4_wk_out]
)
   

SELECT
   [cte_bucket].[item_id]
  ,[item_lu].[line_code]
  ,[item_lu].[class_code]
  ,[item_lu].[pop_code]
  ,[cte_bucket].[top_customer]
  ,SUM([cte_bucket].[1_wk_out]) AS [1_wk_out]
  ,SUM([cte_bucket].[2_wk_out]) AS [2_wk_out]
  ,SUM([cte_bucket].[3_wk_out]) AS [3_wk_out]
  ,SUM([cte_bucket].[4_wk_out]) AS [4_wk_out]
 -- ,SUM([cte_gross_$].[gross_1_wk_out]) AS [gross_1_wk_out]
 -- ,SUM([cte_gross_$].[gross_2_wk_out]) AS [gross_2_wk_out]
  --,SUM([cte_gross_$].[gross_3_wk_out]) AS [gross_3_wk_out]
 -- ,SUM([cte_gross_$].[gross_4_wk_out]) AS [gross_4_wk_out]
FROM [cte_bucket]
JOIN [item_lu]
  ON [cte_bucket].[item_id] = [item_lu].[part_number]
--JOIN [cte_gross_$]
  --ON [cte_bucket].[item_id] = [cte_gross_$].[item_id]
 --AND [cte_bucket].[top_customer] = [cte_gross_$].[top_customer]
GROUP BY
   [cte_bucket].[item_id]
  ,[item_lu].[line_code]
  ,[item_lu].[class_code]
  ,[item_lu].[pop_code]
  ,[cte_bucket].[top_customer]
