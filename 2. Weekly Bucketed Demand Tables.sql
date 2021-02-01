
DROP TABLE IF EXISTS [projctd_dmnd_weekly_buckets];

CREATE TABLE [projctd_dmnd_weekly_buckets]
  (
    [item_id]      VARCHAR(54)
   --,[line_code]    VARCHAR(54)
   ,[top_customer] VARCHAR(54)
   ,[1_wk_out]     INT
   ,[2_wk_out]     INT
   ,[3_wk_out]     INT
   ,[4_wk_out]     INT
   ,[5_wk_out]     INT
   ,[6_wk_out]     INT
  );

WITH [cte_remove_zeroes]
 (
   [item_id]
  ,[top_customer]
  ,[date]
  ,[p50]
  ,[p60]
  ,[p70]
  ,[p80]
  )
AS
 (
  SELECT
      [item_id]
     ,[top_customer]
     ,[date]
     ,CASE WHEN SUM([p50]) < 0
           THEN 0
           ELSE SUM([p50])
           END
     ,CASE WHEN SUM([p60]) < 0
           THEN 0
           ELSE SUM([p60])
           END
     ,CASE WHEN SUM([p70]) < 0
           THEN 0
           ELSE SUM([p70])
           END
     ,CASE WHEN SUM([p80]) < 0
           THEN 0
           ELSE SUM([p80])
           END
  FROM [1_31_21_weekly_run_w_FMP_buy]
  GROUP BY
     [item_id]
    ,[top_customer]
    ,[date]
)
,
  [cte_float_to_int]
 (
   [item_id]
  ,[top_customer]
  ,[date]
  ,[p50]
  ,[p60]
  ,[p70]
  ,[p80]
  )
AS
 (
  SELECT 
      [item_id]
     ,[top_customer]
     ,[date]
     ,SUM( CAST (ROUND ([p50], 0) AS INT) )
     ,SUM( CAST (ROUND ([p60], 0) AS INT) )
     ,SUM( CAST (ROUND ([p70], 0) AS INT) )
     ,SUM( CAST (ROUND ([p80], 0) AS INT) )
   FROM [cte_remove_zeroes]
   GROUP BY 
      [item_id]
     ,[top_customer]
     ,[date]
 )
,
  [cte_calc]
 (
    [item_id]
   ,[top_customer]
   ,[1_wk_out]
   ,[2_wk_out]
   ,[3_wk_out]
   ,[4_wk_out]
   ,[5_wk_out]
   ,[6_wk_out]
 )
AS 
(
SELECT
   [item_id]
  ,[top_customer]
  ,CASE WHEN [date] LIKE ('2021-01-31%')
        THEN SUM([p60])
        ELSE 0
        END
  ,CASE WHEN [date] LIKE ('2021-02-07%')
        THEN SUM([p60])
        ELSE 0
        END
  ,CASE WHEN [date] LIKE ('2021-02-14%')
        THEN SUM([p60])
        ELSE 0
        END
  ,CASE WHEN [date] LIKE ('2021-02-21%')
        THEN SUM([p60])
        ELSE 0
        END
  ,CASE WHEN [date] LIKE ('2021-02-28%')
        THEN SUM([p60])
        ELSE 0
        END
  ,CASE WHEN [date] LIKE ('2021-03-07%')
        THEN SUM([p60])
        ELSE 0
        END
FROM [cte_float_to_int]
GROUP BY
   [item_id]
  ,[date]
  ,[top_customer]
)
  
INSERT INTO [projctd_dmnd_weekly_buckets]
  (
    [item_id]
   ,[top_customer]
   ,[1_wk_out]
   ,[2_wk_out]
   ,[3_wk_out]
   ,[4_wk_out]
   ,[5_wk_out]
   ,[6_wk_out]
  )
   
SELECT 
    [item_id]
   ,[top_customer]
   ,SUM([1_wk_out])
   ,SUM([2_wk_out])
   ,SUM([3_wk_out])
   ,SUM([4_wk_out])
   ,SUM([5_wk_out])
   ,SUM([6_wk_out])
FROM [cte_calc]
GROUP BY
    [item_id]
   ,[top_customer]
