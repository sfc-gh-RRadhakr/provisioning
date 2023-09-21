
USE ROLE SECURITYADMIN;
--DROP PROCEDURE ACDP_PLATFORM_DB.PLATFORM_ROUTINE.CREATE_USER_SQL_PROC (VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR);
DROP procedure if exists ACDP_PLATFORM_DB.PLATFORM_ROUTINE.DROP_USER_SQL_PROC (VARCHAR);

USE ROLE SYSADMIN;

CREATE or REPLACE PROCEDURE  ACDP_PLATFORM_DB.PLATFORM_ROUTINE.DROP_USER_SQL_PROC(
           USER_NAME_PARAMETER VARCHAR(200)
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
    INVALID_PARAMETERS_EXCEPTION EXCEPTION;
    
    USER_SQL VARCHAR DEFAULT '';
    LOG VARIANT DEFAULT '';

BEGIN
    IS_ERROR := '0';

    IF (
        USER_NAME_PARAMETER IS NULL OR TRIM(USER_NAME_PARAMETER) = ''
        ) THEN
            RAISE INVALID_PARAMETERS_EXCEPTION;

    ELSE
      USER_SQL :=  'DROP USER IF EXISTS ' ||USER_NAME_PARAMETER ;
      EXECUTE IMMEDIATE USER_SQL;
      JOB_LOG_DESCRIPTION := '-- USER DROPPED: \n'||USER_SQL ||';'  ;

      RETURN ARRAY_CONSTRUCT(:IS_ERROR,:JOB_LOG_DESCRIPTION)  ;
    END IF;
  
EXCEPTION

  WHEN INVALID_PARAMETERS_EXCEPTION  THEN
    IS_ERROR := '1';
    JOB_LOG_DESCRIPTION := 'ERROR:INCORRECT USER PARAMETERS' ; ;
    RETURN ARRAY_CONSTRUCT(:IS_ERROR,:JOB_LOG_DESCRIPTION)  ;


  WHEN OTHER THEN
    IS_ERROR := '1';
    JOB_LOG_DESCRIPTION := 'SQLCODE:' || SQLCODE || ' SQLERRM:' || SQLERRM || ' SQLSTATE:' ||SQLSTATE;
    RETURN ARRAY_CONSTRUCT(:IS_ERROR,:JOB_LOG_DESCRIPTION)  ;

END;
$$;




grant ownership on procedure ACDP_PLATFORM_DB.PLATFORM_ROUTINE.DROP_USER_SQL_PROC (VARCHAR) to ROLE SECURITYADMIN;

USE ROLE SECURITYADMIN;
--DROP PROCEDURE ACDP_PLATFORM_DB.PLATFORM_ROUTINE.CREATE_USER_SQL_PROC (VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR);
grant USAGE on procedure ACDP_PLATFORM_DB.PLATFORM_ROUTINE.DROP_USER_SQL_PROC (VARCHAR) to ROLE SYSADMIN;
