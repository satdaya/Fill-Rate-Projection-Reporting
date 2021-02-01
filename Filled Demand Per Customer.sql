DROP TABLE IF EXISTS [fill_rate_proj_1_31_21];

CREATE TABLE [fill_rate_proj_1_31_21]
  (
   [top_customer]  VARCHAR(54)
  ,[line_code]     VARCHAR(54)
  ,[wk1_fill_rate] FLOAT
  ,[wk2_fill_rate] FLOAT
  ,[wk3_fill_rate] FLOAT
  ,[wk4_fill_rate] FLOAT
  ,[wk5_fill_rate] FLOAT
  ,[wk6_fill_rate] FLOAT
  )

INSERT INTO [fill_rate_proj_1_31_21]
  (
   [top_customer]
  ,[line_code]     
  ,[wk1_fill_rate] 
  ,[wk2_fill_rate] 
  ,[wk3_fill_rate] 
  ,[wk4_fill_rate] 
  ,[wk5_fill_rate] 
  ,[wk6_fill_rate] 
  )

SELECT
    DISTINCT [cust_allctn].[top_customer]
   ,CASE WHEN [cust_allctn].[line_code] = 'DRR'
         THEN 'DRR'
         WHEN [cust_allctn].[line_code] = 'FRC'
         THEN 'FRC'
         WHEN [cust_allctn].[line_code] = 'CAL'
         THEN 'CAL'
         WHEN [cust_allctn].[line_code] = 'CHY'
         THEN 'CHY'
         WHEN [cust_allctn].[line_code] = 'HYD'
         THEN 'HYD'
         WHEN [cust_allctn].[line_code] = 'SAS'
         THEN 'SAS'
         ELSE 'All Other'
         END
   ,CASE WHEN
       
         (
           SUM([cust_allctn].[allctn_by_cust_wk1])
           +
           SUM([unfilled_by_cust].[unfill_by_cust_wk1])
         )

        = 0 
       THEN 0
       ELSE
       ( 
         SUM([cust_allctn].[allctn_by_cust_wk1])
         /
         (
           SUM([cust_allctn].[allctn_by_cust_wk1])
           +
           SUM([unfilled_by_cust].[unfill_by_cust_wk1])
         )
       )
       END
       AS [wk1_fill_rate]
   ,CASE WHEN
       
         (
           SUM([cust_allctn].[allctn_by_cust_wk2])
           +
           SUM([unfilled_by_cust].[unfill_by_cust_wk2])
         )

        = 0 
       THEN 0
       ELSE
       ( 
         SUM([cust_allctn].[allctn_by_cust_wk2])
         /
         (
           SUM([cust_allctn].[allctn_by_cust_wk2])
           +
           SUM([unfilled_by_cust].[unfill_by_cust_wk2])
         )
       )
       END
       AS [wk2_fill_rate]
   ,CASE WHEN
       
         (
           SUM([cust_allctn].[allctn_by_cust_wk3])
           +
           SUM([unfilled_by_cust].[unfill_by_cust_wk3])
         )

        = 0 
       THEN 0
       ELSE
       ( 
         SUM([cust_allctn].[allctn_by_cust_wk3])
         /
         (
           SUM([cust_allctn].[allctn_by_cust_wk3])
           +
           SUM([unfilled_by_cust].[unfill_by_cust_wk3])
         )
       )
       END
       AS [wk3_fill_rate]
   ,CASE WHEN
       
         (
           SUM([cust_allctn].[allctn_by_cust_wk4])
           +
           SUM([unfilled_by_cust].[unfill_by_cust_wk4])
         )

        = 0 
       THEN 0
       ELSE
       ( 
         SUM([cust_allctn].[allctn_by_cust_wk4])
         /
         (
           SUM([cust_allctn].[allctn_by_cust_wk4])
           +
           SUM([unfilled_by_cust].[unfill_by_cust_wk4])
         )
       )
       END
       AS [wk4_fill_rate]
   ,CASE WHEN
       
         (
           SUM([cust_allctn].[allctn_by_cust_wk5])
           +
           SUM([unfilled_by_cust].[unfill_by_cust_wk5])
         )

        = 0 
       THEN 0
       ELSE
       ( 
         SUM([cust_allctn].[allctn_by_cust_wk5])
         /
         (
           SUM([cust_allctn].[allctn_by_cust_wk5])
           +
           SUM([unfilled_by_cust].[unfill_by_cust_wk5])
         )
       )
       END
       AS [wk5_fill_rate]
   ,CASE WHEN
       
         (
           SUM([cust_allctn].[allctn_by_cust_wk6])
           +
           SUM([unfilled_by_cust].[unfill_by_cust_wk6])
         )

        = 0 
       THEN 0
       ELSE
       ( 
         SUM([cust_allctn].[allctn_by_cust_wk6])
         /
         (
           SUM([cust_allctn].[allctn_by_cust_wk6])
           +
           SUM([unfilled_by_cust].[unfill_by_cust_wk6])
         )
       )
       END
       AS [wk6_fill_rate]
  FROM [cust_allctn]
  JOIN [unfilled_by_cust]
    ON [cust_allctn].[item_id] = [unfilled_by_cust].[item_id]
   AND [cust_allctn].[top_customer] = [unfilled_by_cust].[top_customer]
  --WHERE [cust_allctn].[item_id]  = '121.44158'
  GROUP BY
    [cust_allctn].[top_customer]
   ,CASE WHEN [cust_allctn].[line_code] = 'DRR'
         THEN 'DRR'
         WHEN [cust_allctn].[line_code] = 'FRC'
         THEN 'FRC'
         WHEN [cust_allctn].[line_code] = 'CAL'
         THEN 'CAL'
         WHEN [cust_allctn].[line_code] = 'CHY'
         THEN 'CHY'
         WHEN [cust_allctn].[line_code] = 'HYD'
         THEN 'HYD'
         WHEN [cust_allctn].[line_code] = 'SAS'
         THEN 'SAS'
         ELSE 'All Other'
         END
  ORDER BY
    [cust_allctn].[top_customer]
