
/*
--====================================================================
Quality Checks
--====================================================================
Script Purpose:
  This script performs quality checks to validate the integrity
  consistency, and accuracy of the gold layer. The checks ensure:
  -uniqueness of surrogate keys in diemension tables.
  -Referential integrity between fact and dimension tables.
  -Validation of relationships in the date model for analytical purpose

Usage Notes:
  -Run these checks after data loading silver layer
  -Investigate and resolve any discrepancies found during the checks
*/

--================================================================
--Checking gold.customer_key
--================================================================
-- Check for uniqueness of customer key in gold.dim_customers
--Expectation: no result
select 
	customer_key,
	count(*) AS duplicate_count
	from gold.dim_customers

	group by customer_key

	having count(*) >1

--============================================================
--Checking gold.product_key
--============================================================
-- Check for uniqueness of product key in gold.dim_products
--Expectation: no result

 
  select 
	product_key,
	count(*) AS duplicate_count
	from gold.dim_products

	group by product_key

	having count(*) >1



--============================================================
--Checking gold.fact_sales
--============================================================
-- check the data model connectivity between fact and dimensions

select *
from gold.fact_sales f
left join gold.dim_customers c
ON c.customer_key = f.customer_key
left join gold.dim_products p
ON p.product_key = f.product_key

where p.product_key is null
