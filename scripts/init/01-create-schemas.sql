-- Create the data warehouse database if it does not exist.
-- Note: CREATE DATABASE cannot run inside a transaction block in PostgreSQL.
SELECT 'CREATE DATABASE data_warehouse'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'data_warehouse')\gexec

-- Select / connect to the data warehouse database
\c data_warehouse

BEGIN;

-- Bronze: raw data as ingested from source systems
CREATE SCHEMA IF NOT EXISTS bronze;

-- Silver: cleansed, standardized, and normalized data
CREATE SCHEMA IF NOT EXISTS silver;

-- Gold: business-ready analytical models
CREATE SCHEMA IF NOT EXISTS gold;

COMMIT;
