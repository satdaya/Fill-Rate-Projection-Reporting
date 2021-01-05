DROP TABLE IF EXISTS [po_la_deux_1.1.2021_cleaned]

CREATE TABLE [po_la_deux_1.1.2021_cleaned]
  (
    [item_id]       VARCHAR (54)
   ,[po_#]          VARCHAR (54)
   ,[qty_it]        INT
   ,[due_date]      VARCHAR(11)
   ,[1_wk_out_recv] INT
   ,[2_wk_out_recv] INT
   ,[3_wk_out_recv] INT
   ,[4_wk_out_recv] INT
  )

INSERT INTO [po_la_deux_1.1.2021_cleaned]
  (
    [item_id]
   ,[po_#]
   ,[qty_it]
   ,[due_date]
   ,[1_wk_out_recv]
   ,[2_wk_out_recv]
   ,[3_wk_out_recv]
   ,[4_wk_out_recv]
  )

SELECT
    [Part_Number]
   ,[po_#]
   ,SUM([qty_it])
   ,[due_date]
   ,CASE WHEN [due_date] BETWEEN '2020-12-15' AND '2021-01-07'
         THEN SUM([qty_it])
         END
   ,CASE WHEN [due_date] BETWEEN '2021-01-09' AND '2021-01-15'
         THEN SUM([qty_it])
         END
   ,CASE WHEN [due_date] BETWEEN '2021-01-16' AND '2021-01-22'
         THEN SUM([qty_it])
         END
   ,CASE WHEN [due_date] BETWEEN '2021-01-23' AND '2021-01-29'
         THEN SUM([qty_it])
         END
 FROM [po_la_deux_raw_1.1.21]
GROUP BY
   [Part_Number]
  ,[po_#]
  ,[due_date]
