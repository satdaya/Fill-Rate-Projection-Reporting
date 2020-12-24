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
       SUM( [dec_4_wk_prjctd_dmnd_dev_v2].[dec_wk_4_dmnd] )
       -
       SUM( [cust_allctn].[allctn_by_cust_wk1] )
       )
   FROM [cust_allctn]
   JOIN [dec_4_wk_prjctd_dmnd_dev_v2]
     ON [cust_allctn].[item_id] = [dec_4_wk_prjctd_dmnd_dev_v2].[item_id]
    AND [cust_allctn].[top_customer] = [dec_4_wk_prjctd_dmnd_dev_v2].[top_customer]
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
      SUM( [dec_4_wk_prjctd_dmnd_dev_v2].[dec_wk_5_dmnd] )
      -
      SUM( [cust_allctn].[allctn_by_cust_wk2] )
      )
   FROM [cust_allctn]
   JOIN [dec_4_wk_prjctd_dmnd_dev_v2]
     ON [cust_allctn].[item_id] = [dec_4_wk_prjctd_dmnd_dev_v2].[item_id]
    AND [cust_allctn].[top_customer] = [dec_4_wk_prjctd_dmnd_dev_v2].[top_customer]
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
      SUM( [dec_4_wk_prjctd_dmnd_dev_v2].[jan_wk_1_dmnd] )
      -
      SUM( [cust_allctn].[allctn_by_cust_wk3] )
      )
   FROM [cust_allctn]
   JOIN [dec_4_wk_prjctd_dmnd_dev_v2]
     ON [cust_allctn].[item_id] = [dec_4_wk_prjctd_dmnd_dev_v2].[item_id]
    AND [cust_allctn].[top_customer] = [dec_4_wk_prjctd_dmnd_dev_v2].[top_customer]
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
      SUM( [dec_4_wk_prjctd_dmnd_dev_v2].[jan_wk_2_dmnd] )
      -
      SUM( [cust_allctn].[allctn_by_cust_wk4] )
      )
   FROM [cust_allctn]
   JOIN [dec_4_wk_prjctd_dmnd_dev_v2]
     ON [cust_allctn].[item_id] = [dec_4_wk_prjctd_dmnd_dev_v2].[item_id]
    AND [cust_allctn].[top_customer] = [dec_4_wk_prjctd_dmnd_dev_v2].[top_customer]
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
FROM [cte_unfilled_wk1]
LEFT JOIN [item_lu]
       ON [cte_unfilled_wk1].[item_id] = [item_lu].[part_number]
JOIN [cte_unfilled_wk2]
  ON [cte_unfilled_wk1].[item_id] = [cte_unfilled_wk2].[item_id]
 AND [cte_unfilled_wk1].[top_customer] = [cte_unfilled_wk2].[top_customer]
JOIN [cte_unfilled_wk3]
  ON [cte_unfilled_wk1].[item_id] = [cte_unfilled_wk3].[item_id]
 AND [cte_unfilled_wk1].[top_customer] = [cte_unfilled_wk3].[top_customer]
JOIN [cte_unfilled_wk4]
  ON [cte_unfilled_wk1].[item_id] = [cte_unfilled_wk4].[item_id]
 AND [cte_unfilled_wk1].[top_customer] = [cte_unfilled_wk4].[top_customer]
GROUP BY
   [cte_unfilled_wk1].[item_id]
  ,[item_lu].[line_code]
  ,[item_lu].[class_code]
  ,[item_lu].[pop_code]
  ,[cte_unfilled_wk1].[top_customer] 
  

