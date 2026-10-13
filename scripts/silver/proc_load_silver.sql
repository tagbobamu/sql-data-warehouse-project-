
/*
=================================================================================================================
Stored Procedure: Load Silver(Bronze -> Silver)
=================================================================================================================
Script Purpose:
This stored procedure performs the ETL (Extract ,Transform , Load) process to 
populate the 'silver' schema tables from the 'bronze'schema.
Actions Performed:
  - Truncates Silver tables.
  - Inserts transformed and cleansed data from Bronze into silver tables.
 Parameters:
 None.
 This stored procedure does not accept any parameters or return any values.

Usage Examples:
  EXEC Silver.load_silver;
==================================================================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS

BEGIN

    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME
        BEGIN TRY
            PRINT '==============================================================================================================';
            PRINT 'Loading Silver Layer';
            PRINT '==============================================================================================================';


            PRINT ' --------------------------------------------------------------------------------------------------------------';
            PRINT 'Loading CRM Tables';
            PRINT ' --------------------------------------------------------------------------------------------------------------';
            set @batch_start_time = GETDATE();
            SET @start_time = GETDATE();


    PRINT 'Truncate Table silver.crm_cust_info;';

    Truncate Table silver.crm_cust_info;

    PRINT '>> Insert Data Into: silver.crm_cust_info';

    INSERT INTO silver.crm_cust_info(

	    cst_id,
	    cst_key,
	    cst_firstname,
      
	    cst_lastname,
	    cst_marital_status,
      
	    cst_gndr,
	    cst_create_date
      

    )
    select 
	    cst_id,
	    cst_key,
	    TRIM(cst_firstname) AS cst_firstname,
	    TRIM(cst_lastname) AS cst_lastname,


	    CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
		     WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
		     ELSE 'n/a'
		     END cst_marital_status,

	    CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
		     WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
		     ELSE 'n/a'
		     END cst_gndr,
		     cst_create_date
	    FROM (

	    select 
	    *,
	    Row_number() OVER (Partition by cst_id order by cst_create_date DESC) AS flag_last

	    from bronze.crm_cust_info
	    where cst_id is not null
	    )t
	    where flag_last =1

                SET @end_time = GETDATE();

                PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
                PRINT '>> -------------';
 
            SET @start_time = GETDATE();

	    ------silver.crm_prd_info

	    PRINT 'Truncate Table silver.crm_prd_info;';

	    Truncate Table silver.crm_prd_info;

	    PRINT '>> Insert Data Into: silver.crm_prd_info';


	    insert into silver.crm_prd_info(

            prd_id ,
            cat_id ,
            prd_key,
            prd_nm ,
            prd_cost,
            prd_line,
            prd_start_dt,
            prd_end_dt 



    )


       SELECT
       prd_id,
  
       replace(substring(prd_key,1,5),'-', '_') AS cat_id,

       substring(prd_key,7, LEN(prd_key)) AS prd_key,
       prd_nm,

       isnull(prd_cost,0) AS prd_cost,

  
       case UPPER(TRIM(prd_line)) 
		    when  'M' THEN 'Mountain'
		    when  'R' THEN 'Road'
		    when  'S' THEN 'Other Sales'
		    when  'T' THEN 'Touring'
		    ELSE 'n/a'
       END AS prd_line,

      cast(prd_start_dt AS DATE) AS prd_start_dt,
      Cast(lead(prd_start_dt) over(partition by prd_key order by prd_start_dt)-1 AS DATE) AS prd_end_dt
  

      FROM bronze.crm_prd_info

         SET @end_time = GETDATE();
                PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
                PRINT '>> -------------';
 
            SET @start_time = GETDATE();

          ---------silver.crm_sales_details

         PRINT 'Truncate Table silver.crm_sales_details;';

	     Truncate Table silver.crm_sales_details;

	     PRINT '>> Insert Data Into: silver.crm_sales_details';


      insert into silver.crm_sales_details(
            sls_ord_num  ,
            sls_prd_key ,
            sls_cst_id ,
            sls_order_dt ,
            sls_ship_dt ,
            sls_due_dt ,
            sls_sales ,
            sls_quantity ,
            sls_price )



      select 

            sls_ord_num ,
            sls_prd_key ,
            sls_cst_id ,
        
            CASE WHEN sls_order_dt = 0 or LEN(sls_order_dt) != 8 THEN NULL
            ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
            END AS sls_order_dt,
        

            CASE WHEN sls_ship_dt = 0 or LEN(sls_ship_dt) != 8 THEN NULL
            ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
            END AS sls_ship_dt,

     

            CASE WHEN sls_due_dt = 0 or LEN(sls_due_dt) != 8 THEN NULL
            ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
            END AS sls_due_dt,
            CASE WHEN sls_sales is null or sls_sales <= 0 or sls_sales != sls_quantity * ABS(sls_price)
                THEN sls_quantity * ABS(sls_price)
                ELSE  sls_sales
                END AS sls_sales,
       
            sls_quantity ,
             CASE WHEN sls_price is null or sls_price <= 0
                THEN sls_sales/nullif(sls_quantity, 0)

                ELSE sls_price

                END as sls_price
        

          from bronze.crm_sales_details

                SET @end_time = GETDATE();

                PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
                PRINT '>> -------------';
 
                 SET @start_time = GETDATE();

                 PRINT ' --------------------------------------------------------------------------------------------------------------';
                 PRINT 'Loading ERP Tables';
                 PRINT ' --------------------------------------------------------------------------------------------------------------';
          --------------silver.erp_cust_aZ12

         PRINT 'Truncate Table silver.erp_cust_aZ12;';

	     Truncate Table silver.erp_cust_aZ12;

	     PRINT '>> Insert Data Into: silver.erp_cust_aZ12';

          INSERT INTO silver.erp_cust_aZ12
        (
          cid ,
          bdate ,
          gen 
    
        )

        select 
        Case when cid like 'NAS%' then substring(cid , 4, LEN(cid))
            ELSE cid
            END cid,
        CASE WHEN bdate > GETDATE() THEN NULL
             ELSE  bdate 
             END AS bdate,
        CASE WHEN UPPER(Trim(gen))IN ('F', 'FEMALE' ) Then 'Female'
             When UPPER(Trim(gen))IN ('M', 'MALE') then 'Male'

             ELSE 'n/a'
             END AS gen
         
        from bronze.erp_cust_aZ12

               SET @end_time = GETDATE();
                PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
                PRINT '>> -------------';
 
                 SET @start_time = GETDATE();

        --------silver.erp_loc_a101

        PRINT 'Truncate Table silver.erp_loc_a101;';

	     Truncate Table silver.erp_loc_a101;

	     PRINT '>> Insert Data Into: silver.erp_loc_a101';

        insert into  silver.erp_loc_a101 (
         cid,
         cntry
             )


        select 

        REPLACE(cid,'-', '') AS cid,
         CASE WHEN UPPER(TRIM(cntry)) IN ('US', 'USA') THEN 'United States'
               WHEN UPPER(TRIM(cntry)) = 'DE' THEN 'Germany'
               WHEN  UPPER(TRIM(cntry))  IS NULL or  cntry = '' Then 'n/a'
               ELSE  UPPER(TRIM(cntry))
               END AS cntry
         
        FROM  bronze.erp_loc_a101

                SET @end_time = GETDATE();
                PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
                PRINT '>> -------------';
 
                SET @start_time = GETDATE();

        ---------silver.erp_px_cat_g1v2

         PRINT 'Truncate Table silver.erp_px_cat_g1v2;';

	     Truncate Table silver.erp_px_cat_g1v2;

	     PRINT '>> Insert Data Into: silver.erp_px_cat_g1v2';


        INSERT INTO silver.erp_px_cat_g1v2
            (
              id,
              cat,
              subcat,
            maintenance

            )

            SELECT  
            id,
            cat,
            subcat,
            maintenance

            FROM bronze.erp_px_cat_g1v2



               SET @end_time = GETDATE();


                PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
                PRINT '>> -------------';
                

                SET @batch_end_time = GETDATE();

                PRINT '=============================================================================================================';
                PRINT 'Loading Silver Layer is Completed.'
                PRINT '  - Total Load Duration:' + Cast(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS Varchar) + 'Seconds';
                PRINT '=============================================================================================================';


                END TRY
                BEGIN CATCH
                PRINT '==============================================================================================================';
                PRINT 'ERROR OCCURED DURING LOADING SILVER LAYER';
                PRINT 'ERROR Message' + ERROR_MESSAGE();
                PRINT 'ERROR Message' + CAST(ERROR_NUMBER()AS NVARCHAR);
                PRINT 'ERROR Message' + CAST(ERROR_STATE() AS NVARCHAR);
                PRINT '==============================================================================================================';

                END CATCH
END


