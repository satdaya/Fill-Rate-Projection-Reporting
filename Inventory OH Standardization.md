
```
DROP TABLE IF EXISTS [fill_rate_model_dev_v1];

CREATE TABLE [fill_rate_model_dev_v1] ( [short_partnumber] VARCHAR (54)
                                        ,[qty_oh]          NUMERIC (10, 2)
                                      ) ;

WITH [cte_fill_rate_projections] ( [idnumber], [partnumber], [short_partnumber], [qty_oh] )

AS (

SELECT [SQLAccess.Part].[idnumber]
       ,[PartNumber]
       ,RIGHT(
	      [PartNumber]
	     ,LEN([PartNumber]) -3
	      ) AS [short_part_number]
       ,SUM( [OnHand] ) AS [qty_oh]
  FROM [SQLAccess.Part]
  LEFT JOIN [SQLAccess.Partco]
         ON [SQLAccess.Part].[idnumber] = [SQLAccess.Partco].[PartId]
GROUP BY RIGHT(
	           [SQLAccess.Part].[idnumber]
	          ,LEN([PartNumber]) -3
	          ) 
        ,[PartNumber]
        ,[SQLAccess.Part].[idnumber]
		)

INSERT INTO [fill_rate_model_dev_v1] ([short_partnumber]
                                      ,[qty_oh] 
                                      )

SELECT DISTINCT [short_partnumber]
      ,SUM([qty_oh])
  FROM [cte_fill_rate_projections]
GROUP BY [short_partnumber] ;
```

Clear out unforecasted sku's:

```DROP TABLE IF EXISTS [fill_rate_model_dev_v1];

CREATE TABLE [fill_rate_model_dev_v1] ( [short_partnumber] VARCHAR (54)
                                        ,[qty_oh]          NUMERIC (10, 2)
									  ) ;

WITH [cte_fill_rate_projections] ( [idnumber], [partnumber], [short_partnumber], [qty_oh] )

AS (

SELECT [SQLAccess.Part].[idnumber]
       ,[PartNumber]
	   ,RIGHT(
	           [PartNumber]
	          ,LEN([PartNumber]) -3
	          ) AS [short_part_number]
       ,SUM( [OnHand] ) AS [qty_oh]
  FROM [SQLAccess.Part]
  LEFT JOIN [SQLAccess.Partco]
         ON [SQLAccess.Part].[idnumber] = [SQLAccess.Partco].[PartId]
GROUP BY RIGHT(
	           [SQLAccess.Part].[idnumber]
	          ,LEN([PartNumber]) -3
	          ) 
        ,[PartNumber]
        ,[SQLAccess.Part].[idnumber]
		)
		,
[cte_clean_short_partnumber] ( [short_partnumber] )

AS (SELECT [short_partnumber]
      FROM [cte_fill_rate_projections] 
	  JOIN [4_wk_prjctd_dmnd_nocust_columnar_v5]
	    ON [cte_fill_rate_projections].[short_partnumber] = [4_wk_prjctd_dmnd_nocust_columnar_v5].[item_id]
		)

INSERT INTO [fill_rate_model_dev_v1] ([short_partnumber]
                                         ,[qty_oh] 
										 )

SELECT DISTINCT [cte_clean_short_partnumber].[short_partnumber]
      ,SUM([cte_fill_rate_projections].[qty_oh])
  FROM [cte_fill_rate_projections]
  JOIN [cte_clean_short_partnumber]
    ON [cte_fill_rate_projections].[short_partnumber] = [cte_clean_short_partnumber].[short_partnumber]
GROUP BY [cte_clean_short_partnumber].[short_partnumber] ;
```
