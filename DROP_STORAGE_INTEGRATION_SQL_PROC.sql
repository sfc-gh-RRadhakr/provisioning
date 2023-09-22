USE ROLE ACCOUNTADMIN;
DROP PROCEDURE IF EXISTS PLATFORM_DB.PROVISION_ROUTINE.DROP_STORAGE_INTEGRATION_SQL_PROC(VARCHAR,VARCHAR,VARCHAR) ;

USE ROLE SYSADMIN;

CREATE or REPLACE PROCEDURE PLATFORM_DB.PROVISION_ROUTINE.DROP_STORAGE_INTEGRATION_SQL_PROC (
        P_STORAGE_INTEGRATION_NAME VARCHAR,
        P_USER_COMMENT VARCHAR,
        P_TENANT_NAME VARCHAR)

RETURNS ARRAY NOT NULL
LANGUAGE SQL
EXECUTE AS   OWNER
AS
$$
DECLARE
    TENANT VARCHAR DEFAULT '';
    IS_ERROR VARCHAR DEFAULT '0';
    SI_SQL VARCHAR DEFAULT '';
    JOB_LOG_DESCRIPTION VARCHAR DEFAULT '';
    STORAGE_INTEGRATION_EXCEPTION EXCEPTION;

    LOG VARIANT DEFAULT '';

BEGIN
    TENANT := P_TENANT_NAME;

    IF (NULLIF(TRIM(P_STORAGE_INTEGRATION_NAME), '') IS NOT NULL) THEN
      SI_SQL := 'DROP STORAGE INTEGRATION '|| P_STORAGE_INTEGRATION_NAME || ' ;';
    
    ELSE 
        RAISE STORAGE_INTEGRATION_EXCEPTION;
    END IF;

    EXECUTE IMMEDIATE SI_SQL;
      
    JOB_LOG_DESCRIPTION :=  '-- STORAGE INTEGRATION DROPPED: ' || P_STORAGE_INTEGRATION_NAME || ' COMMENT: ' || P_USER_COMMENT || ' SQL: \n' || SI_SQL;
      
    RETURN ARRAY_CONSTRUCT(:IS_ERROR,:JOB_LOG_DESCRIPTION)  ;       

EXCEPTION

  WHEN STORAGE_INTEGRATION_EXCEPTION  THEN
    IS_ERROR := '1';
    JOB_LOG_DESCRIPTION := 'ERROR: INVALID PARAMETERS ' ||P_STORAGE_INTEGRATION_NAME || ' COMMENT: ' || P_USER_COMMENT;
    RETURN ARRAY_CONSTRUCT(:IS_ERROR,:JOB_LOG_DESCRIPTION)  ;

  WHEN OTHER THEN
    IS_ERROR := '1';
    JOB_LOG_DESCRIPTION := 'SQLCODE:' || SQLCODE || ' SQLERRM:' || SQLERRM || ' SQLSTATE:' ||SQLSTATE;
    RETURN ARRAY_CONSTRUCT(:IS_ERROR,:JOB_LOG_DESCRIPTION)  ;
END;
$$;

GRANT OWNERSHIP ON PROCEDURE PLATFORM_DB.PROVISION_ROUTINE.DROP_STORAGE_INTEGRATION_SQL_PROC(VARCHAR,VARCHAR,VARCHAR) TO ROLE ACCOUNTADMIN;
USE ROLE ACCOUNTADMIN;
GRANT USAGE ON PROCEDURE PLATFORM_DB.PROVISION_ROUTINE.DROP_STORAGE_INTEGRATION_SQL_PROC(VARCHAR,VARCHAR,VARCHAR) TO ROLE SYSADMIN;