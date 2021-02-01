DROP TABLE IF EXISTS [unfilled_by_cust];

CREATE TABLE [unfilled_by_cust]
  (
   [item_id]            VARCHAR(54)
  ,[line_code]          VARCHAR(54)
  ,[class_code]         VARCHAR(54)
  ,[pop_code]           VARCHAR(54)
  ,[top_customer]       VARCHAR(54)
  ,[unfill_by_cust_wk1] NUMERIC(10, 2)
  ,[unfill_by_cust_wk2] NUMERIC(10, 2)
  ,[unfill_by_cust_wk3] NUMERIC(10, 2)
  ,[unfill_by_cust_wk4] NUMERIC(10, 2)
  ,[unfill_by_cust_wk5] NUMERIC(10, 2)
  ,[unfill_by_cust_wk6] NUMERIC(10, 2)
  ,PRIMARY KEY ([item_id], [top_customer])
  );

WITH 
  [cte_unfilled_wk1]
 (
    [item_id]
   ,[top_customer]
   ,[unfill_by_cust_wk1]
  )
AS
(
   SELECT
      DISTINCT [cust_allctn].[item_id]
     ,[cust_allctn].[top_customer]
     ,(
       SUM(  [projctd_dmnd_weekly_buckets].[1_wk_out] )
       -
       SUM( [cust_allctn].[allctn_by_cust_wk1] )
       )
   FROM [cust_allctn]
   JOIN  [projctd_dmnd_weekly_buckets]
     ON [cust_allctn].[item_id] =  [projctd_dmnd_weekly_buckets].[item_id]
    AND [cust_allctn].[top_customer] =  [projctd_dmnd_weekly_buckets].[top_customer]
   GROUP BY 
      [cust_allctn].[item_id]
     ,[cust_allctn].[top_customer]
)
,

  [cte_unfilled_wk2]
 (
    [item_id]
   ,[top_customer]
   ,[unfill_by_cust_wk2]
  )
AS
(
   SELECT
      DISTINCT [cust_allctn].[item_id]
     ,[cust_allctn].[top_customer]
     ,
      (
      SUM(  [projctd_dmnd_weekly_buckets].[2_wk_out] )
      -
      SUM( [cust_allctn].[allctn_by_cust_wk2] )
      )
   FROM [cust_allctn]
   JOIN  [projctd_dmnd_weekly_buckets]
     ON [cust_allctn].[item_id] =  [projctd_dmnd_weekly_buckets].[item_id]
    AND [cust_allctn].[top_customer] =  [projctd_dmnd_weekly_buckets].[top_customer]
   GROUP BY 
      [cust_allctn].[item_id]
     ,[cust_allctn].[top_customer]
)
,

  [cte_unfilled_wk3]
 (
    [item_id]
   ,[top_customer]
   ,[unfill_by_cust_wk3]
  )
AS
(
   SELECT
      DISTINCT [cust_allctn].[item_id]
     ,[cust_allctn].[top_customer]
     ,(
      SUM(  [projctd_dmnd_weekly_buckets].[3_wk_out] )
      -
      SUM( [cust_allctn].[allctn_by_cust_wk3] )
      )
   FROM [cust_allctn]
   JOIN  [projctd_dmnd_weekly_buckets]
     ON [cust_allctn].[item_id] =  [projctd_dmnd_weekly_buckets].[item_id]
    AND [cust_allctn].[top_customer] =  [projctd_dmnd_weekly_buckets].[top_customer]
   GROUP BY 
      [cust_allctn].[item_id]
     ,[cust_allctn].[top_customer]
)
,

  [cte_unfilled_wk4]
 (
    [item_id]
   ,[top_customer]
   ,[unfill_by_cust_wk4]
  )
AS
(
   SELECT
      DISTINCT [cust_allctn].[item_id]
     ,[cust_allctn].[top_customer]
     ,(
      SUM(  [projctd_dmnd_weekly_buckets].[4_wk_out]  )
      -
      SUM( [cust_allctn].[allctn_by_cust_wk4] )
      )
   FROM [cust_allctn]
   JOIN  [projctd_dmnd_weekly_buckets]
     ON [cust_allctn].[item_id] =  [projctd_dmnd_weekly_buckets].[item_id]
    AND [cust_allctn].[top_customer] =  [projctd_dmnd_weekly_buckets].[top_customer]
   GROUP BY 
      [cust_allctn].[item_id]
     ,[cust_allctn].[top_customer]
)
,

  [cte_unfilled_wk5]
 (
    [item_id]
   ,[top_customer]
   ,[unfill_by_cust_wk5]
  )
AS
(
   SELECT
      DISTINCT [cust_allctn].[item_id]
     ,[cust_allctn].[top_customer]
     ,(
      SUM(  [projctd_dmnd_weekly_buckets].[5_wk_out]  )
      -
      SUM( [cust_allctn].[allctn_by_cust_wk5])
      )
   FROM [cust_allctn]
   JOIN  [projctd_dmnd_weekly_buckets]
     ON [cust_allctn].[item_id] =  [projctd_dmnd_weekly_buckets].[item_id]
    AND [cust_allctn].[top_customer] =  [projctd_dmnd_weekly_buckets].[top_customer]
   GROUP BY 
      [cust_allctn].[item_id]
     ,[cust_allctn].[top_customer]
)
,

  [cte_unfilled_wk6]
 (
    [item_id]
   ,[top_customer]
   ,[unfill_by_cust_wk6]
  )
AS
(
   SELECT
      DISTINCT [cust_allctn].[item_id]
     ,[cust_allctn].[top_customer]
     ,(
      SUM(  [projctd_dmnd_weekly_buckets].[6_wk_out]  )
      -
      SUM( [cust_allctn].[allctn_by_cust_wk6])
      )
   FROM [cust_allctn]
   JOIN  [projctd_dmnd_weekly_buckets]
     ON [cust_allctn].[item_id] =  [projctd_dmnd_weekly_buckets].[item_id]
    AND [cust_allctn].[top_customer] =  [projctd_dmnd_weekly_buckets].[top_customer]
   GROUP BY 
      [cust_allctn].[item_id]
     ,[cust_allctn].[top_customer]
)

INSERT INTO [unfilled_by_cust]
  (
   [item_id]
  ,[line_code]
  ,[class_code]
  ,[pop_code]
  ,[top_customer]
  ,[unfill_by_cust_wk1]
  ,[unfill_by_cust_wk2]
  ,[unfill_by_cust_wk3]
  ,[unfill_by_cust_wk4]
  ,[unfill_by_cust_wk5]  
  ,[unfill_by_cust_wk6]  
 )

SELECT 
   [cte_unfilled_wk1].[item_id]
  ,[item_lu].[line_code]
  ,[item_lu].[class_code]
  ,[item_lu].[pop_code]
  ,[cte_unfilled_wk1].[top_customer] 
  ,SUM([cte_unfilled_wk1].[unfill_by_cust_wk1])
  ,SUM([cte_unfilled_wk2].[unfill_by_cust_wk2])
  ,SUM([cte_unfilled_wk3].[unfill_by_cust_wk3])
  ,SUM([cte_unfilled_wk4].[unfill_by_cust_wk4])
  ,SUM([cte_unfilled_wk5].[unfill_by_cust_wk5])
  ,SUM([cte_unfilled_wk6].[unfill_by_cust_wk6])
FROM [cte_unfilled_wk1]
LEFT JOIN [item_lu]
       ON [cte_unfilled_wk1].[item_id] = [item_lu].[item_id]
JOIN [cte_unfilled_wk2]
  ON [cte_unfilled_wk1].[item_id] = [cte_unfilled_wk2].[item_id]
 AND [cte_unfilled_wk1].[top_customer] = [cte_unfilled_wk2].[top_customer]
JOIN [cte_unfilled_wk3]
  ON [cte_unfilled_wk1].[item_id] = [cte_unfilled_wk3].[item_id]
 AND [cte_unfilled_wk1].[top_customer] = [cte_unfilled_wk3].[top_customer]
JOIN [cte_unfilled_wk4]
  ON [cte_unfilled_wk1].[item_id] = [cte_unfilled_wk4].[item_id]
 AND [cte_unfilled_wk1].[top_customer] = [cte_unfilled_wk4].[top_customer]
JOIN [cte_unfilled_wk5]
  ON [cte_unfilled_wk1].[item_id] = [cte_unfilled_wk5].[item_id]
 AND [cte_unfilled_wk1].[top_customer] = [cte_unfilled_wk5].[top_customer]
JOIN [cte_unfilled_wk6]
  ON [cte_unfilled_wk1].[item_id] = [cte_unfilled_wk6].[item_id]
 AND [cte_unfilled_wk1].[top_customer] = [cte_unfilled_wk6].[top_customer]
GROUP BY
   [cte_unfilled_wk1].[item_id]
  ,[item_lu].[line_code]
  ,[item_lu].[class_code]
  ,[item_lu].[pop_code]
  ,[cte_unfilled_wk1].[top_customer] 
  

