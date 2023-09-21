USE ROLE SYSADMIN  ;

CREATE OR REPLACE PROCEDURE PLATFORM_DB.PROVISION_ROUTINE.CREATE_SCHEMA_SQL_PROC (
                DATABASENAME_PARAMETER  VARCHAR,
                SCHEMANAME_PARAMETER    VARCHAR,
                RETENTION_PARAMETER  VARCHAR,
                COMMENT_PARAMETER VARCHAR,
                MANAGED_ACCESS_PARAMETER VARCHAR,
                TENANT_NAME_PARAMETER VARCHAR 
                )

--RETURNS VARIANT  NOT NULL
--RETURNS VARCHAR  NOT NULL
RETURNS ARRAY NOT NULL
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
DECLARE
   TENANT VARCHAR DEFAULT '';
   JOB_NAME VARCHAR DEFAULT '';
   JOB_ACTION VARCHAR DEFAULT '';
   IS_ERROR VARCHAR DEFAULT '0';
   JOB_LOG_DESCRIPTION VARCHAR DEFAULT '';
   SCHEMA_NAME_EXCEPTION EXCEPTION;

   LOG VARIANT DEFAULT '';

    SCHEMA_SQL VARCHAR DEFAULT '';
    SCHEMA_TYPE  VARCHAR DEFAULT '';

BEGIN
    JOB_NAME := 'SCHEMA_WRAPPER';
    JOB_ACTION := 'CREATE';
    TENANT := TENANT_NAME_PARAMETER;
    
    MANAGED_ACCESS_PARAMETER := IFF(TRIM(MANAGED_ACCESS_PARAMETER) = '',' ',' WITH MANAGED ACCESS ');
    RETENTION_PARAMETER := IFF(TRIM(RETENTION_PARAMETER) = '',' ',' DATA_RETENTION_TIME_IN_DAYS= ' || RETENTION_PARAMETER);



    IF (DATABASENAME_PARAMETER IS NOT NULL AND NULLIF(TRIM(DATABASENAME_PARAMETER),'') IS NOT NULL 
                AND SCHEMANAME_PARAMETER IS NOT NULL AND NULLIF(TRIM(SCHEMANAME_PARAMETER),'') IS NOT NULL ) THEN

        SCHEMA_SQL := ' CREATE SCHEMA IF NOT EXISTS '|| DATABASENAME_PARAMETER|| '.'|| SCHEMANAME_PARAMETER || MANAGED_ACCESS_PARAMETER || ' '|| RETENTION_PARAMETER || ' COMMENT=''' || COMMENT_PARAMETER ||'''';
        EXECUTE IMMEDIATE SCHEMA_SQL;
        
        JOB_LOG_DESCRIPTION := '-- SCHEMA CREATED: '||DATABASENAME_PARAMETER || '.' || SCHEMANAME_PARAMETER || ' SCHEMA SQL: \n' || SCHEMA_SQL || ' ;';

        --RETURN OBJECT_CONSTRUCT('TENANT',:TENANT,'JOB_NAME',:JOB_NAME, 'JOB_LOG_DESCRIPTION',:JOB_LOG_DESCRIPTION, 'IS_ERROR', :IS_ERROR, 'ACTION', :JOB_ACTION);
        --RETURN JOB_LOG_DESCRIPTION;
        RETURN ARRAY_CONSTRUCT(:IS_ERROR,:JOB_LOG_DESCRIPTION)  ;


    ELSE
     RAISE SCHEMA_NAME_EXCEPTION;
    END IF ;
    
EXCEPTION

  WHEN SCHEMA_NAME_EXCEPTION  THEN
    IS_ERROR := '1';
    JOB_LOG_DESCRIPTION := 'ERROR: INVALID DATABASEBASENAME, SCHEMANAME PARAMETERS' ; ;
    --RETURN OBJECT_CONSTRUCT('TENANT',:TENANT,'JOB_NAME',:JOB_NAME, 'JOB_LOG_DESCRIPTION',:JOB_LOG_DESCRIPTION, 'IS_ERROR', :IS_ERROR, 'ACTION', :JOB_ACTION)  ;
    --RETURN JOB_LOG_DESCRIPTION;
    RETURN ARRAY_CONSTRUCT(:IS_ERROR,:JOB_LOG_DESCRIPTION)  ;

  WHEN OTHER THEN
    IS_ERROR := '1';
    JOB_LOG_DESCRIPTION := 'SQLCODE:' || SQLCODE || ' SQLERRM:' || SQLERRM || ' SQLSTATE:' ||SQLSTATE;
    --RETURN OBJECT_CONSTRUCT('TENANT',:TENANT,'JOB_NAME',:JOB_NAME, 'JOB_LOG_DESCRIPTION',:JOB_LOG_DESCRIPTION, 'IS_ERROR', :IS_ERROR, 'ACTION', :JOB_ACTION)  ;
    --RETURN JOB_LOG_DESCRIPTION;
    RETURN ARRAY_CONSTRUCT(:IS_ERROR,:JOB_LOG_DESCRIPTION)  ;

END;
$$;
