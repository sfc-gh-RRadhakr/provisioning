USE ROLE SYSADMIN;
CREATE or REPLACE PROCEDURE PLATFORM_DB.PROVISION_ROUTINE.LOG_JOB_DETAILS (
                                                  JOB_DETAILS VARIANT
                                                 )
RETURNS VARCHAR  NOT NULL
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$

 DECLARE
 LOG_SQL VARCHAR DEFAULT '';

BEGIN  
    LOG_SQL := 'INSERT INTO PLATFORM_DB.PROVISION_APP.PROVISION_JOB_LOG (JOB_DETAILS) select parse_json(\$\$'||JOB_DETAILS||'\$\$);';
    EXECUTE IMMEDIATE LOG_SQL;
    RETURN LOG_SQL;

EXCEPTION

  WHEN STATEMENT_ERROR THEN
      RETURN OBJECT_CONSTRUCT('SQLCODE',SQLCODE, 'SQLERRM', SQLERRM, 'SQLSTATE', SQLSTATE);
      
  WHEN OTHER THEN
      RETURN OBJECT_CONSTRUCT('SQLCODE',SQLCODE, 'SQLERRM', SQLERRM, 'SQLSTATE', SQLSTATE);
    END;

$$;