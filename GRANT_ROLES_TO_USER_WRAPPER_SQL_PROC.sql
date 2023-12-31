/*
     ROLE WRAPPER: ACTION - GRANT / REVOKE
*/

USE ROLE SYSADMIN;
CREATE OR REPLACE PROCEDURE PLATFORM_DB.PROVISION_ROUTINE.GRANT_ROLES_TO_USER_WRAPPER(
    P_ACTION VARCHAR,//1
    P_ROLE_NAME VARCHAR,//2
    P_USER_NAME VARCHAR,//3
    P_USER_COMMENT VARCHAR, //4
    P_TENANT_NAME VARCHAR //5
)

RETURNS VARIANT  NOT NULL
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$

DECLARE
    JOB_NAME VARCHAR DEFAULT '';
    JOB_ACTION VARCHAR DEFAULT '';
    TENANT VARCHAR DEFAULT '';
    IS_ERROR VARCHAR DEFAULT '';
    JOB_LOG_DESCRIPTION VARCHAR DEFAULT '';
    TENANT_EXCEPTION_PARAMETER EXCEPTION;
    WRAPPER_EXCEPTION EXCEPTION;
    INVALID_PARAMETERS_EXCEPTION EXCEPTION;
    ACTION_EXCEPTION EXCEPTION;
   
    SYSADMIN_SUFFIX VARCHAR DEFAULT '_SYSADMIN_ROLE';
    LOCAL_SYSADMIN_ROLE VARCHAR DEFAULT '';
    ROLE_NAME VARCHAR DEFAULT '';
    PERMISSION_EXISTS INTEGER DEFAULT 0;

    SP_RETURN_LOG VARCHAR DEFAULT '';
    LOG_AGG VARCHAR DEFAULT '';
    RETURN_LOG VARIANT DEFAULT '';
    LOG ARRAY DEFAULT [];
    LOGS VARCHAR DEFAULT '';

    ACCESS_ROLE VARCHAR DEFAULT '';
BEGIN
    JOB_NAME := 'GRANT_ROLES_TO_USER_WRAPPER';
    IS_ERROR := '0';
    
    IF(P_TENANT_NAME IS NULL OR TRIM(P_TENANT_NAME) ='') THEN
        RAISE TENANT_EXCEPTION_PARAMETER;
    END IF;
    
    TENANT := UPPER(P_TENANT_NAME);

    LOCAL_SYSADMIN_ROLE := TENANT || SYSADMIN_SUFFIX;
    

    IF (
        P_ACTION IS NULL OR TRIM(P_ACTION) = '' OR
        P_ROLE_NAME IS NULL OR TRIM(P_ROLE_NAME) = '' OR 
        P_USER_COMMENT IS NULL OR TRIM(P_USER_COMMENT) = '' OR 
        NOT IS_ROLE_IN_SESSION(LOCAL_SYSADMIN_ROLE)
       ) THEN
        RAISE INVALID_PARAMETERS_EXCEPTION;
    END IF;
    
    --CHECK USER'S CURRENT AVAILABLE ROLES [IF SYSADMIN THEN USE SYSADMIN, ELSE LOCAL_SYSADMIN_ROLE]
    IF(CONTAINS(REPLACE(CURRENT_AVAILABLE_ROLES(),SYSADMIN_SUFFIX,''),'SYSADMIN')) THEN
        ROLE_NAME := 'SYSADMIN';
    ELSE
        ROLE_NAME := LOCAL_SYSADMIN_ROLE;
    END IF;
    
    JOB_ACTION := UPPER(P_ACTION);

    -- Check if Tenant is part of the framework - Control Table
    TENANT := (SELECT TENANT_ABBREVIATION FROM PLATFORM_DB.PROVISION_APP.TENANT_LIST WHERE TENANT_ABBREVIATION = :TENANT AND ACTIVE = 'Y');

    IF(TENANT IS NULL) THEN
      RAISE TENANT_EXCEPTION_PARAMETER;
    END IF;

    PERMISSION_EXISTS := (SELECT
        CASE        
            WHEN EXISTS (SELECT 1 FROM PLATFORM_DB.PROVISION_APP.SP_CONTROL CTL 
                INNER JOIN PLATFORM_DB.PROVISION_APP.SP_LIST L ON L.SP_ID = CTL.SP_ID 
            WHERE CTL.ADMIN_ROLE = :ROLE_NAME AND L.SP_NAME = 'GRANT_ROLES_TO_USER_WRAPPER' AND L.SP_ACTION = :JOB_ACTION) THEN 1
        ELSE 0
    END AS PERMISSION_EXISTS);


    -- GRANT ROLEs TO USER
    IF (JOB_ACTION = 'GRANT' AND PERMISSION_EXISTS = 1) THEN
       LOG := (CALL PLATFORM_DB.PROVISION_ROUTINE.GRANT_ROLE_TO_USER_SQL_PROC(:P_ROLE_NAME, :P_USER_NAME,:P_USER_COMMENT,:P_TENANT_NAME));

       LOG_AGG := LOG_AGG || LOG[1];

       -- Error Check
        IF(LOG[0] = '1') THEN
            IS_ERROR := '1';
            RAISE WRAPPER_EXCEPTION;
        END IF;
       
       SP_RETURN_LOG := 'ROLES GRANTED: '||P_ROLE_NAME || ' TO ROLE ' || P_USER_NAME || ' COMMENT: ' || P_USER_COMMENT;
    
    -- REVOKE ROLEs FROM USER
    ELSEIF (JOB_ACTION = 'REVOKE' AND PERMISSION_EXISTS = 1) THEN
       LOG := (CALL PLATFORM_DB.PROVISION_ROUTINE.REVOKE_ROLE_FROM_USER_SQL_PROC(:P_ROLE_NAME, :P_USER_NAME,:P_USER_COMMENT,:P_TENANT_NAME));
       LOG_AGG := LOG_AGG || LOG[1];
       -- Error Check
        IF(LOG[0] = '1') THEN
            IS_ERROR := '1';
            RAISE WRAPPER_EXCEPTION;
        END IF;
    
        SP_RETURN_LOG := 'ROLES REVOKED: '||P_ROLE_NAME || ' FROM ROLE ' || P_USER_NAME || ' COMMENT: ' || P_USER_COMMENT;
        
    ELSE
       IS_ERROR := '1';
       LOG_AGG := LOG_AGG || 'INVALID ACTION';
       RAISE INVALID_PARAMETERS_EXCEPTION;
    END IF;
    
    RETURN_LOG := OBJECT_CONSTRUCT('tenant',:TENANT,'job_name',:JOB_NAME, 'job_log_description',:SP_RETURN_LOG, 'is_error', :IS_ERROR, 'action', :JOB_ACTION);
    CALL PLATFORM_DB.PROVISION_ROUTINE.LOG_JOB_DETAILS(OBJECT_CONSTRUCT('tenant',:TENANT,'job_name',:JOB_NAME, 'job_log_description',:LOG_AGG, 'is_error', :IS_ERROR, 'action', :JOB_ACTION));
    
    RETURN RETURN_LOG;

EXCEPTION
  WHEN INVALID_PARAMETERS_EXCEPTION  THEN
      IS_ERROR := '1';
      LOG_AGG := LOG_AGG || ' ERROR: INVALID PARAMETERS' ;
      RETURN_LOG := OBJECT_CONSTRUCT('tenant',:TENANT,'job_name',:JOB_NAME, 'job_log_description',:LOG_AGG, 'is_error', :IS_ERROR, 'action', :JOB_ACTION);
      CALL PLATFORM_DB.PROVISION_ROUTINE.LOG_JOB_DETAILS(:RETURN_LOG);
      RETURN RETURN_LOG;

  WHEN TENANT_EXCEPTION_PARAMETER  THEN
      IS_ERROR := '1';
      LOG_AGG := LOG_AGG || ' ERROR: COULD NOT RESOLVE TENANT' ;
      RETURN_LOG := OBJECT_CONSTRUCT('tenant',:TENANT,'job_name',:JOB_NAME, 'job_log_description',:LOG_AGG, 'is_error', :IS_ERROR, 'action', :JOB_ACTION);
      CALL PLATFORM_DB.PROVISION_ROUTINE.LOG_JOB_DETAILS(:RETURN_LOG);
      RETURN RETURN_LOG;
   
   WHEN WRAPPER_EXCEPTION  THEN
      IS_ERROR := '1';
      RETURN_LOG := OBJECT_CONSTRUCT('tenant',:TENANT,'job_name',:JOB_NAME, 'job_log_description',:LOG_AGG, 'is_error', :IS_ERROR, 'action', :JOB_ACTION);
      CALL PLATFORM_DB.PROVISION_ROUTINE.LOG_JOB_DETAILS(:RETURN_LOG);
      RETURN RETURN_LOG;
      
  WHEN OTHER THEN
      IS_ERROR := '1';
      LOG_AGG := LOG_AGG ||'SQLCODE:' || SQLCODE || ' SQLERRM:' || SQLERRM || ' SQLSTATE:' ||SQLSTATE || LOG_AGG;
      RETURN_LOG := OBJECT_CONSTRUCT('tenant',:TENANT,'job_name',:JOB_NAME, 'job_log_description',:LOG_AGG, 'is_error', :IS_ERROR, 'action', :JOB_ACTION);
      CALL PLATFORM_DB.PROVISION_ROUTINE.LOG_JOB_DETAILS(:RETURN_LOG);
      RETURN RETURN_LOG;

END;
$$;


GRANT USAGE ON PROCEDURE PLATFORM_DB.PROVISION_ROUTINE.GRANT_ROLES_TO_USER_WRAPPER(VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR) TO ROLE PLATFORM_DB_PROVISION_ROUTINE_USAGE_ROLE;
