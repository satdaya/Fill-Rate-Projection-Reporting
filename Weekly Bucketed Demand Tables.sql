DROP TABLE IF EXISTS [prjctd_dmnd_wk_dev];

CREATE TABLE [prjctd_dmnd_wk_dev]
  (
   [item_id]                 VARCHAR(54)
  ,[line_code]               VARCHAR(54)
  ,[class_code]              VARCHAR(54)
  ,[pop_code]                VARCHAR(54)
  ,[top_customer]            VARCHAR(54)
  ,[1_wk_out]                NUMERIC(10, 2)
  ,[2_wk_out]                NUMERIC(10, 2)
  ,[3_wk_out]                NUMERIC(10, 2)
  ,[4_wk_out]                NUMERIC(10, 2)
  ,[sku_cust_combo]          INT
  ) ;

WITH [cte_base_calc] 
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
   )

AS
(
   SELECT 
      DISTINCT [item_id]
     ,[line_code]
	 ,[class_code]
	 ,[pop_code]  
     ,CASE WHEN [keycust1_high_level] = 'Parts Authority'
	       THEN 'Parts Authority'
           WHEN [keycust1_high_level] = 'FMP'
	       THEN 'FMP'
           WHEN [keycust1_high_level] = 'Fast Undercar'
	       THEN 'Fast Undercar'
           WHEN [keycust1_high_level] = 'XL Parts'
	       THEN 'XL Parts'
		   ELSE 'All Other'
           END
           AS [top_customer]
	  --,[keycust2_top_customer]
	  ,CASE WHEN [yr] = '2020' AND [mnth] = '12'
	        THEN ( SUM([unit_fill_rate]) / 5 )
		    END AS [1_wk_out]
	  ,CASE WHEN [yr] = '2020' AND [mnth] = '12'
	        THEN ( SUM([unit_fill_rate]) / 5 )
		    END AS [2_wk_out]
	  ,CASE WHEN [yr] = '2021' AND [mnth] = '1'
	        THEN ( SUM([unit_fill_rate]) / 4 )
			END AS [3_wk_out]
	  ,CASE WHEN [yr] = '2021' AND [mnth] = '1'
	        THEN ( SUM([unit_fill_rate]) / 4 )
			END AS [4_wk_out]  
       FROM [LOCKED_2020_11_sku_EOC]
       WHERE [yr] IN ('2020', '2021')
         AND [mnth] IN ('12', '1')
         AND [measure] = 'forecast'
       GROUP BY  [item_id]
                ,[line_code]
	            ,[class_code]
	            ,[pop_code]  
                ,CASE WHEN [keycust1_high_level] = 'Parts Authority'
	         THEN 'Parts Authority'
			 WHEN [keycust1_high_level] = 'FMP'
	         THEN 'FMP'
			 WHEN [keycust1_high_level] = 'Fast Undercar'
	         THEN 'Fast Undercar'
			 WHEN [keycust1_high_level] = 'XL Parts'
	         THEN 'XL Parts'
			 ELSE 'All Other'
			 END
     ,[yr]
	 ,[mnth]
)
		
INSERT INTO [prjctd_dmnd_wk_dev](
   [item_id]
  ,[line_code]
  ,[class_code]
  ,[pop_code]
  ,[top_customer]
  ,[1_wk_out]
  ,[2_wk_out]
  ,[3_wk_out]
  ,[4_wk_out]
  ,[sku_cust_combo] 
	)
SELECT DISTINCT 
   [item_id]
  ,[line_code]
  ,[class_code]
  ,[pop_code]  
  ,[top_customer]
  ,SUM( [dec_wk_4_dmnd])
  ,SUM( [dec_wk_5_dmnd])
  ,SUM( [jan_wk_1_dmnd])
  ,SUM( [jan_wk_2_dmnd])
  ,COUNT( [item_id] ) OVER
        (PARTITION BY [item_id])
FROM [cte_base_calc]
GROUP BY
   [item_id]
  ,[line_code]
  ,[class_code]
  ,[pop_code]  
  ,[top_customer]
