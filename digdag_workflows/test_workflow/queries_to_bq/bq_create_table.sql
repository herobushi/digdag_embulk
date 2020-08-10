DROP TABLE IF EXISTS dlg_test.digdag_test_from_digdag_query2;

CREATE TABLE
  dlg_test.digdag_test_from_digdag_query2
AS
  SELECT
    *
  FROM
    dlg_test.bq_table_test_1;