USE ROLE ACCOUNTADMIN;

DROP PROCEDURE IF EXISTS PLATFORM_DB.PROVISION_ROUTINE.ALTER_RESOURCE_MONITOR_SQL_PROC (VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR) ;


USE ROLE SYSADMIN;
CREATE or REPLACE PROCEDURE PLATFORM_DB.PROVISION_ROUTINE.ALTER_RESOURCE_MONITOR_SQL_PROC (                           
    P_RM_NAME VARCHAR
   ,P_USER_COMMENT VARCHAR
   ,P_CREDIT_QUOTA VARCHAR
   ,P_FREQUENCY VARCHAR
   ,P_START_TIMESTAMP VARCHAR
   ,P_TENANT_NAME VARCHAR
) 

RETURNS ARRAY  NOT NULL
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
 DECLARE
   TENANT VARCHAR DEFAULT '';
   JOB_NAME VARCHAR DEFAULT '';
   JOB_ACTION VARCHAR DEFAULT '';
   IS_ERROR VARCHAR DEFAULT '';
   JOB_LOG_DESCRIPTION VARCHAR DEFAULT '';
   RM_EXCEPTION_PARAMETER  EXCEPTION;
   RM_ALTER_SQL VARCHAR DEFAULT '';

   LOG VARIANT DEFAULT '';
BEGIN
    IS_ERROR := '0';
    
    TENANT := P_TENANT_NAME;

    RM_ALTER_SQL :='';
     --CREDIT_QUOTA = ' || P_CREDIT_QUOTA  || ' FREQUENCY = ' || P_FREQUENCY || ' START_TIMESTAMP = ' ||  P_START_TIMESTAMP ||

    IF ( NULLIF(TRIM(P_CREDIT_QUOTA ), '') IS NOT NULL) THEN
        RM_ALTER_SQL:= RM_ALTER_SQL || ' CREDIT_QUOTA = '||P_CREDIT_QUOTA ;
    END IF;
    
    IF (NULLIF(TRIM(P_FREQUENCY), '') IS NOT NULL) THEN
        RM_ALTER_SQL:= RM_ALTER_SQL || ' FREQUENCY = ' ||P_FREQUENCY  ;
    END IF;
    IF (NULLIF(TRIM(P_START_TIMESTAMP), '') IS NOT NULL) THEN
        RM_ALTER_SQL:= RM_ALTER_SQL || ' START_TIMESTAMP = ' ||P_START_TIMESTAMP;      
    END IF;

    RM_ALTER_SQL := 'ALTER RESOURCE MONITOR '||P_RM_NAME || ' SET '||RM_ALTER_SQL;

    EXECUTE IMMEDIATE RM_ALTER_SQL;
    
    JOB_LOG_DESCRIPTION := ' -- USER COMMENT: ' || P_USER_COMMENT  || '-- ' ||' RESOURCE MONITOR ALTERED : ' || P_RM_NAME || ' SQL: \n' || RM_ALTER_SQL || ';';
    RETURN ARRAY_CONSTRUCT(:IS_ERROR,:JOB_LOG_DESCRIPTION)  ;

EXCEPTION

  
  WHEN RM_EXCEPTION_PARAMETER  THEN
      IS_ERROR := '1';
      JOB_LOG_DESCRIPTION := 'ERROR: INVALID PARAMETERS' || P_RM_NAME || ' COMMENT: ' || P_USER_COMMENT;
      RETURN ARRAY_CONSTRUCT(:IS_ERROR,:JOB_LOG_DESCRIPTION)  ;

  WHEN OTHER THEN
    IS_ERROR := '1';
    JOB_LOG_DESCRIPTION := 'SQLCODE:' || SQLCODE || ' SQLERRM:' || SQLERRM || ' SQLSTATE:' ||SQLSTATE;
    RETURN ARRAY_CONSTRUCT(:IS_ERROR,:JOB_LOG_DESCRIPTION)  ;

END;
$$;

GRANT OWNERSHIP ON PROCEDURE PLATFORM_DB.PROVISION_ROUTINE.ALTER_RESOURCE_MONITOR_SQL_PROC(VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR) to role ACCOUNTADMIN;
USE ROLE ACCOUNTADMIN;
GRANT usage on procedure PLATFORM_DB.PROVISION_ROUTINE.ALTER_RESOURCE_MONITOR_SQL_PROC(VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR) to role SYSADMIN;
