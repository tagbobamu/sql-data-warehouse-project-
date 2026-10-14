/*
--========================================================================
DDL Script: Create Gold Views
--========================================================================
Script Purpose:
   This script creates views for the gold layer in the data warehouse.
   The gold layer represents the final dimentions and fact tables (star schema)
   Each view performe transformations and combines data from silver layer 
   to produce a clean, enriched, and business-ready dataset.

Usage:
 - These views can be queried directly for analytics reporting.

*/
--==========================================================================
-- Create Dimension: gold.dim_customers
--==========================================================================


IF OBJECT_ID ('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO
Create VIEW gold.dim_customers AS


select
	row_number() over (order by cst_id) AS customer_key,
	ci.cst_id AS customer_id,
	ci.cst_key AS  customer_number,
	ci.cst_firstname AS first_name,
	ci.cst_lastname AS last_name,
	la.cntry AS country,
	ci.cst_marital_status AS marital_status,
	
	
	
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr   ----crm is the master info
		ELSE Coalesce(ca.gen, 'n/a')
	END AS gender,
	ca.bdate AS birthday,
	ci.cst_create_date AS create_date

	
from silver.crm_cust_info ci
left join silver.erp_cust_az12 ca
ON        ci.cst_key = ca.cid
left join silver.erp_loc_a101 la
ON        ci.cst_key = la.cid




--==========================================================================
-- Create Dimension: gold.dim_products
--==========================================================================

IF OBJECT_ID ('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;


CREATE VIEW gold.dim_products AS
select 
	row_number() over (order by prd_start_dt,prd_key)AS product_key,
	pn.prd_id AS product_id,
	pn.prd_key AS product_number,
	pn.prd_nm AS product_name,
	pn.cat_id AS category_id,
	pc.cat AS category,
	pc.subcat AS subcategory,
	pc.maintenance,
	pn.prd_cost AS cost,
	pn.prd_line AS product_line,
	pn.prd_start_dt AS start_date
from silver.crm_prd_info pn

left join silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
where prd_end_dt is null



--==========================================================================
-- Create Fact: gold.fact_sales
--==========================================================================


IF OBJECT_ID ('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;

CREATE VIEW gold.fact_sales AS
select 
sd.sls_ord_num AS order_number,
pr.product_key,
cu.customer_key,
sd.sls_order_dt AS order_date,
sd.sls_ship_dt AS shipping_date,
sd.sls_due_dt AS due_date,
sd.sls_sales AS sales_amount,
sd.sls_quantity AS quantity,
sd.sls_price AS price

from silver.crm_sales_details sd

left join gold.dim_products pr
ON sd.sls_prd_key = pr.product_number
left join gold.dim_customers cu
ON sd.sls_cst_id = cu.customer_id
