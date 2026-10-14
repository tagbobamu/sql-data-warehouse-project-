/*
================================================================================
Quality Checks.
===============================================================================
Script Purpose:
    The script performs various quality fro data consistency, accuracy, and 
    standardization across the 'silver' schema. It includes checks for:
    --NULLs or duplicate in primary key.
    --unwanted spaces in string fiieds.
    --Data Standadization & Consistency
    -- Invalid Date ranges and order

Usage Notes:
  -Run these checks after loading silver layer.
  -Investigate and resolve any discrepancies found during the checks
-========================================================================
*/

--========================================================================
--Checking 'silver.crm_cust_info'
--==============================================
---Standadization & Consistency
---check for NULLs or duplicate in primary key
---Expectation: no result
      
      select cst_id, 
         Count(*)
        from silver.crm_cust_info
    	group by cst_id  
    	HAVING Count(*) > 1 OR cst_id IS NULL

-------check for unwanted spaces
-------Expectation: no result

        select cst_key 
 
        from silver.crm_cust_info
        where cst_key != TRIM(cst_key)



---=============================================
--Checking 'silver.crm_prd_info'
--==============================================
---Standadization & Consistency
---Expectation: no result
       select distinct
       prd_line
      from silver.crm_prd_info

  ----check for invalid Date orders (start date > end date (
 ---Expectation: no result
       select * 
         
        from silver.crm_prd_info
        where prd_end_dt < prd_start_dt
         
                 
---=============================================
--Checking 'silver.crm_sales_details'
--==============================================
----check for Invalid Dates
----- Expectation: No Ivalid Dates

    SELECT
    nullif(sls_due_dt,0) AS sls_due_dt
    FROM bronze.crm_sales_details
    WHERE sls_due_dt <= 0
    OR LEN(sls_due_dt) != 8
    OR sls_due_dt >20500101
    OR sls_due_dt <19000101;

  ----check for invalid orders (Order dates > shipping/ due dates

    select * 
    from silver.crm_sales_details
    where sls_order_dt > sls_ship_dt 
    or sls_order_dt > sls_due_dt
      

---=============================================
--Checking 'silver.erp_cust_aZ12'
--==============================================
---Identify Out of Range Date
---Expectation: Birthdates between 1924-01-01 and today

        select distinct
        bdate
        from silver.erp_cust_aZ12
        where bdate < '1924-01-01' 
        OR bdate > GETDATE();



---Standadization & Consistency
      select distinct
       gen
      from silver.erp_cust_aZ12


---=============================================
--Checking 'silver.erp_loc_a101'
--==============================================
---Standadization & Consistency
---Expectation: no result

select distinct

cntry
from silver.erp_loc_a101

order by cntry;


---=============================================
--Checking 'silver.erp_px_cat_g1v2'
--==============================================
---check for unwanted spaces
---Expectation: no result

select * from silver.erp_px_cat_g1v2
where cat != TRIM(cat) 
OR subcat != TRIM(subcat) 
OR maintenance != TRIM(maintenance)

 
   select distinct
   maintenance  
   from .bronze.erp_px_cat_g1v2
