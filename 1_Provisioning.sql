USE ROLE SYSADMIN;
CREATE DATABASE IF NOT EXISTS PLATFORM_DB;
CREATE SCHEMA IF NOT EXISTS PLATFORM_DB.PROVISION_APP;--  To hold tables
CREATE SCHEMA IF NOT EXISTS PLATFORM_DB.PROVISION_ROUTINE; -- To holds procs
CREATE SCHEMA IF NOT EXISTS PLATFORM_DB.PROVISION; -- To hold views

USE ROLE SECURITYADMIN;
CREATE ROLE IF NOT EXISTS PLATFORM_DB_PROVISION_ROUTINE_USAGE_ROLE;
GRANT ROLE  PLATFORM_DB_PROVISION_ROUTINE_USAGE_ROLE TO ROLE SYSADMIN;

GRANT USAGE ON DATABASE  PLATFORM_DB TO ROLE PLATFORM_DB_PROVISION_ROUTINE_USAGE_ROLE;
GRANT USAGE ON SCHEMA    PLATFORM_DB.PROVISION_ROUTINE TO ROLE PLATFORM_DB_PROVISION_ROUTINE_USAGE_ROLE;



-- Warehouse
USE ROLE SYSADMIN;
CREATE WAREHOUSE IF NOT EXISTS  PROVISION_ADHOC_VWH 
WAREHOUSE_SIZE = 'XSMALL'
AUTO_SUSPEND = 60
COMMENT ='For Platform Team';

USE ROLE SECURITYADMIN;
CREATE ROLE IF NOT EXISTS PROVISION_ADHOC_VWH_ROLE;
GRANT ROLE  PROVISION_ADHOC_VWH_ROLE TO ROLE SYSADMIN;



