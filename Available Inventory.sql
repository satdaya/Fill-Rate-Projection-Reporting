DROP TABLE IF EXISTS [available_dev];


CREATE TABLE [available_dev]( 
   [item_id]     VARCHAR(54)
  ,[line_code]   VARCHAR(54)
  ,[class_code]  VARCHAR(54)
  ,[pop_code]    VARCHAR(54)
  ,[current_oh]  FLOAT
  ,[eow_oh_wk1]  FLOAT 
  ,[eow_oh_wk2]  FLOAT
  ,[eow_oh_wk3]  FLOAT
  ,[eow_oh_wk4]  FLOAT
  )   ;

WITH
  [cte_PO_LaDeux_12.18] 
  ( 
     [Part_Number]
    ,[dec_wk4]
	,[dec_wk5]
	,[jan_wk1]
	,[jan_wk2]
	)
  AS (
     SELECT 
	    DISTINCT [Part_Number]
	   ,SUM([dec_wk4])
	   ,SUM([dec_wk5])
	   ,SUM([jan_wk1])
	   ,SUM([jan_wk2])
	 FROM [po_ladeux_12.18.2020]
	 GROUP BY [Part_Number]
	 )
,
  [cte_demand_agg]
  (
     [item_id]
	,[dec_wk_4_dmnd]
	,[dec_wk_5_dmnd]
	,[jan_wk_1_dmnd]
	,[jan_wk_2_dmnd]
	)
  AS (
     SELECT 
	    DISTINCT [item_id]
       ,SUM([dec_wk_4_dmnd])
	   ,SUM([dec_wk_5_dmnd])
	   ,SUM([jan_wk_1_dmnd])
	   ,SUM([jan_wk_2_dmnd])
     FROM [dec_4_wk_prjctd_dmnd_dev_v2]
	 GROUP BY [item_id]
	 )
,
  [cte_wk1_out]
    ( 
     [item_id]
	,[eow_oh]
	)
  AS (
    SELECT
	   DISTINCT [fill_rate_model_dev_v2].[short_partnumber]
	  ,CASE WHEN ( 
	             SUM( ISNULL( [fill_rate_model_dev_v2].[qty_oh], 0 ) )
	             + 
	             SUM( ISNULL( [cte_PO_LaDeux_12.18].[dec_wk4], 0 ) )
				 - 
				 SUM( ISNULL( [cte_demand_agg].[dec_wk_4_dmnd], 0 ) ) 
				 )
				 < 0
	        THEN 0
			ELSE (
			     SUM( ISNULL( [fill_rate_model_dev_v2].[qty_oh], 0 ) )
	             + 
	             SUM( ISNULL( [cte_PO_LaDeux_12.18].[dec_wk4], 0 ) )
				 - 
				 SUM( ISNULL( [cte_demand_agg].[dec_wk_4_dmnd], 0 ) )
				 )
            END
	FROM [fill_rate_model_dev_v2]
	LEFT JOIN [cte_PO_LaDeux_12.18] 
	  ON [fill_rate_model_dev_v2].[short_partnumber] = [cte_PO_LaDeux_12.18].[Part_Number]
	LEFT JOIN [cte_demand_agg]
	  ON [fill_rate_model_dev_v2].[short_partnumber] = [cte_demand_agg].[item_id]
	GROUP BY [fill_rate_model_dev_v2].[short_partnumber]

	  )
,

  [cte_wk2_out]
   ( 
     [item_id]
	,[eow_oh]
	)
  AS (
    SELECT
	   DISTINCT [fill_rate_model_dev_v2].[short_partnumber]
	  ,CASE WHEN (
	             SUM( ISNULL( [cte_wk1_out].[eow_oh], 0 ) )
	             +
	             SUM( ISNULL( [cte_PO_LaDeux_12.18].[dec_wk5], 0 ) )
				 - 
				 SUM( ISNULL([cte_demand_agg].[dec_wk_5_dmnd], 0 ) )
				 )
				 < 0
	        THEN 0
			ELSE (
			     SUM( ISNULL([cte_wk1_out].[eow_oh], 0 ) )
	             +
	             SUM( ISNULL([cte_PO_LaDeux_12.18].[dec_wk5], 0 ) )
				 - 
				 SUM( ISNULL([cte_demand_agg].[dec_wk_5_dmnd], 0 ) )
				 )
			END
	FROM [fill_rate_model_dev_v2]
	LEFT JOIN [cte_PO_LaDeux_12.18]
	  ON [fill_rate_model_dev_v2].[short_partnumber] = [cte_PO_LaDeux_12.18].[Part_Number]
	LEFT JOIN [cte_demand_agg]
	  ON [fill_rate_model_dev_v2].[short_partnumber] = [cte_demand_agg].[item_id]
	LEFT JOIN [cte_wk1_out]
	  ON [fill_rate_model_dev_v2].[short_partnumber] = [cte_wk1_out].[item_id]
    GROUP BY [fill_rate_model_dev_v2].[short_partnumber]
	  )
,

  [cte_wk3_out]
   ( 
     [item_id]
	,[eow_oh]
	)
  AS (
    SELECT
	   DISTINCT [fill_rate_model_dev_v2].[short_partnumber]
	  ,CASE WHEN (
	             SUM( ISNULL([cte_wk2_out].[eow_oh], 0 ) )
	             +
	             SUM( ISNULL([cte_PO_LaDeux_12.18].[jan_wk1], 0 ) )
				 -
				 SUM (ISNULL([cte_demand_agg].[jan_wk_1_dmnd], 0 ) )
				 )
				 < 0
	        THEN 0
			ELSE (
			     SUM( ISNULL([cte_wk2_out].[eow_oh], 0 ) )
	             +
	             SUM( ISNULL([cte_PO_LaDeux_12.18].[jan_wk1], 0 ) )
				 -
				 SUM (ISNULL([cte_demand_agg].[jan_wk_1_dmnd], 0 ) )
				 )
			END
	FROM [fill_rate_model_dev_v2]
	LEFT JOIN [cte_PO_LaDeux_12.18]
	  ON [fill_rate_model_dev_v2].[short_partnumber] = [cte_PO_LaDeux_12.18].[Part_Number]
	LEFT JOIN [cte_demand_agg]
	  ON [fill_rate_model_dev_v2].[short_partnumber] = [cte_demand_agg].[item_id]
	LEFT JOIN [cte_wk2_out]
	  ON [fill_rate_model_dev_v2].[short_partnumber] = [cte_wk2_out].[item_id]
	GROUP BY [fill_rate_model_dev_v2].[short_partnumber]
	  )
,
  [cte_wk4_out]
   ( 
     [item_id]
	,[eow_oh]
	)
  AS (
    SELECT
	   DISTINCT [fill_rate_model_dev_v2].[short_partnumber]
	  ,CASE WHEN (
	             SUM( ISNULL([cte_wk3_out].[eow_oh], 0 ) )
	             +
				 SUM( ISNULL([cte_PO_LaDeux_12.18].[jan_wk2], 0 ) )
				 -
				 SUM (ISNULL([cte_demand_agg].[jan_wk_2_dmnd], 0 ) )
				 )
				 < 0
	        THEN 0
			ELSE (
			     SUM( ISNULL([cte_wk3_out].[eow_oh], 0 ) )
	             +
				 SUM ( ISNULL([cte_PO_LaDeux_12.18].[jan_wk2], 0 ) )
				 -
				 SUM ( ISNULL([cte_demand_agg].[jan_wk_2_dmnd], 0 ) )
				 )
			END
	FROM [fill_rate_model_dev_v2]
	LEFT JOIN [cte_PO_LaDeux_12.18]
	  ON [fill_rate_model_dev_v2].[short_partnumber] = [cte_PO_LaDeux_12.18].[Part_Number]
	LEFT JOIN [cte_demand_agg]
	  ON [fill_rate_model_dev_v2].[short_partnumber] = [cte_demand_agg].[item_id]
	LEFT JOIN [cte_wk3_out]
	  ON [fill_rate_model_dev_v2].[short_partnumber] = [cte_wk3_out].[item_id]
	GROUP BY [fill_rate_model_dev_v2].[short_partnumber]
	  )

INSERT INTO [available_dev]
   (
   [item_id]
  ,[line_code]
  ,[class_code]
  ,[pop_code]
  ,[current_oh]
  ,[eow_oh_wk1]
  ,[eow_oh_wk2]
  ,[eow_oh_wk3]
  ,[eow_oh_wk4]
  )

SELECT
   DISTINCT [fill_rate_model_dev_v2].[short_partnumber]
  ,[item_lu].[line_code]
  ,[item_lu].[class_code]
  ,[item_lu].[pop_code]
  ,SUM ( [fill_rate_model_dev_v2].[qty_oh] )
  ,SUM ( [cte_wk1_out].[eow_oh] )
  ,SUM ( [cte_wk2_out].[eow_oh] )
  ,SUM ( [cte_wk3_out].[eow_oh] )
  ,SUM ( [cte_wk4_out].[eow_oh] )
FROM [fill_rate_model_dev_v2]
JOIN [item_lu]
  ON [fill_rate_model_dev_v2].[short_partnumber] = [item_lu].[part_number]
LEFT JOIN [cte_wk1_out]
  ON [fill_rate_model_dev_v2].[short_partnumber] = [cte_wk1_out].[item_id]
LEFT JOIN [cte_wk2_out]
  ON [fill_rate_model_dev_v2].[short_partnumber] = [cte_wk2_out].[item_id]
LEFT JOIN [cte_wk3_out]
  ON [fill_rate_model_dev_v2].[short_partnumber] = [cte_wk3_out].[item_id]
LEFT JOIN [cte_wk4_out]
  ON [fill_rate_model_dev_v2].[short_partnumber] = [cte_wk4_out].[item_id]
GROUP BY
   [fill_rate_model_dev_v2].[short_partnumber]
  ,[item_lu].[line_code]
  ,[item_lu].[class_code]
  ,[item_lu].[pop_code]
    
