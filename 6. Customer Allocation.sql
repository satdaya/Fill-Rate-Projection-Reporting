DROP TABLE IF EXISTS [cust_allctn];

CREATE TABLE [cust_allctn]
 (
   [item_id]            VARCHAR(54)
  ,[line_code]          VARCHAR(54)
  ,[class_code]         VARCHAR(54)
  ,[pop_code]           VARCHAR(54)
  ,[top_customer]       VARCHAR(54)
  ,[allctn_by_cust_wk1] NUMERIC(10, 2)
  ,[allctn_by_cust_wk2] NUMERIC(10, 2)
  ,[allctn_by_cust_wk3] NUMERIC(10, 2)
  ,[allctn_by_cust_wk4] NUMERIC(10, 2)
  ,[allctn_by_cust_wk5] NUMERIC(10, 2)
  ,[allctn_by_cust_wk6] NUMERIC(10, 2)
  ,PRIMARY KEY ([item_id], [top_customer])
)
;
WITH
  [cte_cust_allctn_wk1]
  (
    [item_id]
   ,[top_customer] 
   ,[allctn_by_cust_wk1]
  )

  AS
  (
   SELECT
     DISTINCT [projctd_dmnd_weekly_buckets].[item_id]
    ,[top_customer]
    ,CASE WHEN 
        SUM([eow_oh_wk1_no_dmnd]) = 0
        THEN 0
        ELSE
            CASE WHEN ( SUM([eow_oh_wk1_no_dmnd])
                          > 
                        SUM([projctd_dmnd_weekly_buckets].[1_wk_out])
                      )
                 THEN  SUM([projctd_dmnd_weekly_buckets].[1_wk_out])
                 WHEN  SUM([eow_oh_wk1_no_dmnd]) = 1
                       AND 
                       SUM([projctd_dmnd_weekly_buckets].[1_wk_out]) = 1
                       AND [projctd_dmnd_weekly_buckets].[top_customer] = 'Parts Authority'
                 THEN 1
                 WHEN  SUM([eow_oh_wk1_no_dmnd]) = 1
                       AND 
                       SUM([projctd_dmnd_weekly_buckets].[1_wk_out]) = 1
                       AND [projctd_dmnd_weekly_buckets].[top_customer] = 'FMP'
                       AND NOT EXISTS
                          (
                           SELECT
                             DISTINCT [projctd_dmnd_weekly_buckets].[item_id]
                            ,[projctd_dmnd_weekly_buckets].[top_customer]
                           FROM [projctd_dmnd_weekly_buckets]    
                           WHERE  [projctd_dmnd_weekly_buckets].[top_customer] = 'Parts Authority'
                          )
                 THEN 1
                 WHEN  SUM([eow_oh_wk1_no_dmnd]) = 1
                       AND 
                       SUM([projctd_dmnd_weekly_buckets].[1_wk_out]) = 1
                       AND [projctd_dmnd_weekly_buckets].[top_customer]  = 'Fast Undercar'
                       AND NOT EXISTS
                          (
                           SELECT
                             DISTINCT [projctd_dmnd_weekly_buckets].[item_id]
                            ,[projctd_dmnd_weekly_buckets].[top_customer]
                           FROM [projctd_dmnd_weekly_buckets]    
                           WHERE  [projctd_dmnd_weekly_buckets].[top_customer] IN ('Parts Authority', 'FMP')
                          )
                 THEN 1
                 WHEN  SUM([eow_oh_wk1_no_dmnd]) = 1
                       AND 
                       SUM([projctd_dmnd_weekly_buckets].[1_wk_out]) = 1
                       AND [projctd_dmnd_weekly_buckets].[top_customer]  = 'XL Parts'
                       AND NOT EXISTS
                          (
                           SELECT
                             DISTINCT [projctd_dmnd_weekly_buckets].[item_id]
                            ,[projctd_dmnd_weekly_buckets].[top_customer]
                           FROM [projctd_dmnd_weekly_buckets]    
                           WHERE  [projctd_dmnd_weekly_buckets].[top_customer] IN ('Parts Authority', 'FMP', 'Fast Undercar')
                          )
                 THEN 1
                 WHEN  SUM([eow_oh_wk1_no_dmnd]) = 1
                       AND 
                       SUM([projctd_dmnd_weekly_buckets].[1_wk_out]) = 1
                       AND [projctd_dmnd_weekly_buckets].[top_customer]  = 'All Other'
                       AND NOT EXISTS
                          (
                           SELECT
                             DISTINCT [projctd_dmnd_weekly_buckets].[item_id]
                            ,[projctd_dmnd_weekly_buckets].[top_customer]
                           FROM [projctd_dmnd_weekly_buckets]    
                           WHERE  [projctd_dmnd_weekly_buckets].[top_customer] IN ('Parts Authority', 'FMP', 'Fast Undercar', 'XL Parts')
                          )
                       
                 THEN 1
                 ELSE  (
                        SUM([eow_oh_wk1_no_dmnd])
                          /
                       SUM( SUM( [projctd_dmnd_weekly_buckets].[1_wk_out] ) ) OVER
                          ( PARTITION BY [projctd_dmnd_weekly_buckets].[item_id], [top_customer] ) )
                 END
        END
    FROM [available_dev_no_dmnd]
    JOIN [projctd_dmnd_weekly_buckets]
      ON [available_dev_no_dmnd].[item_id] = [projctd_dmnd_weekly_buckets].[item_id]
    GROUP BY 
      [projctd_dmnd_weekly_buckets].[item_id]
     ,[projctd_dmnd_weekly_buckets].[top_customer]
   )
,

   [cte_cust_allctn_wk2]
  (
    [item_id]
   ,[top_customer] 
   ,[allctn_by_cust_wk2]
  )


  AS
  ( SELECT
     DISTINCT [projctd_dmnd_weekly_buckets].[item_id]
    ,[top_customer]
    ,CASE WHEN SUM([eow_oh_wk2_no_dmnd]) < 1
          THEN 0
          ELSE
            CASE WHEN ( SUM([eow_oh_wk2_no_dmnd])
                          > 
                        SUM([projctd_dmnd_weekly_buckets].[2_wk_out])
                      )
                 THEN  SUM([projctd_dmnd_weekly_buckets].[2_wk_out])
                 WHEN  SUM([eow_oh_wk1_no_dmnd]) = 1
                       AND 
                       SUM([projctd_dmnd_weekly_buckets].[2_wk_out]) = 1
                       AND [projctd_dmnd_weekly_buckets].[top_customer] = 'Parts Authority'
                 THEN 1
                 WHEN  SUM([eow_oh_wk2_no_dmnd]) = 1
                       AND 
                       SUM([projctd_dmnd_weekly_buckets].[2_wk_out]) = 1
                       AND [projctd_dmnd_weekly_buckets].[top_customer] = 'FMP'
                       AND NOT EXISTS
                          (
                           SELECT
                             DISTINCT [projctd_dmnd_weekly_buckets].[item_id]
                            ,[projctd_dmnd_weekly_buckets].[top_customer]
                           FROM [projctd_dmnd_weekly_buckets]    
                           WHERE  [projctd_dmnd_weekly_buckets].[top_customer] = 'Parts Authority'
                          )
                 THEN 1
                 WHEN  SUM([eow_oh_wk2_no_dmnd]) = 1
                       AND 
                       SUM([projctd_dmnd_weekly_buckets].[2_wk_out]) = 1
                       AND [projctd_dmnd_weekly_buckets].[top_customer]  = 'Fast Undercar'
                       AND NOT EXISTS
                          (
                           SELECT
                             DISTINCT [projctd_dmnd_weekly_buckets].[item_id]
                            ,[projctd_dmnd_weekly_buckets].[top_customer]
                           FROM [projctd_dmnd_weekly_buckets]    
                           WHERE  [projctd_dmnd_weekly_buckets].[top_customer] IN ('Parts Authority', 'FMP')
                          )
                 THEN 1
                 WHEN  SUM([eow_oh_wk2_no_dmnd]) = 1
                       AND 
                       SUM([projctd_dmnd_weekly_buckets].[2_wk_out]) = 1
                       AND [projctd_dmnd_weekly_buckets].[top_customer]  = 'XL Parts'
                       AND NOT EXISTS
                          (
                           SELECT
                             DISTINCT [projctd_dmnd_weekly_buckets].[item_id]
                            ,[projctd_dmnd_weekly_buckets].[top_customer]
                           FROM [projctd_dmnd_weekly_buckets]    
                           WHERE  [projctd_dmnd_weekly_buckets].[top_customer] IN ('Parts Authority', 'FMP', 'Fast Undercar')
                          )
                 THEN 1
                 WHEN  SUM([eow_oh_wk2_no_dmnd]) = 1
                       AND 
                       SUM([projctd_dmnd_weekly_buckets].[2_wk_out]) = 1
                       AND [projctd_dmnd_weekly_buckets].[top_customer]  = 'All Other'
                       AND NOT EXISTS
                          (
                           SELECT
                             DISTINCT [projctd_dmnd_weekly_buckets].[item_id]
                            ,[projctd_dmnd_weekly_buckets].[top_customer]
                           FROM [projctd_dmnd_weekly_buckets]    
                           WHERE  [projctd_dmnd_weekly_buckets].[top_customer] IN ('Parts Authority', 'FMP', 'Fast Undercar', 'XL Parts')
                          )
                       
                 THEN 1
                 ELSE  (
                        SUM([eow_oh_wk2_no_dmnd])
                          /
                       SUM( SUM( [projctd_dmnd_weekly_buckets].[2_wk_out] ) ) OVER
                          ( PARTITION BY [projctd_dmnd_weekly_buckets].[item_id], [top_customer] ) )
                 END
        END
    FROM [available_dev_no_dmnd]
    JOIN [projctd_dmnd_weekly_buckets]
      ON [available_dev_no_dmnd].[item_id] = [projctd_dmnd_weekly_buckets].[item_id]
    GROUP BY 
      [projctd_dmnd_weekly_buckets].[item_id]
     ,[projctd_dmnd_weekly_buckets].[top_customer]
)
,

   [cte_cust_allctn_wk3]
  (
    [item_id]
   ,[top_customer] 
   ,[allctn_by_cust_wk3]
  )

  AS
  (
   SELECT
     DISTINCT [projctd_dmnd_weekly_buckets].[item_id]
    ,[top_customer]
    ,CASE WHEN SUM([eow_oh_wk3_no_dmnd]) < 1
          THEN 0
          ELSE
            CASE WHEN ( SUM([eow_oh_wk3_no_dmnd])
                          > 
                        SUM([projctd_dmnd_weekly_buckets].[3_wk_out])
                      )
                 THEN  SUM([projctd_dmnd_weekly_buckets].[3_wk_out])
                 WHEN  SUM([eow_oh_wk3_no_dmnd]) = 1
                       AND 
                       SUM([projctd_dmnd_weekly_buckets].[3_wk_out]) = 1
                       AND [projctd_dmnd_weekly_buckets].[top_customer] = 'Parts Authority'
                 THEN 1
                 WHEN  SUM([eow_oh_wk3_no_dmnd]) = 1
                       AND 
                       SUM([projctd_dmnd_weekly_buckets].[3_wk_out]) = 1
                       AND [projctd_dmnd_weekly_buckets].[top_customer] = 'FMP'
                       AND NOT EXISTS
                          (
                           SELECT
                             DISTINCT [projctd_dmnd_weekly_buckets].[item_id]
                            ,[projctd_dmnd_weekly_buckets].[top_customer]
                           FROM [projctd_dmnd_weekly_buckets]    
                           WHERE  [projctd_dmnd_weekly_buckets].[top_customer] = 'Parts Authority'
                          )
                 THEN 1
                 WHEN  SUM([eow_oh_wk3_no_dmnd]) = 1
                       AND 
                       SUM([projctd_dmnd_weekly_buckets].[3_wk_out]) = 1
                       AND [projctd_dmnd_weekly_buckets].[top_customer]  = 'Fast Undercar'
                       AND NOT EXISTS
                          (
                           SELECT
                             DISTINCT [projctd_dmnd_weekly_buckets].[item_id]
                            ,[projctd_dmnd_weekly_buckets].[top_customer]
                           FROM [projctd_dmnd_weekly_buckets]    
                           WHERE  [projctd_dmnd_weekly_buckets].[top_customer] IN ('Parts Authority', 'FMP')
                          )
                 THEN 1
                 WHEN  SUM([eow_oh_wk3_no_dmnd]) = 1
                       AND 
                       SUM([projctd_dmnd_weekly_buckets].[3_wk_out]) = 1
                       AND [projctd_dmnd_weekly_buckets].[top_customer]  = 'XL Parts'
                       AND NOT EXISTS
                          (
                           SELECT
                             DISTINCT [projctd_dmnd_weekly_buckets].[item_id]
                            ,[projctd_dmnd_weekly_buckets].[top_customer]
                           FROM [projctd_dmnd_weekly_buckets]    
                           WHERE  [projctd_dmnd_weekly_buckets].[top_customer] IN ('Parts Authority', 'FMP', 'Fast Undercar')
                          )
                 THEN 1
                 WHEN  SUM([eow_oh_wk3_no_dmnd]) = 1
                       AND 
                       SUM([projctd_dmnd_weekly_buckets].[3_wk_out]) = 1
                       AND [projctd_dmnd_weekly_buckets].[top_customer]  = 'All Other'
                       AND NOT EXISTS
                          (
                           SELECT
                             DISTINCT [projctd_dmnd_weekly_buckets].[item_id]
                            ,[projctd_dmnd_weekly_buckets].[top_customer]
                           FROM [projctd_dmnd_weekly_buckets]    
                           WHERE  [projctd_dmnd_weekly_buckets].[top_customer] IN ('Parts Authority', 'FMP', 'Fast Undercar', 'XL Parts')
                          )
                       
                 THEN 1
                 ELSE  (
                        SUM([eow_oh_wk3_no_dmnd])
                          /
                       SUM( SUM( [projctd_dmnd_weekly_buckets].[3_wk_out] ) ) OVER
                          ( PARTITION BY [projctd_dmnd_weekly_buckets].[item_id], [top_customer] ) )
                 END
        END
    FROM [available_dev_no_dmnd]
    JOIN [projctd_dmnd_weekly_buckets]
      ON [available_dev_no_dmnd].[item_id] = [projctd_dmnd_weekly_buckets].[item_id]
    GROUP BY 
      [projctd_dmnd_weekly_buckets].[item_id]
     ,[projctd_dmnd_weekly_buckets].[top_customer]
   )
,

   [cte_cust_allctn_wk4]
  (
    [item_id]
   ,[top_customer] 
   ,[allctn_by_cust_wk4]
  )


  AS
  (
   SELECT
     DISTINCT [projctd_dmnd_weekly_buckets].[item_id]
    ,[top_customer]
    ,CASE WHEN SUM([eow_oh_wk4_no_dmnd]) < 1
          THEN 0
          ELSE
            CASE WHEN ( SUM([eow_oh_wk4_no_dmnd])
                          > 
                        SUM([projctd_dmnd_weekly_buckets].[4_wk_out])
                      )
                 THEN  SUM([projctd_dmnd_weekly_buckets].[4_wk_out])
                 WHEN  SUM([eow_oh_wk4_no_dmnd]) = 1
                       AND 
                       SUM([projctd_dmnd_weekly_buckets].[4_wk_out]) = 1
                       AND [projctd_dmnd_weekly_buckets].[top_customer] = 'Parts Authority'
                 THEN 1
                 WHEN  SUM([eow_oh_wk4_no_dmnd]) = 1
                       AND 
                       SUM([projctd_dmnd_weekly_buckets].[4_wk_out]) = 1
                       AND [projctd_dmnd_weekly_buckets].[top_customer] = 'FMP'
                       AND NOT EXISTS
                          (
                           SELECT
                             DISTINCT [projctd_dmnd_weekly_buckets].[item_id]
                            ,[projctd_dmnd_weekly_buckets].[top_customer]
                           FROM [projctd_dmnd_weekly_buckets]    
                           WHERE  [projctd_dmnd_weekly_buckets].[top_customer] = 'Parts Authority'
                          )
                 THEN 1
                 WHEN  SUM([eow_oh_wk4_no_dmnd]) = 1
                       AND 
                       SUM([projctd_dmnd_weekly_buckets].[4_wk_out]) = 1
                       AND [projctd_dmnd_weekly_buckets].[top_customer]  = 'Fast Undercar'
                       AND NOT EXISTS
                          (
                           SELECT
                             DISTINCT [projctd_dmnd_weekly_buckets].[item_id]
                            ,[projctd_dmnd_weekly_buckets].[top_customer]
                           FROM [projctd_dmnd_weekly_buckets]    
                           WHERE  [projctd_dmnd_weekly_buckets].[top_customer] IN ('Parts Authority', 'FMP')
                          )
                 THEN 1
                 WHEN  SUM([eow_oh_wk4_no_dmnd]) = 1
                       AND 
                       SUM([projctd_dmnd_weekly_buckets].[4_wk_out]) = 1
                       AND [projctd_dmnd_weekly_buckets].[top_customer]  = 'XL Parts'
                       AND NOT EXISTS
                          (
                           SELECT
                             DISTINCT [projctd_dmnd_weekly_buckets].[item_id]
                            ,[projctd_dmnd_weekly_buckets].[top_customer]
                           FROM [projctd_dmnd_weekly_buckets]    
                           WHERE  [projctd_dmnd_weekly_buckets].[top_customer] IN ('Parts Authority', 'FMP', 'Fast Undercar')
                          )
                 THEN 1
                 WHEN  SUM([eow_oh_wk4_no_dmnd]) = 1
                       AND 
                       SUM([projctd_dmnd_weekly_buckets].[4_wk_out]) = 1
                       AND [projctd_dmnd_weekly_buckets].[top_customer]  = 'All Other'
                       AND NOT EXISTS
                          (
                           SELECT
                             DISTINCT [projctd_dmnd_weekly_buckets].[item_id]
                            ,[projctd_dmnd_weekly_buckets].[top_customer]
                           FROM [projctd_dmnd_weekly_buckets]    
                           WHERE  [projctd_dmnd_weekly_buckets].[top_customer] IN ('Parts Authority', 'FMP', 'Fast Undercar', 'XL Parts')
                          )
                       
                 THEN 1
                 ELSE  (
                        SUM([eow_oh_wk4_no_dmnd])
                          /
                       SUM( SUM( [projctd_dmnd_weekly_buckets].[4_wk_out] ) ) OVER
                          ( PARTITION BY [projctd_dmnd_weekly_buckets].[item_id], [top_customer] ) )
                 END
        END
    FROM [available_dev_no_dmnd]
    JOIN [projctd_dmnd_weekly_buckets]
      ON [available_dev_no_dmnd].[item_id] = [projctd_dmnd_weekly_buckets].[item_id]
    GROUP BY 
      [projctd_dmnd_weekly_buckets].[item_id]
     ,[projctd_dmnd_weekly_buckets].[top_customer]
   ),

   [cte_cust_allctn_wk5]
  (
    [item_id]
   ,[top_customer] 
   ,[allctn_by_cust_wk5]
  )


  AS
  ( SELECT
     DISTINCT [projctd_dmnd_weekly_buckets].[item_id]
    ,[top_customer]
    ,CASE WHEN SUM([eow_oh_wk5_no_dmnd]) < 1
          THEN 0
          ELSE
            CASE WHEN ( SUM([eow_oh_wk5_no_dmnd])
                          > 
                        SUM([projctd_dmnd_weekly_buckets].[5_wk_out])
                      )
                 THEN  SUM([projctd_dmnd_weekly_buckets].[5_wk_out])
                 WHEN  SUM([eow_oh_wk1_no_dmnd]) = 1
                       AND 
                       SUM([projctd_dmnd_weekly_buckets].[5_wk_out]) = 1
                       AND [projctd_dmnd_weekly_buckets].[top_customer] = 'Parts Authority'
                 THEN 1
                 WHEN  SUM([eow_oh_wk5_no_dmnd]) = 1
                       AND 
                       SUM([projctd_dmnd_weekly_buckets].[5_wk_out]) = 1
                       AND [projctd_dmnd_weekly_buckets].[top_customer] = 'FMP'
                       AND NOT EXISTS
                          (
                           SELECT
                             DISTINCT [projctd_dmnd_weekly_buckets].[item_id]
                            ,[projctd_dmnd_weekly_buckets].[top_customer]
                           FROM [projctd_dmnd_weekly_buckets]    
                           WHERE  [projctd_dmnd_weekly_buckets].[top_customer] = 'Parts Authority'
                          )
                 THEN 1
                 WHEN  SUM([eow_oh_wk5_no_dmnd]) = 1
                       AND 
                       SUM([projctd_dmnd_weekly_buckets].[5_wk_out]) = 1
                       AND [projctd_dmnd_weekly_buckets].[top_customer]  = 'Fast Undercar'
                       AND NOT EXISTS
                          (
                           SELECT
                             DISTINCT [projctd_dmnd_weekly_buckets].[item_id]
                            ,[projctd_dmnd_weekly_buckets].[top_customer]
                           FROM [projctd_dmnd_weekly_buckets]    
                           WHERE  [projctd_dmnd_weekly_buckets].[top_customer] IN ('Parts Authority', 'FMP')
                          )
                 THEN 1
                 WHEN  SUM([eow_oh_wk5_no_dmnd]) = 1
                       AND 
                       SUM([projctd_dmnd_weekly_buckets].[5_wk_out]) = 1
                       AND [projctd_dmnd_weekly_buckets].[top_customer]  = 'XL Parts'
                       AND NOT EXISTS
                          (
                           SELECT
                             DISTINCT [projctd_dmnd_weekly_buckets].[item_id]
                            ,[projctd_dmnd_weekly_buckets].[top_customer]
                           FROM [projctd_dmnd_weekly_buckets]    
                           WHERE  [projctd_dmnd_weekly_buckets].[top_customer] IN ('Parts Authority', 'FMP', 'Fast Undercar')
                          )
                 THEN 1
                 WHEN  SUM([eow_oh_wk5_no_dmnd]) = 1
                       AND 
                       SUM([projctd_dmnd_weekly_buckets].[5_wk_out]) = 1
                       AND [projctd_dmnd_weekly_buckets].[top_customer]  = 'All Other'
                       AND NOT EXISTS
                          (
                           SELECT
                             DISTINCT [projctd_dmnd_weekly_buckets].[item_id]
                            ,[projctd_dmnd_weekly_buckets].[top_customer]
                           FROM [projctd_dmnd_weekly_buckets]    
                           WHERE  [projctd_dmnd_weekly_buckets].[top_customer] IN ('Parts Authority', 'FMP', 'Fast Undercar', 'XL Parts')
                          )
                       
                 THEN 1
                 ELSE  (
                        SUM([eow_oh_wk5_no_dmnd])
                          /
                       SUM( SUM( [projctd_dmnd_weekly_buckets].[5_wk_out] ) ) OVER
                          ( PARTITION BY [projctd_dmnd_weekly_buckets].[item_id], [top_customer] ) )
                 END
        END
    FROM [available_dev_no_dmnd]
    JOIN [projctd_dmnd_weekly_buckets]
      ON [available_dev_no_dmnd].[item_id] = [projctd_dmnd_weekly_buckets].[item_id]
    GROUP BY 
      [projctd_dmnd_weekly_buckets].[item_id]
     ,[projctd_dmnd_weekly_buckets].[top_customer]
    )
,

   [cte_cust_allctn_wk6]
  (
    [item_id]
   ,[top_customer] 
   ,[allctn_by_cust_wk6]
  )


  AS
  ( SELECT
     DISTINCT [projctd_dmnd_weekly_buckets].[item_id]
    ,[top_customer]
    ,CASE WHEN SUM([eow_oh_wk6_no_dmnd]) < 1
          THEN 0
          ELSE
            CASE WHEN ( SUM([eow_oh_wk6_no_dmnd])
                          > 
                        SUM([projctd_dmnd_weekly_buckets].[6_wk_out])
                      )
                 THEN  SUM([projctd_dmnd_weekly_buckets].[6_wk_out])
                 WHEN  SUM([eow_oh_wk1_no_dmnd]) = 1
                       AND 
                       SUM([projctd_dmnd_weekly_buckets].[6_wk_out]) = 1
                       AND [projctd_dmnd_weekly_buckets].[top_customer] = 'Parts Authority'
                 THEN 1
                 WHEN  SUM([eow_oh_wk6_no_dmnd]) = 1
                       AND 
                       SUM([projctd_dmnd_weekly_buckets].[6_wk_out]) = 1
                       AND [projctd_dmnd_weekly_buckets].[top_customer] = 'FMP'
                       AND NOT EXISTS
                          (
                           SELECT
                             DISTINCT [projctd_dmnd_weekly_buckets].[item_id]
                            ,[projctd_dmnd_weekly_buckets].[top_customer]
                           FROM [projctd_dmnd_weekly_buckets]    
                           WHERE  [projctd_dmnd_weekly_buckets].[top_customer] = 'Parts Authority'
                          )
                 THEN 1
                 WHEN  SUM([eow_oh_wk6_no_dmnd]) = 1
                       AND 
                       SUM([projctd_dmnd_weekly_buckets].[6_wk_out]) = 1
                       AND [projctd_dmnd_weekly_buckets].[top_customer]  = 'Fast Undercar'
                       AND NOT EXISTS
                          (
                           SELECT
                             DISTINCT [projctd_dmnd_weekly_buckets].[item_id]
                            ,[projctd_dmnd_weekly_buckets].[top_customer]
                           FROM [projctd_dmnd_weekly_buckets]    
                           WHERE  [projctd_dmnd_weekly_buckets].[top_customer] IN ('Parts Authority', 'FMP')
                          )
                 THEN 1
                 WHEN  SUM([eow_oh_wk6_no_dmnd]) = 1
                       AND 
                       SUM([projctd_dmnd_weekly_buckets].[6_wk_out]) = 1
                       AND [projctd_dmnd_weekly_buckets].[top_customer]  = 'XL Parts'
                       AND NOT EXISTS
                          (
                           SELECT
                             DISTINCT [projctd_dmnd_weekly_buckets].[item_id]
                            ,[projctd_dmnd_weekly_buckets].[top_customer]
                           FROM [projctd_dmnd_weekly_buckets]    
                           WHERE  [projctd_dmnd_weekly_buckets].[top_customer] IN ('Parts Authority', 'FMP', 'Fast Undercar')
                          )
                 THEN 1
                 WHEN  SUM([eow_oh_wk6_no_dmnd]) = 1
                       AND 
                       SUM([projctd_dmnd_weekly_buckets].[6_wk_out]) = 1
                       AND [projctd_dmnd_weekly_buckets].[top_customer]  = 'All Other'
                       AND NOT EXISTS
                          (
                           SELECT
                             DISTINCT [projctd_dmnd_weekly_buckets].[item_id]
                            ,[projctd_dmnd_weekly_buckets].[top_customer]
                           FROM [projctd_dmnd_weekly_buckets]    
                           WHERE  [projctd_dmnd_weekly_buckets].[top_customer] IN ('Parts Authority', 'FMP', 'Fast Undercar', 'XL Parts')
                          )
                       
                 THEN 1
                 ELSE  (
                        SUM([eow_oh_wk6_no_dmnd])
                          /
                       SUM( SUM( [projctd_dmnd_weekly_buckets].[6_wk_out] ) ) OVER
                          ( PARTITION BY [projctd_dmnd_weekly_buckets].[item_id], [top_customer] ) )
                 END
        END
    FROM [available_dev_no_dmnd]
    JOIN [projctd_dmnd_weekly_buckets]
      ON [available_dev_no_dmnd].[item_id] = [projctd_dmnd_weekly_buckets].[item_id]
    GROUP BY 
      [projctd_dmnd_weekly_buckets].[item_id]
     ,[projctd_dmnd_weekly_buckets].[top_customer]
)

 INSERT INTO [cust_allctn]
  (
   [item_id]
  ,[line_code]
  ,[class_code]
  ,[pop_code]
  ,[top_customer]
  ,[allctn_by_cust_wk1]
  ,[allctn_by_cust_wk2]
  ,[allctn_by_cust_wk3]
  ,[allctn_by_cust_wk4]
  ,[allctn_by_cust_wk5]
  ,[allctn_by_cust_wk6]
)

SELECT
   [cte_cust_allctn_wk1].[item_id] 
  ,[item_lu].[line_code]
  ,[item_lu].[class_code]
  ,[item_lu].[pop_code]
  ,[cte_cust_allctn_wk1].[top_customer] 
  ,SUM([cte_cust_allctn_wk1].[allctn_by_cust_wk1])
  ,SUM([cte_cust_allctn_wk2].[allctn_by_cust_wk2])
  ,SUM([cte_cust_allctn_wk3].[allctn_by_cust_wk3])
  ,SUM([cte_cust_allctn_wk4].[allctn_by_cust_wk4])
  ,SUM([cte_cust_allctn_wk5].[allctn_by_cust_wk5])
  ,SUM([cte_cust_allctn_wk6].[allctn_by_cust_wk6])
FROM [cte_cust_allctn_wk1]
LEFT JOIN [item_lu]
       ON [cte_cust_allctn_wk1].[item_id] = [item_lu].[item_id]
JOIN [cte_cust_allctn_wk2]
  ON [cte_cust_allctn_wk1].[item_id] = [cte_cust_allctn_wk2].[item_id]
 AND [cte_cust_allctn_wk1].[top_customer] = [cte_cust_allctn_wk2].[top_customer]
JOIN [cte_cust_allctn_wk3]
  ON [cte_cust_allctn_wk1].[item_id] = [cte_cust_allctn_wk3].[item_id]
 AND [cte_cust_allctn_wk1].[top_customer] = [cte_cust_allctn_wk3].[top_customer]
JOIN [cte_cust_allctn_wk4]
  ON [cte_cust_allctn_wk1].[item_id] = [cte_cust_allctn_wk4].[item_id]
 AND [cte_cust_allctn_wk1].[top_customer] = [cte_cust_allctn_wk4].[top_customer]
JOIN [cte_cust_allctn_wk5]
  ON [cte_cust_allctn_wk1].[item_id] = [cte_cust_allctn_wk5].[item_id]
 AND [cte_cust_allctn_wk1].[top_customer] = [cte_cust_allctn_wk5].[top_customer]
JOIN [cte_cust_allctn_wk6]
  ON [cte_cust_allctn_wk1].[item_id] = [cte_cust_allctn_wk6].[item_id]
 AND [cte_cust_allctn_wk1].[top_customer] = [cte_cust_allctn_wk6].[top_customer]
GROUP BY
   [cte_cust_allctn_wk1].[item_id] 
  ,[item_lu].[line_code]
  ,[item_lu].[class_code]
  ,[item_lu].[pop_code]
  ,[cte_cust_allctn_wk1].[top_customer] 
