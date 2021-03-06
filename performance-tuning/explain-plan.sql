-- >---
-- >title: Oracle Explain Plan
-- >metadata:
-- >    description: 'Oracle Explain Plan'
-- >    keywords: 'Oracle Explain Plan, example code, tutorials'
-- >author: Venkata Bhattaram / tinitiate.com
-- >code-alias: explain-plan
-- >slug: oracle/plsql/explain-plan
-- >---

-- ># Oracle Explain Plan
-- >* EXPLAIN PLAN is the the process adopted by Oracle Optimizer for a query that 
-- >  is executed.
-- >* It displays the execution plans chosen by the Oracle optimizer for SELECT, 
-- >  INSERT, UPDATE and DELETE statements
-- >* The order of execution of a query roughly has the following steps:
-- >  * Make sure the QUERY syntax is valid
-- >  * Make sure all the DB objects (Tables, Views, Functions) referred to in the 
-- >    "syntaxtically correct query" are accessible in the current executing schema.
-- >  * Transform the query by adjusting or rewriting the query-subquery.
-- >  * Identify the optimal execution path RBO or CBO and execute the query.

-- >## Setting Up and Viewing Explain Plan

-- >### Step 1.
-- >* In SQLPLUS run the below statement
-- >```sql
explain plan
set statement_id = 'ti_ex_plan_1' for 
select *
from   ti_emp;
-- >```

-- >### Step 2.
-- >* In the same session of SQLPLUS run the below statement
-- >
select plan_table_output 
from   table(dbms_xplan.display(null, 'ti_ex_plan_1','BASIC'));
-- >```

-- >## OPTIMIZER MODE
-- >* OPTIMIZER_MODE establishes the default behavior for choosing an optimization 
-- >  approach for the instance.
-- >* first_rows and first_rows_n (Where n is a number)
-- > The optimizer uses a mix of costs and heuristics to find a best plan for fast 
-- > delivery of the first few rows.
-- >*all_rows
-- > This is the default cost-based approach for all SQL statements in the session 
-- > and optimizes with a goal of minimum resource usage to execute a SQL statement.
-- >```sql
-- Query to get the current 'OPTIMIZER_MODE' of the session
select value
from   v$parameter 
where  name='optimizer_mode';

-- Statement to set OPTIMIZER MODE in a session
-- using the alter session set optimizer_mode

-- FIRST_ROWS
-- Tries to retrive rows in the fastest possible response time
alter session set optimizer_mode=first_rows_20;
alter session set optimizer_mode=first_rows;

-- CHOOSE or ALL_ROWS
-- This is the default CBO both are same, they use statistics, Indexes, 
-- Partitioning Pruning as available, This is the setting where Oracle DB takes the 
-- decision on execution plans
alter session set optimizer_mode=all_rows;
alter session set optimizer_mode=choose;

-- RULE BASED OPTIMIZER
-- RBO does not use the table index statistics
alter session set optimizer_mode=rule;

-- >```


-- >## Check index statistics status
-- >``sql
-- We can check the index statistics details for an index using the following 
-- statements,
-- Make sure there is data in the table of the index.
analyze index tinitiate.large_table_with_index_idx1 validate structure;

-- The above command followed by the index_stats view, which has only ONE row, 
-- for the index preceeding this statement for which the 
-- 'analyze index <schema-name>.<index-name> validate structure;'
-- is executed.
select *
from   index_stats;

--First rule of thumb:	If the index has height greater than four, rebuild the index. For most indexes, the height of the index will be quite low, i.e. one or two. There have been examples of an index on a 3 million-row table that had height three. An index with height greater than four may need to be rebuilt as this might indicate a tree structure with too many deleted leaf entries. This can lead to unnecessary database block reads of the index. It is helpful to know the data structure for the table and index. Most times, the index height should be two or less, but there are exceptions.
-- Second rule of thumb:	The deleted leaf rows should be less than 20% of the total number of leaf rows. An excessive number of deleted leaf rows indicates that a high number of deletes or updates have occurred to the index column(s). The index should be rebuilt to better balance the index entries in the tree. The INDEX_STATS table can be queried to determine if there are excessive deleted leaf rows in relation to the total number of leaf rows. 

-- >## Managing and Maintaining table indexes
-- >* Gather the statistics of all the indexs on a table
-- >```sql
-- The below is used to gather the statistics of all the indexs on a table
begin
  dbms_stats.gather_table_stats(
     ownname=>'TINITIATE'
    ,tabname=>'LARGE_TABLE_WITH_INDEX'
    -- This varies for all table rows, this is the recommended in there is 
    -- no set sample size
    ,estimate_percent=>dbms_stats.auto_sample_size 
    ,cascade=>true);
end;
/
-- >```
-- >* Gather the statistics of all the tables in a schema
-- >```sql
-- Code for gather the statistics of all the indexs of all tables in a schema
begin
  dbms_stats.gather_schema_stats(
     ownname=>'TINITIATE'
     -- This varies for all table rows, this is the recommended in there is 
     -- no set sample size
    ,estimate_percent=>dbms_stats.auto_sample_size);
end;
/
-- >```
