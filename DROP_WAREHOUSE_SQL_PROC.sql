USE ROLE SYSADMIN;
CREATE OR REPLACE PROCEDURE PLATFORM_DB.PROVISION_ROUTINE.DROP_WAREHOUSE_SQL_PROC (WH_NAME VARCHAR, TENANT_NAME_PARAMETER VARCHAR)
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
   TENANT_EXCEPTION_PARAMETER EXCEPTION;
   WH_SQL VARCHAR DEFAULT '';
   LOG VARIANT DEFAULT '';

BEGIN
    
    IS_ERROR := '0';
    
    TENANT := TENANT_NAME_PARAMETER;

    //Validate Naming Convention:{Tenant Abbreviation}_ObjectName_{ObjectType}
    IF(TENANT IS NOT NULL AND STARTSWITH(WH_NAME,TENANT) AND ENDSWITH(WH_NAME,'_VWH') ) THEN
    
    WH_SQL:= 'DROP WAREHOUSE IF EXISTS ' || WH_NAME || ';';
    EXECUTE IMMEDIATE WH_SQL;
    
    JOB_LOG_DESCRIPTION := '-- DROPPED WAREHOUSE: '||WH_NAME || ' DROP_SQL: \n' || WH_SQL;
      RETURN ARRAY_CONSTRUCT(:IS_ERROR,:JOB_LOG_DESCRIPTION)  ;

    ELSE
      RAISE TENANT_EXCEPTION_PARAMETER;
    END IF;
EXCEPTION
  
  WHEN TENANT_EXCEPTION_PARAMETER  THEN
      IS_ERROR := '1';
      JOB_LOG_DESCRIPTION := 'ERROR: INVALID WH NAMING CONVENTION' || WH_NAME ;
      RETURN ARRAY_CONSTRUCT(:IS_ERROR,:JOB_LOG_DESCRIPTION)  ;

  
  WHEN OTHER THEN
      IS_ERROR := '1';
      JOB_LOG_DESCRIPTION := 'SQLCODE:' || SQLCODE || ' SQLERRM:' || SQLERRM || ' SQLSTATE:' ||SQLSTATE;
      RETURN ARRAY_CONSTRUCT(:IS_ERROR,:JOB_LOG_DESCRIPTION)  ;

END;

$$;
