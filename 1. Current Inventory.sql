--Pulls current inventory position. Allocated sku's are included.

DROP TABLE IF EXISTS [current_inventory];

CREATE TABLE [current_inventory] (
    [short_partnumber]  VARCHAR (54) PRIMARY KEY
   ,[qty_oh]            NUMERIC (10, 2)
   ) ;

WITH [cte_fill_rate_projections] 
  ( 
    [idnumber]
   ,[partnumber]
   ,[short_partnumber]
   ,[qty_oh]
   )

AS (

SELECT 
   [SQLAccess.Part].[idnumber]
  ,[PartNumber]
   --a 3 character line code precedes the part number. The line below removes the line code
  ,RIGHT(
     [PartNumber]
    ,LEN([PartNumber]) -3
         ) AS [short_part_number]
  ,SUM( [OnHand] ) AS [qty_oh]
  FROM [SQLAccess.Part]
  LEFT JOIN [SQLAccess.Partco]
         ON [SQLAccess.Part].[idnumber] = [SQLAccess.Partco].[PartId]
  WHERE [SQLAccess.Partco].[co] = '2'
GROUP BY 
   RIGHT(
     [SQLAccess.Part].[idnumber]
    ,LEN([PartNumber]) -3
	     ) 
   ,[PartNumber]
   ,[SQLAccess.Part].[idnumber]
)
,
[cte_clean_short_partnumber] ( [short_partnumber] )

AS (
  SELECT DISTINCT [short_partnumber]
  FROM [cte_fill_rate_projections] 
  JOIN [4_wk_prjctd_dmnd_nocust_columnar_v5]
    ON [cte_fill_rate_projections].[short_partnumber] = [4_wk_prjctd_dmnd_nocust_columnar_v5].[item_id]
)

INSERT INTO [current_inventory] (
   [short_partnumber]
  ,[qty_oh] 
)

SELECT DISTINCT [cte_clean_short_partnumber].[short_partnumber]
      ,SUM([cte_fill_rate_projections].[qty_oh])
  FROM [cte_fill_rate_projections]
  JOIN [cte_clean_short_partnumber]
    ON [cte_fill_rate_projections].[short_partnumber] = [cte_clean_short_partnumber].[short_partnumber]
GROUP BY [cte_clean_short_partnumber].[short_partnumber] ;

