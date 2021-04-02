DROP TABLE IF EXISTS [weekly_frcst_stage];

CREATE TABLE [weekly_frcst_stage]
 (
   [date_use]     VARCHAR(10)
  ,[item_id]      VARCHAR(54)
  ,[top_customer] VARCHAR(54)
  ,[qty_ord]      INT
  ,PRIMARY KEY ( [date_use], [item_id], [top_customer] )
)

INSERT INTO [weekly_frcst_stage]
(
   [date_use]
  ,[item_id]
  ,[top_customer]
  ,[qty_ord]
)

SELECT 
   CONVERT(VARCHAR(10), [InvDate], 20)
  ,[PartNumber]
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
   ,SUM([QtyOrd])
FROM [FrcstFactTbl]
JOIN [account_hierarchy_lu_dec_20]
  ON [FrcstFactTbl].[AccountNumber] = [account_hierarchy_lu_dec_20].[AccountNumber]
WHERE [InvDate] BETWEEN '2020-07-01' AND GETDATE()
  AND [PartNumber] IS NOT NULL
GROUP BY
   CONVERT(VARCHAR(10), [InvDate], 20)
  ,[PartNumber]
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

--SELECT *
--FROM [weekly_frcst_stage]
