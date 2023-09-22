USE ROLE ACCOUNTADMIN;
DROP PROCEDURE IF EXISTS PLATFORM_DB.PROVISION_ROUTINE.DROP_RESOURCE_MONITOR_SQL_PROC (VARCHAR,VARCHAR,VARCHAR);


USE ROLE SYSADMIN;

CREATE or REPLACE PROCEDURE PLATFORM_DB.PROVISION_ROUTINE.DROP_RESOURCE_MONITOR_SQL_PROC (
        P_RM_NAME VARCHAR,
        P_USER_COMMENT VARCHAR,
        P_TENANT_NAME VARCHAR)

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
    RM_SQL VARCHAR DEFAULT '';
    JOB_LOG_DESCRIPTION VARCHAR DEFAULT '';
    DB_EXCEPTION_PARAMETER EXCEPTION;

    LOG VARIANT DEFAULT '';

BEGIN
    JOB_NAME := 'RESOURCE_MONITOR_WRAPPER';
    JOB_ACTION := 'DROP';
    TENANT := P_TENANT_NAME;
      
      IF (ENDSWITH(UPPER(P_RM_NAME),'RM')) THEN
      RM_SQL := 'DROP RESOURCE MONITOR IF EXISTS '|| P_RM_NAME  ;
      EXECUTE IMMEDIATE RM_SQL;
      
      JOB_LOG_DESCRIPTION :=  '-- RESOURCE MONITOR DROPPED: ' || P_RM_NAME ||' COMMENT: ' || P_USER_COMMENT || ' DROP_SQL: \n' || RM_SQL;
      RETURN ARRAY_CONSTRUCT(:IS_ERROR,:JOB_LOG_DESCRIPTION)  ;
      
    ELSE
        RAISE DB_EXCEPTION_PARAMETER;
    END IF;
EXCEPTION

  WHEN DB_EXCEPTION_PARAMETER  THEN
    IS_ERROR := '1';
    JOB_LOG_DESCRIPTION := 'ERROR: INVALID NAMING CONVENTION ' ||P_RM_NAME || ' COMMENT: ' || P_USER_COMMENT;
    RETURN ARRAY_CONSTRUCT(:IS_ERROR,:JOB_LOG_DESCRIPTION)  ; 

  WHEN OTHER THEN
    IS_ERROR := '1';
    JOB_LOG_DESCRIPTION := 'SQLCODE:' || SQLCODE || ' SQLERRM:' || SQLERRM || ' SQLSTATE:' ||SQLSTATE;
    RETURN ARRAY_CONSTRUCT(:IS_ERROR,:JOB_LOG_DESCRIPTION)  ;
END;
$$;

GRANT OWNERSHIP ON PROCEDURE PLATFORM_DB.PROVISION_ROUTINE.DROP_RESOURCE_MONITOR_SQL_PROC (VARCHAR,VARCHAR,VARCHAR) TO ROLE ACCOUNTADMIN;

USE ROLE ACCOUNTADMIN;
GRANT USAGE ON PROCEDURE PLATFORM_DB.PROVISION_ROUTINE.DROP_RESOURCE_MONITOR_SQL_PROC (VARCHAR,VARCHAR,VARCHAR) TO ROLE SYSADMIN;

