
USE ROLE SECURITYADMIN;
--DROP PROCEDURE PLATFORM_DB.PROVISION_ROUTINE.DISABLE_USER_SQL_PROC (VARCHAR,VARCHAR,VARCHAR);
drop procedure if exists PLATFORM_DB.PROVISION_ROUTINE.RESET_USER_PASSWORD_SQL_PROC (VARCHAR,VARCHAR,VARCHAR);

USE ROLE SYSADMIN;

CREATE or REPLACE PROCEDURE  PLATFORM_DB.PROVISION_ROUTINE.RESET_USER_PASSWORD_SQL_PROC(
        P_USER_NAME VARCHAR,
        P_PASSWORD VARCHAR,
        P_TENANT_NAME VARCHAR
        )

RETURNS ARRAY NOT NULL
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
    TENANT_EXCEPTION_PARAMETER EXCEPTION;
    ROLE_NAME_EXCEPTION EXCEPTION;
    USER_SQL VARCHAR DEFAULT '';

    LOG VARIANT DEFAULT '';

BEGIN

    IS_ERROR := '0';
    TENANT := P_TENANT_NAME;
  
    USER_SQL :=  'ALTER USER ' || P_USER_NAME || ' SET PASSWORD = ''' || P_PASSWORD || ''' MUST_CHANGE_PASSWORD = TRUE ;';
    EXECUTE IMMEDIATE USER_SQL;
    JOB_LOG_DESCRIPTION := '-- PASSWORD CHANGED FOR USER: '|| P_USER_NAME;

    RETURN ARRAY_CONSTRUCT(:IS_ERROR,:JOB_LOG_DESCRIPTION)  ;

EXCEPTION
  WHEN OTHER THEN
    IS_ERROR := '1';
    JOB_LOG_DESCRIPTION := 'SQLCODE:' || SQLCODE || ' SQLERRM:' || SQLERRM || ' SQLSTATE:' ||SQLSTATE;
    RETURN ARRAY_CONSTRUCT(:IS_ERROR,:JOB_LOG_DESCRIPTION)  ;

END;
$$;


grant ownership on procedure PLATFORM_DB.PROVISION_ROUTINE.RESET_USER_PASSWORD_SQL_PROC (VARCHAR,VARCHAR,VARCHAR) to ROLE SECURITYADMIN;

USE ROLE SECURITYADMIN;
--DROP PROCEDURE PLATFORM_DB.PROVISION_ROUTINE.DISABLE_USER_SQL_PROC (VARCHAR,VARCHAR,VARCHAR);
grant USAGE on procedure PLATFORM_DB.PROVISION_ROUTINE.RESET_USER_PASSWORD_SQL_PROC (VARCHAR,VARCHAR,VARCHAR) to ROLE SYSADMIN;