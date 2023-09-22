USE ROLE SECURITYADMIN;
drop procedure if exists PLATFORM_DB.PROVISION_ROUTINE.DROP_ROLE_SQL_PROC(VARCHAR,VARCHAR);

USE ROLE SYSADMIN;
CREATE OR REPLACE PROCEDURE PLATFORM_DB.PROVISION_ROUTINE.DROP_ROLE_SQL_PROC (ROLE_NAME VARCHAR, TENANT_NAME_PARAMETER VARCHAR)
RETURNS ARRAY  NOT NULL
LANGUAGE SQL
EXECUTE AS   OWNER
AS
$$
DECLARE
   TENANT VARCHAR DEFAULT '';
   JOB_NAME VARCHAR DEFAULT '';
   JOB_ACTION VARCHAR DEFAULT '';
   IS_ERROR VARCHAR DEFAULT '0';
   JOB_LOG_DESCRIPTION VARCHAR DEFAULT '';
   ROLE_NAME_EXCEPTION EXCEPTION;
   AR_PREFIX STRING DEFAULT '_';
   LOG VARIANT DEFAULT '';

BEGIN
    JOB_NAME := 'DROP_ROLE_SQL_PROC';
    --JOB_ACTION := ACTION;
    IS_ERROR := '0';
    TENANT := TENANT_NAME_PARAMETER;

  //IF (  (ENDSWITH(ROLE_NAME,'_AR') AND STARTSWITH(ROLE_NAME,AR_PREFIX||TENANT_NAME_PARAMETER)) OR (ENDSWITH(ROLE_NAME,'_FR') AND STARTSWITH(ROLE_NAME,TENANT_NAME_PARAMETER) ) ) THEN

  IF (CONTAINS(ROLE_NAME, '_ROLE')) THEN
    EXECUTE IMMEDIATE 'DROP ROLE IF EXISTS '|| ROLE_NAME ;
    JOB_LOG_DESCRIPTION :=  '-- ROLE DROPPED: \n'|| 'DROP ROLE '|| ROLE_NAME || ';' ;
      RETURN ARRAY_CONSTRUCT(:IS_ERROR,:JOB_LOG_DESCRIPTION)  ;
  ELSE
    RAISE ROLE_NAME_EXCEPTION;
  END IF ;
EXCEPTION
  
  WHEN ROLE_NAME_EXCEPTION  THEN
    IS_ERROR := '1';
    JOB_LOG_DESCRIPTION := 'ERROR: INVALID ROLE' ;
      RETURN ARRAY_CONSTRUCT(:IS_ERROR,:JOB_LOG_DESCRIPTION)  ;
  WHEN OTHER THEN
      IS_ERROR := '1';
      JOB_LOG_DESCRIPTION := 'SQLCODE:' || SQLCODE || ' SQLERRM:' || SQLERRM || ' SQLSTATE:' ||SQLSTATE;
      RETURN ARRAY_CONSTRUCT(:IS_ERROR,:JOB_LOG_DESCRIPTION)  ;

END;

$$;
grant ownership on procedure PLATFORM_DB.PROVISION_ROUTINE.DROP_ROLE_SQL_PROC(VARCHAR,VARCHAR) to ROLE SECURITYADMIN;
USE ROLE SECURITYADMIN;
grant usage on procedure PLATFORM_DB.PROVISION_ROUTINE.DROP_ROLE_SQL_PROC(VARCHAR,VARCHAR) to ROLE SYSADMIN;