/* 
This query takes all in transit and on PO sku's scheduled to arrive within the next 6 weeks and breaks them into weekly buckets.
*/

DROP TABLE IF EXISTS [po_la_deux_cleaned];

CREATE TABLE [po_la_deux_cleaned]
  (
    [item_id]       VARCHAR (54)
   ,[line_code]     VARCHAR (54)
   ,[1_wk_out_recv] INT
   ,[2_wk_out_recv] INT
   ,[3_wk_out_recv] INT
   ,[4_wk_out_recv] INT
   ,[5_wk_out_recv] INT
   ,[6_wk_out_recv] INT
  );

WITH [cte_po_ld_buckets]
  (
    [item_id]
   ,[line_code]
   ,[1_wk_out_recv]
   ,[2_wk_out_recv]
   ,[3_wk_out_recv]
   ,[4_wk_out_recv]
   ,[5_wk_out_recv]
   ,[6_wk_out_recv]
  )
AS
  (
-- I do not use dynamic dates, as I run this query on varying days of the week.
SELECT
    [Part_Number]
   ,[line_code]
   ,CASE WHEN [dbd] BETWEEN '2020-12-15' AND '2021-01-30'
         THEN SUM([qty])
         END
   ,CASE WHEN [dbd] BETWEEN '2021-01-30' AND '2021-02-05'
         THEN SUM([qty])
         END
   ,CASE WHEN [dbd] BETWEEN '2021-02-06' AND '2021-02-12'
         THEN SUM([qty])
         END
   ,CASE WHEN [dbd] BETWEEN '2021-02-13' AND '2021-02-19'
         THEN SUM([qty])
         END
   ,CASE WHEN [dbd] BETWEEN '2021-02-20' AND '2021-02-26'
         THEN SUM([qty])
         END
   ,CASE WHEN [dbd] BETWEEN '2021-02-27' AND '2021-03-05'
         THEN SUM([qty])
         END
 FROM [po_ld_1.23.2021]
GROUP BY
   [Part_Number]
  ,[line_code]
  ,[dbd]
)
INSERT INTO [po_la_deux_cleaned]
  (
    [item_id]
   ,[line_code]
   ,[1_wk_out_recv]
   ,[2_wk_out_recv]
   ,[3_wk_out_recv]
   ,[4_wk_out_recv]
   ,[5_wk_out_recv]
   ,[6_wk_out_recv]
  )

SELECT
    [item_id]
   ,[line_code]
   ,SUM( [1_wk_out_recv] )
   ,SUM( [2_wk_out_recv] )
   ,SUM( [3_wk_out_recv] )
   ,SUM( [4_wk_out_recv] )
   ,SUM( [5_wk_out_recv] )
   ,SUM( [6_wk_out_recv] )
FROM [cte_po_ld_buckets]
GROUP BY 
    [item_id]
   ,[line_code]

