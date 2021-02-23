/*
The previous query established the demand at the end of each week. This query establishes just the current plus inbound calculation needed for the following calculation queries.
*/

DROP TABLE IF EXISTS [available_dev_no_dmnd];
CREATE TABLE [available_dev_no_dmnd]( 
   [item_id]     VARCHAR(54) PRIMARY KEY
  ,[line_code]   VARCHAR(54)
  ,[class_code]  VARCHAR(54)
  ,[pop_code]    VARCHAR(54)
  ,[current_oh]  FLOAT
  ,[eow_oh_wk1_no_dmnd]  INT 
  ,[eow_oh_wk2_no_dmnd]  INT
  ,[eow_oh_wk3_no_dmnd]  INT
  ,[eow_oh_wk4_no_dmnd]  INT
  ,[eow_oh_wk5_no_dmnd]  INT
  ,[eow_oh_wk6_no_dmnd]  INT
  )
  ;

WITH
  [cte_po_la_deux] 
  ( 
    [item_id]
   ,[1_wk_out_recv]
   ,[2_wk_out_recv]
   ,[3_wk_out_recv]
   ,[4_wk_out_recv]
   ,[5_wk_out_recv]
   ,[6_wk_out_recv]
	)
  AS (
     SELECT 
	    DISTINCT [item_id]
	   ,SUM([1_wk_out_recv])
	   ,SUM([2_wk_out_recv])
	   ,SUM([3_wk_out_recv])
	   ,SUM([4_wk_out_recv])
	   ,SUM([5_wk_out_recv])
	   ,SUM([6_wk_out_recv])
	 FROM [po_la_deux_1.1.2021_cleaned]
	 GROUP BY [item_id]
	 )
,
  [cte_demand_agg]
  (
     [item_id]
	,[1_wk_out]
	,[2_wk_out]
	,[3_wk_out]
	,[4_wk_out]
	,[5_wk_out]
	,[6_wk_out]
	)
  AS (
     SELECT 
	    DISTINCT [item_id]
       ,SUM([1_wk_out])
	   ,SUM([2_wk_out])
	   ,SUM([3_wk_out])
	   ,SUM([4_wk_out])
	   ,SUM([5_wk_out])
	   ,SUM([6_wk_out])
     FROM  [projctd_dmnd_weekly_buckets]
	 GROUP BY [item_id]
	 )
,
  [cte_wk1_out_no_dmnd]
    ( 
     [item_id]
	,[eow_oh]
	)
  AS (
    SELECT
	   DISTINCT [current_inventory].[short_partnumber]
	  ,CASE WHEN ( 
	             SUM( ISNULL( [current_inventory].[qty_oh], 0 ) )
	             + 
	             SUM( ISNULL( [cte_po_la_deux].[1_wk_out_recv], 0 ) )
                 
				 )
				 < 0
	        THEN 0
			ELSE (
			     SUM( ISNULL( [current_inventory].[qty_oh], 0 ) )
	             + 
	             SUM( ISNULL( [cte_po_la_deux].[1_wk_out_recv], 0 ) )

				 )
            END
	FROM [current_inventory]
	LEFT JOIN [cte_po_la_deux] 
	  ON [current_inventory].[short_partnumber] = [cte_po_la_deux].[item_id]
	LEFT JOIN [cte_demand_agg]
	  ON [current_inventory].[short_partnumber] = [cte_demand_agg].[item_id]
	GROUP BY [current_inventory].[short_partnumber]

	  )
,

  [cte_wk2_out_no_dmnd]
   ( 
     [item_id]
	,[eow_oh]
	)
  AS (
    SELECT
	   DISTINCT [available_dev].[item_id]
	  ,CASE WHEN (
	             SUM( ISNULL( [available_dev].[eow_oh_wk1], 0 ) )
	             +
	             SUM( ISNULL( [cte_po_la_deux].[2_wk_out_recv], 0 ) )
				 )
				 < 0
	        THEN 0
			ELSE (
			     SUM( ISNULL([available_dev].[eow_oh_wk1], 0 ) )
	             +
	             SUM( ISNULL([cte_po_la_deux].[2_wk_out_recv], 0 ) )
				 )
			END
	FROM [available_dev]
	LEFT JOIN [cte_po_la_deux] 
	  ON [available_dev].[item_id] = [cte_po_la_deux].[item_id]
	LEFT JOIN [cte_demand_agg]
	  ON [available_dev].[item_id] = [cte_demand_agg].[item_id]
    GROUP BY [available_dev].[item_id]
	  )
,

  [cte_wk3_out_no_dmnd]
   ( 
     [item_id]
	,[eow_oh]
	)
  AS (
    SELECT
	   DISTINCT [available_dev].[item_id]
	  ,CASE WHEN (
	             SUM( ISNULL( [available_dev].[eow_oh_wk2], 0 ) )
	             +
	             SUM( ISNULL([cte_po_la_deux].[3_wk_out_recv], 0 ) )
				 )
				 < 0
	        THEN 0
			ELSE (
			     SUM( ISNULL([available_dev].[eow_oh_wk2], 0 ) )
	             +
	             SUM( ISNULL([cte_po_la_deux].[3_wk_out_recv], 0 ) )
				 )
			END
	FROM [available_dev]
	LEFT JOIN [cte_po_la_deux] 
	  ON [available_dev].[item_id] = [cte_po_la_deux].[item_id]
	LEFT JOIN [cte_demand_agg]
	  ON [available_dev].[item_id] = [cte_demand_agg].[item_id]
    GROUP BY [available_dev].[item_id]
	  )
,
  [cte_wk4_out_no_dmnd]
   ( 
     [item_id]
	,[eow_oh]
	)
  AS (
    SELECT
	   DISTINCT [available_dev].[item_id]
	  ,CASE WHEN (
	             SUM( ISNULL([available_dev].[eow_oh_wk3], 0 ) )
	             +
				 SUM( ISNULL([cte_po_la_deux].[4_wk_out_recv], 0 ) )
				 )
				 < 0
	        THEN 0
			ELSE (
			     SUM( ISNULL([available_dev].[eow_oh_wk3], 0 ) )
	             +
				 SUM ( ISNULL([cte_po_la_deux].[4_wk_out_recv], 0 ) )
				 )
			END
	FROM [available_dev]
	LEFT JOIN [cte_po_la_deux] 
	  ON [available_dev].[item_id] = [cte_po_la_deux].[item_id]
	LEFT JOIN [cte_demand_agg]
	  ON [available_dev].[item_id] = [cte_demand_agg].[item_id]
    GROUP BY [available_dev].[item_id]
	  )
,
  [cte_wk5_out_no_dmnd]
   ( 
     [item_id]
	,[eow_oh]
	)
  AS (
    SELECT
	   DISTINCT [available_dev].[item_id]
	  ,CASE WHEN (
	             SUM( ISNULL([available_dev].[eow_oh_wk4], 0 ) )
	             +
				 SUM( ISNULL([cte_po_la_deux].[5_wk_out_recv], 0 ) )
				 )
				 < 0
	        THEN 0
			ELSE  (
	             SUM( ISNULL([available_dev].[eow_oh_wk4], 0 ) )
	             +
				 SUM( ISNULL([cte_po_la_deux].[5_wk_out_recv], 0 ) )
				 )
			END
	FROM [available_dev]
	LEFT JOIN [cte_po_la_deux] 
	  ON [available_dev].[item_id] = [cte_po_la_deux].[item_id]
	LEFT JOIN [cte_demand_agg]
	  ON [available_dev].[item_id] = [cte_demand_agg].[item_id]
    GROUP BY [available_dev].[item_id]
	  )
,
  [cte_wk6_out_no_dmnd]
   ( 
     [item_id]
	,[eow_oh]
	)
  AS (
    SELECT
	   DISTINCT [available_dev].[item_id]
	  ,CASE WHEN (
	             SUM( ISNULL([available_dev].[eow_oh_wk5], 0 ) )
	             +
				 SUM( ISNULL([cte_po_la_deux].[6_wk_out_recv], 0 ) )
				 )
				 < 0
	        THEN 0
			ELSE (
	             SUM( ISNULL([available_dev].[eow_oh_wk5], 0 ) )
	             +
				 SUM( ISNULL([cte_po_la_deux].[6_wk_out_recv], 0 ) )
				 )
			END
	FROM [available_dev]
	LEFT JOIN [cte_po_la_deux] 
	  ON [available_dev].[item_id] = [cte_po_la_deux].[item_id]
	LEFT JOIN [cte_demand_agg]
	  ON [available_dev].[item_id] = [cte_demand_agg].[item_id]
    GROUP BY [available_dev].[item_id]
	  )

INSERT INTO [available_dev_no_dmnd]
   (
   [item_id]
  ,[line_code]
  ,[class_code]
  ,[pop_code]
  ,[current_oh]
  ,[eow_oh_wk1_no_dmnd]
  ,[eow_oh_wk2_no_dmnd]
  ,[eow_oh_wk3_no_dmnd]
  ,[eow_oh_wk4_no_dmnd]
  ,[eow_oh_wk5_no_dmnd]
  ,[eow_oh_wk6_no_dmnd]
  )

SELECT
   DISTINCT [current_inventory].[short_partnumber]
  ,[item_lu].[line_code]
  ,[item_lu].[class_code]
  ,[item_lu].[pop_code]
  ,SUM ( [current_inventory].[qty_oh] )
  ,SUM ( [cte_wk1_out_no_dmnd].[eow_oh] )
  ,SUM ( [cte_wk2_out_no_dmnd].[eow_oh] )
  ,SUM ( [cte_wk3_out_no_dmnd].[eow_oh] )
  ,SUM ( [cte_wk4_out_no_dmnd].[eow_oh] )
  ,SUM ( [cte_wk5_out_no_dmnd].[eow_oh] )
  ,SUM ( [cte_wk6_out_no_dmnd].[eow_oh] )
FROM [current_inventory]
JOIN [item_lu]
  ON [current_inventory].[short_partnumber] = [item_lu].[item_id]
LEFT JOIN [cte_wk1_out_no_dmnd]
  ON [current_inventory].[short_partnumber] = [cte_wk1_out_no_dmnd].[item_id]
LEFT JOIN [cte_wk2_out_no_dmnd]
  ON [current_inventory].[short_partnumber] = [cte_wk2_out_no_dmnd].[item_id]
LEFT JOIN [cte_wk3_out_no_dmnd]
  ON [current_inventory].[short_partnumber] = [cte_wk3_out_no_dmnd].[item_id]
LEFT JOIN [cte_wk4_out_no_dmnd]
  ON [current_inventory].[short_partnumber] = [cte_wk4_out_no_dmnd].[item_id]
LEFT JOIN [cte_wk5_out_no_dmnd]
  ON [current_inventory].[short_partnumber] = [cte_wk5_out_no_dmnd].[item_id]
LEFT JOIN [cte_wk6_out_no_dmnd]
  ON [current_inventory].[short_partnumber] = [cte_wk6_out_no_dmnd].[item_id]
GROUP BY
   [current_inventory].[short_partnumber]
  ,[item_lu].[line_code]
  ,[item_lu].[class_code]
  ,[item_lu].[pop_code]
