/*
This query examines the availability at the end of each week. It does so by:
 a. establishing the inventory at the end of prior week
 b. adding the incoming PO volume
 c. subtracting the anticipated demand
 A Case statement eliminates all negative quantities.
*/

DROP TABLE IF EXISTS [available_dev];

CREATE TABLE [available_dev]( 
   [item_id]     VARCHAR(54) PRIMARY KEY
  ,[line_code]   VARCHAR(54)
  ,[class_code]  VARCHAR(54)
  ,[pop_code]    VARCHAR(54)
  ,[current_oh]  INT
  ,[eow_oh_wk1]  INT 
  ,[eow_oh_wk2]  INT
  ,[eow_oh_wk3]  INT
  ,[eow_oh_wk4]  INT
  ,[eow_oh_wk5]  INT
  ,[eow_oh_wk6]  INT
  )   ;

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
     FROM [po_la_deux_cleaned]
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
  [cte_wk1_out]
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
                 - 
                 SUM( ISNULL( [cte_demand_agg].[1_wk_out], 0 ) ) 
                 )
                 < 0
            THEN 0
            ELSE (
                 SUM( ISNULL( [current_inventory].[qty_oh], 0 ) )
                 + 
                 SUM( ISNULL( [cte_po_la_deux].[1_wk_out_recv], 0 ) )
                 - 
                 SUM( ISNULL( [cte_demand_agg].[1_wk_out], 0 ) )
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

  [cte_wk2_out]
   ( 
     [item_id]
    ,[eow_oh]
    )
  AS (
    SELECT
       DISTINCT [cte_wk1_out].[item_id]
      ,CASE WHEN (
                 SUM( ISNULL( [cte_wk1_out].[eow_oh], 0 ) )
                 +
                 SUM( ISNULL( [cte_po_la_deux].[2_wk_out_recv], 0 ) )
                 - 
                 SUM( ISNULL([cte_demand_agg].[2_wk_out], 0 ) )
                 )
                 < 0
            THEN 0
            ELSE (
                 SUM( ISNULL([cte_wk1_out].[eow_oh], 0 ) )
                 +
                 SUM( ISNULL([cte_po_la_deux].[2_wk_out_recv], 0 ) )
                 - 
                 SUM( ISNULL([cte_demand_agg].[2_wk_out], 0 ) )
                 )
            END
    FROM [cte_wk1_out]
    LEFT JOIN [cte_po_la_deux] 
      ON [cte_wk1_out].[item_id] = [cte_po_la_deux].[item_id]
    LEFT JOIN [cte_demand_agg]
      ON [cte_wk1_out].[item_id] = [cte_demand_agg].[item_id]
    GROUP BY [cte_wk1_out].[item_id]
      )
,

  [cte_wk3_out]
   ( 
     [item_id]
    ,[eow_oh]
    )
  AS (
    SELECT
       DISTINCT [cte_wk2_out].[item_id]
      ,CASE WHEN (
                 SUM( ISNULL([cte_wk2_out].[eow_oh], 0 ) )
                 +
                 SUM( ISNULL([cte_po_la_deux].[3_wk_out_recv], 0 ) )
                 -
                 SUM (ISNULL([cte_demand_agg].[3_wk_out], 0 ) )
                 )
                 < 0
            THEN 0
            ELSE (
                 SUM( ISNULL([cte_wk2_out].[eow_oh], 0 ) )
                 +
                 SUM( ISNULL([cte_po_la_deux].[3_wk_out_recv], 0 ) )
                 -
                 SUM (ISNULL([cte_demand_agg].[3_wk_out], 0 ) )
                 )
            END
    FROM [cte_wk2_out]
    LEFT JOIN [cte_po_la_deux] 
      ON [cte_wk2_out].[item_id] = [cte_po_la_deux].[item_id]
    LEFT JOIN [cte_demand_agg]
      ON [cte_wk2_out].[item_id]  = [cte_demand_agg].[item_id]
    GROUP BY [cte_wk2_out].[item_id]
      )
,
  [cte_wk4_out]
   ( 
     [item_id]
    ,[eow_oh]
    )
  AS (
    SELECT
       DISTINCT [cte_wk3_out].[item_id]
      ,CASE WHEN (
                 SUM( ISNULL([cte_wk3_out].[eow_oh], 0 ) )
                 +
                 SUM( ISNULL([cte_po_la_deux].[4_wk_out_recv], 0 ) )
                 -
                 SUM (ISNULL([cte_demand_agg].[4_wk_out], 0 ) )
                 )
                 < 0
            THEN 0
            ELSE (
                 SUM( ISNULL([cte_wk3_out].[eow_oh], 0 ) )
                 +
                 SUM ( ISNULL([cte_po_la_deux].[4_wk_out_recv], 0 ) )
                 -
                 SUM ( ISNULL([cte_demand_agg].[4_wk_out], 0 ) )
                 )
            END
    FROM [cte_wk3_out]
    LEFT JOIN [cte_po_la_deux] 
      ON [cte_wk3_out].[item_id] = [cte_po_la_deux].[item_id]
    LEFT JOIN [cte_demand_agg]
      ON [cte_wk3_out].[item_id] = [cte_demand_agg].[item_id]
    GROUP BY [cte_wk3_out].[item_id]
      )
,
  [cte_wk5_out]
   ( 
     [item_id]
    ,[eow_oh]
    )
  AS (
    SELECT
       DISTINCT [cte_wk4_out].[item_id]
      ,CASE WHEN (
                 SUM( ISNULL([cte_wk4_out].[eow_oh], 0 ) )
                 +
                 SUM( ISNULL([cte_po_la_deux].[5_wk_out_recv], 0 ) )
                 -
                 SUM (ISNULL([cte_demand_agg].[5_wk_out], 0 ) )
                 )
                 < 0
            THEN 0
            ELSE (
                 SUM( ISNULL([cte_wk4_out].[eow_oh], 0 ) )
                 +
                 SUM( ISNULL([cte_po_la_deux].[5_wk_out_recv], 0 ) )
                 -
                 SUM (ISNULL([cte_demand_agg].[5_wk_out], 0 ) )
                 )
            END
    FROM [cte_wk4_out]
    LEFT JOIN [cte_po_la_deux]
      ON [cte_wk4_out].[item_id] = [cte_po_la_deux].[item_id]
    LEFT JOIN [cte_demand_agg]
      ON [cte_wk4_out].[item_id] = [cte_demand_agg].[item_id]
    GROUP BY [cte_wk4_out].[item_id]
      )
,
  [cte_wk6_out]
   ( 
     [item_id]
    ,[eow_oh]
    )
  AS (
    SELECT
       DISTINCT [cte_wk5_out].[item_id]
      ,CASE WHEN (
                 SUM( ISNULL([cte_wk5_out].[eow_oh], 0 ) )
                 +
                 SUM( ISNULL([cte_po_la_deux].[6_wk_out_recv], 0 ) )
                 -
                 SUM (ISNULL([cte_demand_agg].[6_wk_out], 0 ) )
                 )
                 < 0
            THEN 0
            ELSE (
                 SUM( ISNULL([cte_wk5_out].[eow_oh], 0 ) )
                 +
                 SUM( ISNULL([cte_po_la_deux].[6_wk_out_recv], 0 ) )
                 -
                 SUM (ISNULL([cte_demand_agg].[6_wk_out], 0 ) )
                 )
            END
    FROM [cte_wk5_out]
    LEFT JOIN [cte_po_la_deux] 
      ON [cte_wk5_out].[item_id] = [cte_po_la_deux].[item_id]
    LEFT JOIN [cte_demand_agg]
      ON [cte_wk5_out].[item_id] = [cte_demand_agg].[item_id]
    GROUP BY [cte_wk5_out].[item_id]
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
  ,[eow_oh_wk5]
  ,[eow_oh_wk6]
  )

SELECT
   DISTINCT [current_inventory].[short_partnumber]
  ,[item_lu].[line_code]
  ,[item_lu].[class_code]
  ,[item_lu].[pop_code]
  ,SUM ( [current_inventory].[qty_oh] )
  ,SUM ( [cte_wk1_out].[eow_oh] )
  ,SUM ( [cte_wk2_out].[eow_oh] )
  ,SUM ( [cte_wk3_out].[eow_oh] )
  ,SUM ( [cte_wk4_out].[eow_oh] )
  ,SUM ( [cte_wk5_out].[eow_oh] )
  ,SUM ( [cte_wk6_out].[eow_oh] )
FROM [current_inventory]
JOIN [item_lu]
  ON [current_inventory].[short_partnumber] = [item_lu].[item_id]
LEFT JOIN [cte_wk1_out]
  ON [current_inventory].[short_partnumber] = [cte_wk1_out].[item_id]
LEFT JOIN [cte_wk2_out]
  ON [current_inventory].[short_partnumber] = [cte_wk2_out].[item_id]
LEFT JOIN [cte_wk3_out]
  ON [current_inventory].[short_partnumber] = [cte_wk3_out].[item_id]
LEFT JOIN [cte_wk4_out]
  ON [current_inventory].[short_partnumber] = [cte_wk4_out].[item_id]
LEFT JOIN [cte_wk5_out]
  ON [current_inventory].[short_partnumber] = [cte_wk5_out].[item_id]
LEFT JOIN [cte_wk6_out]
  ON [current_inventory].[short_partnumber] = [cte_wk6_out].[item_id]
GROUP BY
   [current_inventory].[short_partnumber]
  ,[item_lu].[line_code]
  ,[item_lu].[class_code]
  ,[item_lu].[pop_code]
    
