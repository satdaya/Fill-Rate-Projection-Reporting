
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
Demand Bucketing
```
DROP TABLE IF EXISTS [4_wk_prjctd_dmnd_nocust_columnar_v5];

CREATE TABLE [4_wk_prjctd_dmnd_nocust_columnar_v5](
                                      [item_id]                 VARCHAR(54)
                                     ,[line_code]               VARCHAR(54)
								     ,[class_code]              VARCHAR(54)
								     ,[pop_code]                VARCHAR(54) 
									 ,[dec_wk_3_dmnd]           NUMERIC(10, 2)
									 ,[dec_wk_4_dmnd]           NUMERIC(10, 2)
									 ,[dec_wk_5_dmnd]           NUMERIC(10, 2)
									 ,[jan_wk_1_dmnd]           NUMERIC(10, 2)
									 )

INSERT INTO [4_wk_prjctd_dmnd_nocust_columnar_v5](
                                      [item_id]
                                     ,[line_code]
								     ,[class_code]
								     ,[pop_code]
									 ,[dec_wk_3_dmnd]
									 ,[dec_wk_4_dmnd]
									 ,[dec_wk_5_dmnd]
									 ,[jan_wk_1_dmnd] 
									 )

SELECT DISTINCT [item_id]
       ,[line_code]
	   ,[class_code]
	   ,[pop_code]  
	  ,CASE WHEN [yr] = '2020' AND [mnth] = '12'
	        THEN ( SUM([unit_frcst_use]) / 5 )
		 END AS [dec_wk_3_dmnd]
	  ,CASE WHEN [yr] = '2020' AND [mnth] = '12'
	        THEN ( SUM([unit_frcst_use]) / 5 )
		 END AS [dec_wk_4_dmnd]
	  ,CASE WHEN [yr] = '2020' AND [mnth] = '12'
	        THEN ( SUM([unit_frcst_use]) / 5 )
		 END AS [dec_wk_5_dmnd]
	  ,CASE WHEN [yr] = '2021' AND [mnth] = '1'
	        THEN ( SUM([unit_frcst_use]) / 4 )
		 END AS [jan_wk_1_dmnd] 
        FROM [LOCKED_2020_11_sku_EOC]
       WHERE [yr] IN ('2020', '2021')
         AND [mnth] IN ('12', '1')
         AND [measure] = 'forecast'
       GROUP BY  [item_id]
                ,[line_code]
	        ,[class_code]
	        ,[pop_code]
	        ,[yr]
	        ,[mnth]
```
