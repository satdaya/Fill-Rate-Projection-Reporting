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
     DISTINCT [dec_4_wk_prjctd_dmnd_dev_v2].[item_id]
    ,[top_customer]
    ,CASE WHEN 
        (
        SUM( SUM([eow_oh_wk1]) ) OVER
        ( PARTITION BY [dec_4_wk_prjctd_dmnd_dev_v2].[item_id], [top_customer] ) 
        = 0 )
        OR
        (
        SUM( SUM([eow_oh_wk1]) ) OVER
           ( PARTITION BY [dec_4_wk_prjctd_dmnd_dev_v2].[item_id])
        = 0 
        )
        THEN 0
        ELSE
            CASE WHEN ( SUM([eow_oh_wk1])
                          > 
                        SUM([dec_wk_4_dmnd])
                      )
                 THEN   SUM( SUM( [dec_wk_4_dmnd] ) ) OVER
                          ( PARTITION BY [dec_4_wk_prjctd_dmnd_dev_v2].[item_id], [top_customer] )
                 ELSE  (
                        SUM( SUM([eow_oh_wk1]) ) OVER
                          ( PARTITION BY [dec_4_wk_prjctd_dmnd_dev_v2].[item_id] )
                          /
                       SUM( SUM( [dec_wk_4_dmnd] ) ) OVER
                          ( PARTITION BY [dec_4_wk_prjctd_dmnd_dev_v2].[item_id], [top_customer] ) )
                 END
        END
    FROM [available_dev]
    JOIN [dec_4_wk_prjctd_dmnd_dev_v2]
      ON [available_dev].[item_id] = [dec_4_wk_prjctd_dmnd_dev_v2].[item_id]
    GROUP BY 
      [dec_4_wk_prjctd_dmnd_dev_v2].[item_id]
     ,[dec_4_wk_prjctd_dmnd_dev_v2].[top_customer]
   )
,

   [cte_cust_allctn_wk2]
  (
    [item_id]
   ,[top_customer] 
   ,[allctn_by_cust_wk2]
  )


  AS
  (
   SELECT
     DISTINCT [dec_4_wk_prjctd_dmnd_dev_v2].[item_id]
    ,[top_customer]
    ,CASE WHEN 
        (
        SUM( SUM([eow_oh_wk2]) ) OVER
        ( PARTITION BY [dec_4_wk_prjctd_dmnd_dev_v2].[item_id], [top_customer] ) 
        = 0 )
        OR
        (
        SUM( SUM([eow_oh_wk2]) ) OVER
           ( PARTITION BY [dec_4_wk_prjctd_dmnd_dev_v2].[item_id])
        = 0 
        )
        THEN 0
        ELSE
            CASE WHEN ( SUM([eow_oh_wk2])
                          > 
                        SUM([dec_wk_5_dmnd])
                      )
                 THEN   SUM( SUM( [dec_wk_5_dmnd] ) ) OVER
                          ( PARTITION BY [dec_4_wk_prjctd_dmnd_dev_v2].[item_id], [top_customer] )
                 ELSE  (
                        SUM( SUM([eow_oh_wk2]) ) OVER
                          ( PARTITION BY [dec_4_wk_prjctd_dmnd_dev_v2].[item_id] )
                          /
                       SUM( SUM( [dec_wk_5_dmnd] ) ) OVER
                          ( PARTITION BY [dec_4_wk_prjctd_dmnd_dev_v2].[item_id], [top_customer] ) )
                 END
        END
    FROM [available_dev]
    JOIN [dec_4_wk_prjctd_dmnd_dev_v2]
      ON [available_dev].[item_id] = [dec_4_wk_prjctd_dmnd_dev_v2].[item_id]
    GROUP BY 
      [dec_4_wk_prjctd_dmnd_dev_v2].[item_id]
     ,[dec_4_wk_prjctd_dmnd_dev_v2].[top_customer]
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
     DISTINCT [dec_4_wk_prjctd_dmnd_dev_v2].[item_id]
    ,[top_customer]
    ,CASE WHEN 
        (
        SUM( SUM([eow_oh_wk3]) ) OVER
        ( PARTITION BY [dec_4_wk_prjctd_dmnd_dev_v2].[item_id], [top_customer] ) 
        = 0 )
        OR
        (
        SUM( SUM([eow_oh_wk3]) ) OVER
           ( PARTITION BY [dec_4_wk_prjctd_dmnd_dev_v2].[item_id])
        = 0 
        )
        THEN 0
        ELSE
            CASE WHEN ( SUM([eow_oh_wk3])
                          > 
                        SUM([jan_wk_1_dmnd])
                      )
                 THEN   SUM( SUM( [jan_wk_1_dmnd] ) ) OVER
                          ( PARTITION BY [dec_4_wk_prjctd_dmnd_dev_v2].[item_id], [top_customer] )
                 ELSE  (
                        SUM( SUM([eow_oh_wk3]) ) OVER
                          ( PARTITION BY [dec_4_wk_prjctd_dmnd_dev_v2].[item_id] )
                          /
                       SUM( SUM( [jan_wk_1_dmnd] ) ) OVER
                          ( PARTITION BY [dec_4_wk_prjctd_dmnd_dev_v2].[item_id], [top_customer] ) )
                 END
        END
    FROM [available_dev]
    JOIN [dec_4_wk_prjctd_dmnd_dev_v2]
      ON [available_dev].[item_id] = [dec_4_wk_prjctd_dmnd_dev_v2].[item_id]
    GROUP BY 
      [dec_4_wk_prjctd_dmnd_dev_v2].[item_id]
     ,[dec_4_wk_prjctd_dmnd_dev_v2].[top_customer]
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
     DISTINCT [dec_4_wk_prjctd_dmnd_dev_v2].[item_id]
    ,[top_customer]
    ,CASE WHEN 
        (
        SUM( SUM([eow_oh_wk4]) ) OVER
        ( PARTITION BY [dec_4_wk_prjctd_dmnd_dev_v2].[item_id], [top_customer] ) 
        = 0 )
        OR
        (
        SUM( SUM([eow_oh_wk4]) ) OVER
           ( PARTITION BY [dec_4_wk_prjctd_dmnd_dev_v2].[item_id])
        = 0 
        )
        THEN 0
        ELSE
            CASE WHEN ( SUM([eow_oh_wk4])
                          > 
                        SUM([jan_wk_2_dmnd])
                      )
                 THEN   SUM( SUM( [jan_wk_2_dmnd] ) ) OVER
                          ( PARTITION BY [dec_4_wk_prjctd_dmnd_dev_v2].[item_id], [top_customer] )
                 ELSE  (
                        SUM( SUM([eow_oh_wk4]) ) OVER
                          ( PARTITION BY [dec_4_wk_prjctd_dmnd_dev_v2].[item_id] )
                          /
                       SUM( SUM( [jan_wk_2_dmnd] ) ) OVER
                          ( PARTITION BY [dec_4_wk_prjctd_dmnd_dev_v2].[item_id], [top_customer] ) )
                 END
        END
    FROM [available_dev]
    JOIN [dec_4_wk_prjctd_dmnd_dev_v2]
      ON [available_dev].[item_id] = [dec_4_wk_prjctd_dmnd_dev_v2].[item_id]
    GROUP BY 
      [dec_4_wk_prjctd_dmnd_dev_v2].[item_id]
     ,[dec_4_wk_prjctd_dmnd_dev_v2].[top_customer]
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
FROM [cte_cust_allctn_wk1]
LEFT JOIN [item_lu]
       ON [cte_cust_allctn_wk1].[item_id] = [item_lu].[part_number]
JOIN [cte_cust_allctn_wk2]
  ON [cte_cust_allctn_wk1].[item_id] = [cte_cust_allctn_wk2].[item_id]
 AND [cte_cust_allctn_wk1].[top_customer] = [cte_cust_allctn_wk2].[top_customer]
JOIN [cte_cust_allctn_wk3]
  ON [cte_cust_allctn_wk1].[item_id] = [cte_cust_allctn_wk3].[item_id]
 AND [cte_cust_allctn_wk1].[top_customer] = [cte_cust_allctn_wk3].[top_customer]
JOIN [cte_cust_allctn_wk4]
  ON [cte_cust_allctn_wk1].[item_id] = [cte_cust_allctn_wk4].[item_id]
 AND [cte_cust_allctn_wk1].[top_customer] = [cte_cust_allctn_wk4].[top_customer]
GROUP BY
   [cte_cust_allctn_wk1].[item_id] 
  ,[item_lu].[line_code]
  ,[item_lu].[class_code]
  ,[item_lu].[pop_code]
  ,[cte_cust_allctn_wk1].[top_customer] 



