/*
===============================================================================
Load Script: Bronze Layer (Source -> Bronze) — PostgreSQL
===============================================================================
Script Purpose:
  Loads data into the 'bronze' schema from external CSV files.
  - Truncates bronze tables before loading
  - Uses COPY to load CSV files into bronze tables (raw, as-is)

Prerequisites:
  - Datasets mounted at /datasets inside the Postgres container
  - Bronze tables already created (scripts/bronze/ddl_bronze.sql)

Usage:
  CALL bronze.load_bronze();
===============================================================================
*/

CREATE OR REPLACE PROCEDURE bronze.load_bronze()
LANGUAGE plpgsql
AS $$
DECLARE
    start_time TIMESTAMP;
    end_time TIMESTAMP;
    batch_start_time TIMESTAMP;
    batch_end_time TIMESTAMP;
BEGIN
    batch_start_time := clock_timestamp();

    RAISE NOTICE '================================================';
    RAISE NOTICE 'Loading Bronze Layer';
    RAISE NOTICE '================================================';

    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE 'Loading CRM Tables';
    RAISE NOTICE '------------------------------------------------';

    -- crm_cust_info
    start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: bronze.crm_cust_info';
    TRUNCATE TABLE bronze.crm_cust_info;
    RAISE NOTICE '>> Inserting Data Into: bronze.crm_cust_info';
    -- CSV treats '' as NULL by default; keep text columns as empty strings
    COPY bronze.crm_cust_info
    FROM '/datasets/source_crm/cust_info.csv'
    WITH (
        FORMAT csv,
        HEADER true,
        NULL '',
        FORCE_NOT_NULL (cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr)
    );
    end_time := clock_timestamp();
    RAISE NOTICE '>> Load Duration: % seconds',
        EXTRACT(EPOCH FROM (end_time - start_time))::INT;
    RAISE NOTICE '>> -------------';

    -- crm_prd_info
    start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: bronze.crm_prd_info';
    TRUNCATE TABLE bronze.crm_prd_info;
    RAISE NOTICE '>> Inserting Data Into: bronze.crm_prd_info';
    COPY bronze.crm_prd_info
    FROM '/datasets/source_crm/prd_info.csv'
    WITH (
        FORMAT csv,
        HEADER true,
        NULL '',
        FORCE_NOT_NULL (prd_key, prd_nm, prd_line)
    );
    end_time := clock_timestamp();
    RAISE NOTICE '>> Load Duration: % seconds',
        EXTRACT(EPOCH FROM (end_time - start_time))::INT;
    RAISE NOTICE '>> -------------';

    -- crm_sales_details
    start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: bronze.crm_sales_details';
    TRUNCATE TABLE bronze.crm_sales_details;
    RAISE NOTICE '>> Inserting Data Into: bronze.crm_sales_details';
    COPY bronze.crm_sales_details
    FROM '/datasets/source_crm/sales_details.csv'
    WITH (
        FORMAT csv,
        HEADER true,
        NULL '',
        FORCE_NOT_NULL (sls_ord_num, sls_prd_key)
    );
    end_time := clock_timestamp();
    RAISE NOTICE '>> Load Duration: % seconds',
        EXTRACT(EPOCH FROM (end_time - start_time))::INT;
    RAISE NOTICE '>> -------------';

    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE 'Loading ERP Tables';
    RAISE NOTICE '------------------------------------------------';

    -- erp_loc_a101
    start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: bronze.erp_loc_a101';
    TRUNCATE TABLE bronze.erp_loc_a101;
    RAISE NOTICE '>> Inserting Data Into: bronze.erp_loc_a101';
    COPY bronze.erp_loc_a101
    FROM '/datasets/source_erp/LOC_A101.csv'
    WITH (
        FORMAT csv,
        HEADER true,
        NULL '',
        FORCE_NOT_NULL (cid, cntry)
    );
    end_time := clock_timestamp();
    RAISE NOTICE '>> Load Duration: % seconds',
        EXTRACT(EPOCH FROM (end_time - start_time))::INT;
    RAISE NOTICE '>> -------------';

    -- erp_cust_az12
    start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: bronze.erp_cust_az12';
    TRUNCATE TABLE bronze.erp_cust_az12;
    RAISE NOTICE '>> Inserting Data Into: bronze.erp_cust_az12';
    COPY bronze.erp_cust_az12
    FROM '/datasets/source_erp/CUST_AZ12.csv'
    WITH (
        FORMAT csv,
        HEADER true,
        NULL '',
        FORCE_NOT_NULL (cid, gen)
    );
    end_time := clock_timestamp();
    RAISE NOTICE '>> Load Duration: % seconds',
        EXTRACT(EPOCH FROM (end_time - start_time))::INT;
    RAISE NOTICE '>> -------------';

    -- erp_px_cat_g1v2
    start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: bronze.erp_px_cat_g1v2';
    TRUNCATE TABLE bronze.erp_px_cat_g1v2;
    RAISE NOTICE '>> Inserting Data Into: bronze.erp_px_cat_g1v2';
    COPY bronze.erp_px_cat_g1v2
    FROM '/datasets/source_erp/PX_CAT_G1V2.csv'
    WITH (
        FORMAT csv,
        HEADER true,
        NULL '',
        FORCE_NOT_NULL (id, cat, subcat, maintenance)
    );
    end_time := clock_timestamp();
    RAISE NOTICE '>> Load Duration: % seconds',
        EXTRACT(EPOCH FROM (end_time - start_time))::INT;
    RAISE NOTICE '>> -------------';

    batch_end_time := clock_timestamp();
    RAISE NOTICE '==========================================';
    RAISE NOTICE 'Loading Bronze Layer is Completed';
    RAISE NOTICE ' - Total Load Duration: % seconds',
        EXTRACT(EPOCH FROM (batch_end_time - batch_start_time))::INT;
    RAISE NOTICE '==========================================';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '==========================================';
        RAISE NOTICE 'ERROR OCCURED DURING LOADING BRONZE LAYER';
        RAISE NOTICE 'Error Message: %', SQLERRM;
        RAISE NOTICE 'Error State: %', SQLSTATE;
        RAISE NOTICE '==========================================';
        RAISE;
END;
$$;
