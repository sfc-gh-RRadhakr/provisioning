
USE ROLE SYSADMIN;

CREATE or REPLACE PROCEDURE  PLATFORM_DB.PROVISION_ROUTINE.LOCK_USER_WRAPPER(
        P_USER_NAME VARCHAR,
        P_TICKET_NUMBER VARCHAR
        )
RETURNS ARRAY NOT NULL
LANGUAGE SQL
EXECUTE AS   OWNER
AS
$$
DECLARE

    JOB_NAME VARCHAR DEFAULT '';
    JOB_ACTION VARCHAR DEFAULT '';
    IS_ERROR VARCHAR DEFAULT '0';
    JOB_LOG_DESCRIPTION VARCHAR DEFAULT '';
    USER_SQL VARCHAR DEFAULT '';
    TICKET_TAG VARCHAR DEFAULT '';
    WRAPPER_EXCEPTION EXCEPTION;
    TICKET_NUMBER_EXCEPTION_PARAMETER EXCEPTION;
    LOG_AGG VARCHAR DEFAULT '';
    RETURN_LOG VARIANT DEFAULT '';
    LOG ARRAY DEFAULT [];
    LOGS VARCHAR DEFAULT '';
    NEW_COMMENT VARCHAR DEFAULT '';
    TENANT VARCHAR DEFAULT '';
BEGIN

    IS_ERROR := '0';
    JOB_NAME := 'LOCK_USER_WRAPPER';
    JOB_ACTION :=  'DISABLE';
    TENANT := 'ACCOUNT-LEVEL';

    IF (P_TICKET_NUMBER IS NULL OR TRIM(P_TICKET_NUMBER) = '') THEN
        RAISE TICKET_NUMBER_EXCEPTION_PARAMETER;
    ELSE
     TICKET_TAG := 'TICKET#:' || P_TICKET_NUMBER;
    END IF;


    LOG := (CALL PLATFORM_DB.PROVISION_ROUTINE.LOCK_USER_SQL_PROC(:P_USER_NAME ,:P_TICKET_NUMBER ));

    LOG_AGG := LOG_AGG || LOG[1];

    -- Error Check
    IF(LOG[0] = '1') THEN
        IS_ERROR := '1';
        RAISE WRAPPER_EXCEPTION;
    END IF;

    JOB_LOG_DESCRIPTION := '--USER ' || P_USER_NAME || ' DISABLED: TRUE';
    RETURN_LOG := OBJECT_CONSTRUCT('tenant',:TENANT,'job_name',:JOB_NAME, 'job_log_description',:JOB_LOG_DESCRIPTION, 'is_error', :IS_ERROR, 'action', :JOB_ACTION);
    CALL PLATFORM_DB.PROVISION_ROUTINE.LOG_JOB_DETAILS(OBJECT_CONSTRUCT('tenant',:TENANT,'job_name',:JOB_NAME, 'job_log_description',:LOG_AGG, 'is_error', :IS_ERROR, 'action', :JOB_ACTION));

    RETURN RETURN_LOG;

EXCEPTION
  WHEN TICKET_NUMBER_EXCEPTION_PARAMETER  THEN
      IS_ERROR := '1';
      LOG_AGG := LOG_AGG || ' ERROR: INVALID TICKET NUMBER PARAMETER' ;
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
    JOB_LOG_DESCRIPTION := 'SQLCODE:' || SQLCODE || ' SQLERRM:' || SQLERRM || ' SQLSTATE:' ||SQLSTATE || LOG_AGG;
      RETURN_LOG := OBJECT_CONSTRUCT('tenant','ACCOUNT-LEVEL','job_name',:JOB_NAME, 'job_log_description',:LOG_AGG, 'is_error', :IS_ERROR, 'action', :JOB_ACTION);


END;
$$;

grant USAGE on procedure PLATFORM_DB.PROVISION_ROUTINE.LOCK_USER_SQL_PROC (VARCHAR,VARCHAR) to ROLE PLATFORM_DB_PROVISION_ROUTINE_USAGE_ROLE;



grant USAGE on procedure PLATFORM_DB.PROVISION_ROUTINE.LOCK_USER_SQL_PROC (VARCHAR,VARCHAR) to ROLE PLATFORM_DB_PROVISION_ROUTINE_USAGE_ROLE;
