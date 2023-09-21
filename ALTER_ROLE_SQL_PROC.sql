USE ROLE SECURITYADMIN;
DROP PROCEDURE IF EXISTS PLATFORM_DB.PROVISION_ROUTINE.ALTER_ROLE_SQL_PROC (VARCHAR,VARCHAR,VARCHAR,VARCHAR);

USE ROLE SYSADMIN  ;

CREATE OR REPLACE PROCEDURE PLATFORM_DB.PROVISION_ROUTINE.ALTER_ROLE_SQL_PROC (
                P_CURRENT_ROLE_NAME         VARCHAR,
                P_NEW_ROLE_NAME             VARCHAR,
                P_ROLE_COMMENT              VARCHAR,
                P_TENANT_NAME               VARCHAR
                )

RETURNS ARRAY NOT NULL
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
DECLARE
   TENANT VARCHAR DEFAULT '';
   IS_ERROR VARCHAR DEFAULT '0';
   JOB_LOG_DESCRIPTION VARCHAR DEFAULT '';

BEGIN
    IS_ERROR := '0';
    TENANT := P_TENANT_NAME;

    LET ALTER_SQL VARCHAR :='ALTER ROLE ' || P_CURRENT_ROLE_NAME || ' RENAME TO ' || P_NEW_ROLE_NAME || ' ;';
    EXECUTE IMMEDIATE ALTER_SQL;
    
    JOB_LOG_DESCRIPTION := '-- ALTERED ROLE - NEW ROLE: ' || P_NEW_ROLE_NAME || ' ALTER_SQL : \n' || ALTER_SQL;

    -- IF (P_ROLE_COMMENT IS NOT NULL AND TRIM(P_ROLE_COMMENT) != '') THEN
    --     LET ALTER_SQL_COMMENT VARCHAR := 'ALTER ROLE ' || P_NEW_ROLE_NAME || ' IF EXISTS SET COMMENT = ' || P_ROLE_COMMENT || ' ;' ;
    --     EXECUTE IMMEDIATE ALTER_SQL_COMMENT;

    --     JOB_LOG_DESCRIPTION :=  JOB_LOG_DESCRIPTION || '\n' || ALTER_SQL_COMMENT;
    -- END IF;

    RETURN ARRAY_CONSTRUCT(:IS_ERROR,:JOB_LOG_DESCRIPTION)  ;

EXCEPTION

  WHEN OTHER THEN
    IS_ERROR := '1';
    JOB_LOG_DESCRIPTION := 'SQLCODE:' || SQLCODE || ' SQLERRM:' || SQLERRM || ' SQLSTATE:' ||SQLSTATE;
    RETURN ARRAY_CONSTRUCT(:IS_ERROR,:JOB_LOG_DESCRIPTION)  ;
END;
$$;


grant ownership on procedure PLATFORM_DB.PROVISION_ROUTINE.ALTER_ROLE_SQL_PROC (VARCHAR,VARCHAR,VARCHAR,VARCHAR) to ROLE SECURITYADMIN;

USE ROLE SECURITYADMIN;
grant USAGE on procedure PLATFORM_DB.PROVISION_ROUTINE.ALTER_ROLE_SQL_PROC (VARCHAR,VARCHAR,VARCHAR,VARCHAR) to ROLE SYSADMIN;

