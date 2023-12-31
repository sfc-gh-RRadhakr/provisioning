/*
     SCHEMA WRAPPER: ACTION - CREATE
     1: Creates the relevant schemas based on database type
     2: Creates roles based on databasetype and schema type
     3: Grants privileges to roles based on database type, schema type and role type
     4: User Wrapper
        4a: Create User(s)
        4b: Grant Schema Role(s) to User(s)

     CURRENT BEHAVIOR:
     - Does not assign a default role
     - Does not Assign a default virtual warehouse

    -- TODO:
     -- SELECT ON FUTURE TABLES FOR THE VIEW MAIN ROLE
     -- FUTURE OWNERSHIP [METADATA CHANGE]
     -- CR_USER
*/
USE ROLE SYSADMIN;

CREATE OR REPLACE PROCEDURE PLATFORM_DB.PROVISION_ROUTINE.SCHEMA_WRAPPER(
    P_ACTION                                VARCHAR,
    P_DATABASE_TYPE                         VARCHAR,
    P_DATABASE_NAME                         VARCHAR,
    P_SCHEMA_TYPE                           VARCHAR,  
    P_SCHEMA_NAME                           VARCHAR,
    P_DATA_RETENTION_TIME_IN_DAYS           VARCHAR,
    P_SCHEMA_COMMENT                        VARCHAR,
    P_USER_COMMENT                          VARCHAR,
    P_MANAGED_ACCESS_SCHEMA                 VARCHAR,
    P_TENANT_NAME                           VARCHAR
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
    LOG_AGG VARCHAR DEFAULT '';
    RETURN_LOG VARIANT DEFAULT '';

    SYSADMIN_SUFFIX VARCHAR DEFAULT '_SYSADMIN_ROLE';
    LOCAL_SYSADMIN_ROLE VARCHAR DEFAULT '';
    ROLE_NAME VARCHAR DEFAULT '';
    SP_RETURN_LOG VARCHAR DEFAULT '';
    PERMISSION_EXISTS INTEGER DEFAULT 0;

    LOG ARRAY  DEFAULT [];

    LOGS VARCHAR DEFAULT '';
    CURSOR_RESULT ARRAY DEFAULT [];
    SCHEMA_RESULT VARCHAR DEFAULT '';
    GRANT_SQL VARCHAR  DEFAULT '';
    GRANT_SQL_LIST VARCHAR DEFAULT '';
    TENANT_ID VARCHAR DEFAULT '';
    DATA_PRODUCT_TYPE VARCHAR DEFAULT '';

    -- USER_TYPE_ID INTEGER;
    -- V_USER_TYPE_NAME VARCHAR;
    -- USER_NAME VARCHAR;
    -- DEFAULT_ROLE VARCHAR;
    -- DEFAULT_WAREHOUSE VARCHAR;
    -- EXT_ROLES_LIST VARCHAR;

BEGIN

    JOB_NAME := 'SCHEMA_WRAPPER';
    IS_ERROR := '0';
    IF(P_TENANT_NAME IS NULL OR TRIM(P_TENANT_NAME) ='') THEN
        RAISE TENANT_EXCEPTION_PARAMETER;
    END IF;
    TENANT := UPPER(P_TENANT_NAME);


    LOCAL_SYSADMIN_ROLE := TENANT || SYSADMIN_SUFFIX;
    P_DATABASE_TYPE := IFF(P_DATABASE_TYPE='','ALL',P_DATABASE_TYPE);
    IF (
        P_ACTION IS NULL OR TRIM(P_ACTION) = '' OR
        P_DATABASE_TYPE IS NULL OR TRIM(P_DATABASE_TYPE) = '' OR
        P_DATABASE_NAME IS NULL OR TRIM(P_DATABASE_NAME) = '' OR
        P_SCHEMA_NAME IS NULL OR TRIM(P_SCHEMA_NAME) = '' OR P_SCHEMA_TYPE IS NULL or TRIM(P_SCHEMA_TYPE)='' OR
        P_DATA_RETENTION_TIME_IN_DAYS IS NULL OR TRIM(P_DATA_RETENTION_TIME_IN_DAYS) = '' OR
        P_SCHEMA_COMMENT IS NULL OR TRIM(P_SCHEMA_COMMENT) = '' OR
        (NOT STARTSWITH(P_DATABASE_NAME, TENANT)))   THEN
            RAISE INVALID_PARAMETERS_EXCEPTION;
    END IF;

    ROLE_NAME := LOCAL_SYSADMIN_ROLE;

     IF(CONTAINS(REPLACE(CURRENT_AVAILABLE_ROLES(),SYSADMIN_SUFFIX,''),'SYSADMIN')) THEN
        ROLE_NAME := 'SYSADMIN';
    ELSE
        ROLE_NAME := LOCAL_SYSADMIN_ROLE;
    END IF;
    
    JOB_ACTION := UPPER(P_ACTION);
    P_DATABASE_TYPE := UPPER(P_DATABASE_TYPE);
    P_DATABASE_NAME := UPPER(P_DATABASE_NAME);
    P_SCHEMA_NAME := UPPER(P_SCHEMA_NAME);
    P_SCHEMA_TYPE := UPPER(P_SCHEMA_TYPE);

    TENANT := UPPER(P_TENANT_NAME);

    -- Check if Tenant is part of the framework - Control Table
    LET CONTROL_TABLE CURSOR(p) FOR 
        SELECT TENANT_ID , TENANT_ABBREVIATION,DATA_PRODUCT_TYPE
               FROM PLATFORM_DB.PROVISION_APP.TENANT_LIST 
               WHERE TENANT_ABBREVIATION = ? AND ACTIVE = 'Y';
    
    OPEN CONTROL_TABLE USING (:TENANT);
    FOR ACTIVE_TENANT IN CONTROL_TABLE DO
        TENANT_ID := ACTIVE_TENANT.TENANT_ID;
        DATA_PRODUCT_TYPE := ACTIVE_TENANT.DATA_PRODUCT_TYPE;
    END FOR;
    CLOSE CONTROL_TABLE; 
    IF(TENANT_ID IS NULL) THEN
      RAISE TENANT_EXCEPTION_PARAMETER;
    END IF;

        PERMISSION_EXISTS := (SELECT
        CASE        
            WHEN EXISTS (SELECT 1 FROM PLATFORM_DB.PROVISION_APP.SP_CONTROL CTL 
                INNER JOIN PLATFORM_DB.PROVISION_APP.SP_LIST L ON L.SP_ID = CTL.SP_ID 
            WHERE CTL.ADMIN_ROLE = :ROLE_NAME AND L.SP_NAME = 'SCHEMA_WRAPPER' AND L.SP_ACTION = :JOB_ACTION) THEN 1
        ELSE 0
    END AS PERMISSION_EXISTS);


    IF(JOB_ACTION = 'CREATE' AND PERMISSION_EXISTS = 1) THEN
    /*
        STEP 1: Based on DATABASETYPE_PARAMETER, TENANT_ID identify Schemas to be created
            Stage: _STG [T]
            Core: _CORE [T], [V]
            Semantic: _APP [T], [V]
    */
    CURSOR_RESULT := ARRAY_CONSTRUCT();
    

    LET SCHEMA_LIST CURSOR(p) FOR 
                SELECT S.SCHEMASHORTNAME,S.SCHEMATYPENAME,D.DATABASETYPENAME,S.DATABASETYPEID, S.SCHEMA_TYPEID 
                FROM PLATFORM_DB.PROVISION_APP.DATABASETYPE D 
                INNER JOIN PLATFORM_DB.PROVISION_APP.SCHEMA_TYPE  S 
                        ON D.DATABASETYPEID = S.DATABASETYPEID 
                WHERE DATABASETYPENAME = ? AND S.TENANT_ID = ? AND S.SCHEMATYPENAME=? ; 
    
    OPEN SCHEMA_LIST USING (:P_DATABASE_TYPE,:TENANT_ID,:P_SCHEMA_TYPE);
    FOR SCHEMA IN SCHEMA_LIST DO

        LET SCHEMA_SHORT_NAME VARCHAR := SCHEMA.SCHEMASHORTNAME;
        LET SCHEMA_NAME VARCHAR:= P_SCHEMA_NAME || SCHEMA_SHORT_NAME;       
        LET SCHEMATYPE_NAME VARCHAR:= SCHEMA.SCHEMATYPENAME;
        LET DATABASETYPE_NAME VARCHAR:= SCHEMA.DATABASETYPENAME;
        
        LOG := (CALL PLATFORM_DB.PROVISION_ROUTINE.CREATE_SCHEMA_SQL_PROC(:P_DATABASE_NAME,:SCHEMA_NAME,:P_DATA_RETENTION_TIME_IN_DAYS, :P_SCHEMA_COMMENT, :P_MANAGED_ACCESS_SCHEMA, :TENANT));
        
        LOG_AGG := LOG_AGG || LOG[1] || '\n';

        -- Error Check
        IF(LOG[0] = '1') THEN
            IS_ERROR := '1';
            RAISE WRAPPER_EXCEPTION;
        END IF;

        SP_RETURN_LOG := SP_RETURN_LOG || ' SCHEMA CREATED: ' || SCHEMA_NAME || ', ';
        
    /*
        Step 2: Based on Database Type, Schema Type, Tenant identify Schema Roles to be created
            Example: 
            _CORE [T] -> MAIN_ROLE, DML_ROLE, READ_ROLE
            [V] -> MAIN_ROLE, READ_ROLE
    */        
        
        LET SCHEMA_ROLES_LIST CURSOR(p) FOR 
            SELECT R.TENANT_ID,ROLENAME_TYPE, DATABASETYPENAME,SCHEMASHORTNAME 
            FROM PLATFORM_DB.PROVISION_APP.ROLE_MATRIX R 
            INNER JOIN PLATFORM_DB.PROVISION_APP.DatabaseType D  
                ON  D.DATABASETYPEID=R.DATABASETYPEID 
            INNER JOIN PLATFORM_DB.PROVISION_APP.Schema_Type  S  
                ON  S.SCHEMA_TYPEID=R.SCHEMA_TYPEID AND S.DATABASETYPEID=R.DATABASETYPEID 
            WHERE DATABASETYPENAME = ? AND SCHEMATYPENAME = ? AND R.TENANT_ID = ?;
    
        OPEN SCHEMA_ROLES_LIST USING (:DATABASETYPE_NAME,:SCHEMATYPE_NAME,:TENANT_ID);
        FOR R IN SCHEMA_ROLES_LIST DO
            
            ROLE_NAME := P_DATABASE_NAME || '_' || SCHEMA_NAME || R.ROLENAME_TYPE;
            LET ROLENAME_TYPE VARCHAR := R.ROLENAME_TYPE;

            LOG := (CALL PLATFORM_DB.PROVISION_ROUTINE.CREATE_ROLE_SQL_PROC(:ROLE_NAME, :TENANT));
            LOG_AGG := LOG_AGG || LOG[1] || '\n';
            -- Error Check
            IF(LOG[0] = '1') THEN
                IS_ERROR := '1';
                RAISE WRAPPER_EXCEPTION;
            END IF;
            
            SP_RETURN_LOG := SP_RETURN_LOG || ' ROLE CREATED: ' || ROLE_NAME || ', ';


    /*
        STEP 3: Based on Database Type, Schema Type, Role Type, Tenant identify Privileges to be granted
            Example: 
            GRANT USAGE ON DATABASE  TEST_TENANT_CORE_DB TO ROLE TEST_TENANT_CORE_DB_SALESOP_CORE_DML_ROLE;
            GRANT USAGE ON SCHEMA TEST_TENANT_CORE_DB.SALESOP_CORE TO ROLE TEST_TENANT_CORE_DB_SALESOP_CORE_DML_ROLE;
            GRANT SELECT,DELETE,INSERT,TRUNCATE,UPDATE ON ALL TABLES  IN SCHEMA TEST_TENANT_CORE_DB.SALESOP_CORE TO ROLE TEST_TENANT_CORE_DB_SALESOP_CORE_DML_ROLE;
            GRANT SELECT,DELETE,INSERT,TRUNCATE,UPDATE ON FUTURE TABLES  IN SCHEMA TEST_TENANT_CORE_DB.SALESOP_CORE TO ROLE TEST_TENANT_CORE_DB_SALESOP_CORE_DML_ROLE;
    */ 

            LET GRANTS CURSOR(p) FOR 
                SELECT SCHEMATYPENAME, ROLENAME_TYPE,PRIVILEGETYPE, IFNULL(ON_TAG,'0') ON_TAG ,IFNULL(IN_TAG,'0') as IN_TAG ,  PRIVILEGE 
                FROM PLATFORM_DB.PROVISION_APP.PRIVILEGES_MATRIX P
                INNER JOIN PLATFORM_DB.PROVISION_APP.DATABASETYPE D  ON  P.DATABASETYPEID=D.DATABASETYPEID
                INNER JOIN PLATFORM_DB.PROVISION_APP.SCHEMA_TYPE  S  ON  P.SCHEMA_TYPEID=S.SCHEMA_TYPEID  AND D.DATABASETYPEID=S.DATABASETYPEID
                INNER JOIN PLATFORM_DB.PROVISION_APP.ROLE_MATRIX  R  ON  R.SCHEMA_TYPEID=S.SCHEMA_TYPEID  AND R.DATABASETYPEID=S.DATABASETYPEID and R.ROLETYPE_ID=P.ROLETYPE_ID
                INNER JOIN PLATFORM_DB.PROVISION_APP.PRIVILEGE_MAPPING PM ON PM.PRIVILEGEID=P.PRIVILEGEID
                    WHERE R.ROLENAME_TYPE=?  AND DATABASETYPENAME=? and SCHEMATYPENAME=? AND P.TENANT_ID = ?
                 ORDER BY PRIVILEGETYPE ;  
           
            OPEN GRANTS USING (:ROLENAME_TYPE, :DATABASETYPE_NAME, :SCHEMATYPE_NAME, :TENANT_ID);
            FOR G IN GRANTS DO
                
                LET PRIVILEGETYPE VARCHAR  :=   G.PRIVILEGETYPE;
                LET ON_TAG VARCHAR := G.ON_TAG;
                LET IN_TAG VARCHAR := G.IN_TAG;
                LET PRIVILEGE VARCHAR := G.PRIVILEGE;
                
                IF (ON_TAG !='0') THEN
                    ON_TAG := ' ON ' || ON_TAG;
                END IF;

                IF (IN_TAG !='0') THEN
                    IN_TAG := ' IN ' || IN_TAG;
                ELSE
                    IN_TAG := ' ';
                END IF;

                IF (PRIVILEGETYPE = 'DATABASE') THEN
                  --GRANT USAGE ON DATABASE ACDP_TENANT_STAGING_DB TO ROLE ACDP_TENANT_STAGING_DB_UDMTOOL_STG_MAIN_ROLE ;
                  GRANT_SQL := ' GRANT ' || PRIVILEGE || ON_TAG || ' ' || IN_TAG || ' ' ||  P_DATABASE_NAME  || ' TO ROLE ' || ROLE_NAME || ';';
                  GRANT_SQL_LIST := GRANT_SQL_LIST || GRANT_SQL;
                END IF;

                IF (CONTAINS(PRIVILEGE,'USAGE') AND TRIM(ON_TAG) = 'ON SCHEMA' AND TRIM(IN_TAG) != '') THEN 

                  --GRANT  CREATE TABLE,CREATE VIEW TABLE ON SCHEMA  GBI_FINANCE_STAGING_DB.UDMTOOL_STG TO ROLE GBI_FINANCE_STAGING_DB_UDMTOOL_STG_MAIN_ROLE ;
                  GRANT_SQL :=' GRANT ' || PRIVILEGE  || ' ON ' || PRIVILEGETYPE  || ' ' || IN_TAG || ' ' || P_DATABASE_NAME || '.' || SCHEMA_NAME || ' TO ROLE ' || ROLE_NAME || ';';
                  GRANT_SQL_LIST := GRANT_SQL_LIST || GRANT_SQL;
                END IF;

                IF (TRIM(PRIVILEGETYPE) = 'SCHEMA' AND TRIM(ON_TAG) = 'ON SCHEMA' AND TRIM(IN_TAG) = '') THEN
                  GRANT_SQL :=' GRANT ' || PRIVILEGE || ON_TAG  || ' ' || P_DATABASE_NAME || '.' ||  SCHEMA_NAME || ' TO ROLE ' || ROLE_NAME || ';';
                  GRANT_SQL_LIST := GRANT_SQL_LIST || GRANT_SQL;
                END IF;

                IF (PRIVILEGETYPE = 'SCHEMAOBJECT') THEN
                  GRANT_SQL :=' GRANT ' || PRIVILEGE || ON_TAG || ' ' || IN_TAG || ' ' || P_DATABASE_NAME || '.' || SCHEMA_NAME || ' TO ROLE ' || ROLE_NAME || ';';
                  GRANT_SQL_LIST := GRANT_SQL_LIST || GRANT_SQL;
                END IF;
                
                -- This logic is to handle the following behavior -> SQLCODE:3504 SQLERRM:A future grant with privilege OWNERSHIP on object type TABLE already exists in the schema'
                -- EX: GRANT SELECT,DELETE,INSERT,TRUNCATE,UPDATE,OWNERSHIP ON FUTURE TABLES  IN SCHEMA GBI_XAPTEST1_SEMANTIC_DB.APTEST2_APP TO ROLE GBI_XAPTEST1_SEMANTIC_DB_APTEST2_APP_MAIN_ROLE;
                IF (CONTAINS(PRIVILEGE, 'OWNERSHIP')) THEN
                    LOG := (CALL PLATFORM_DB.PROVISION_ROUTINE.GRANT_ROLE_SQL_PROC(:GRANT_SQL));
                    
                    LOG_AGG := LOG_AGG || LOG[1] || '\n';
                    
                    IF(LOG[0] = '1' AND CONTAINS(LOG[1],'SQLCODE:3504')) THEN
                        IS_ERROR := '0'; -- Error is expected if ownership grant already exists...Continue without an error
                    END IF;

                -- Rest of the Grants
                ELSE
                    LOG := (CALL PLATFORM_DB.PROVISION_ROUTINE.GRANT_ROLE_SQL_PROC(:GRANT_SQL));
                    LOG_AGG := LOG_AGG || LOG[1] || '\n';
                    IF(LOG[0] = '1') THEN
                        IS_ERROR := '1';
                        RAISE WRAPPER_EXCEPTION;
                    END IF;
                END IF;

                END FOR;
                
                CLOSE GRANTS; 
                
                LET BU_TARGET_ROLE_NAME VARCHAR := P_DATABASE_NAME || '_ALL'|| ROLENAME_TYPE;
                LET BU_READ_ROLE_SQL VARCHAR := 'GRANT ROLE ' || ROLE_NAME || ' TO ROLE ' ||  BU_TARGET_ROLE_NAME;   
                
                LOG := (CALL PLATFORM_DB.PROVISION_ROUTINE.CREATE_ROLE_SQL_PROC(:BU_TARGET_ROLE_NAME, :TENANT));                    
                LOG_AGG := LOG_AGG || LOG[1] || '\n';                    
                IF(LOG[0] = '1') THEN
                    IS_ERROR := '1';
                    RAISE WRAPPER_EXCEPTION;
                END IF;
                
                SP_RETURN_LOG := SP_RETURN_LOG || ' ROLE CREATED : ' || BU_TARGET_ROLE_NAME || ', ';
 
                LOG := (CALL PLATFORM_DB.PROVISION_ROUTINE.GRANT_ROLE_SQL_PROC(:BU_READ_ROLE_SQL));
                LOG_AGG := LOG_AGG || LOG[1] || '\n';
                IF(LOG[0] = '1') THEN
                    IS_ERROR := '1';
                    RAISE WRAPPER_EXCEPTION;
                END IF;
                SP_RETURN_LOG := SP_RETURN_LOG || ' GRANTED ROLE : ' || ROLE_NAME || ' TO ROLE ' ||  BU_TARGET_ROLE_NAME || ', ';

                
            END FOR;
        CLOSE SCHEMA_ROLES_LIST; 

    END FOR;
    CLOSE SCHEMA_LIST;
 
   
    ELSE
        RAISE INVALID_PARAMETERS_EXCEPTION;
    END IF;
      IF (LOG_AGG ='') THEN
        RAISE INVALID_PARAMETERS_EXCEPTION;
    END IF;
     RETURN_LOG := OBJECT_CONSTRUCT('tenant',:TENANT,'job_name',:JOB_NAME, 'job_log_description',:SP_RETURN_LOG, 'is_error', :IS_ERROR, 'action', :JOB_ACTION);
    CALL PLATFORM_DB.PROVISION_ROUTINE.LOG_JOB_DETAILS(OBJECT_CONSTRUCT('tenant',:TENANT,'job_name',:JOB_NAME, 'job_log_description',:LOG_AGG, 'is_error', :IS_ERROR, 'action', :JOB_ACTION));

    RETURN RETURN_LOG;

EXCEPTION
  
  WHEN INVALID_PARAMETERS_EXCEPTION  THEN
      IS_ERROR := '1';
      JOB_LOG_DESCRIPTION := 'ERROR: INVALID PARAMETERS' ;
      RETURN_LOG := OBJECT_CONSTRUCT('tenant',:TENANT,'job_name',:JOB_NAME, 'job_log_description',:JOB_LOG_DESCRIPTION, 'is_error', :IS_ERROR, 'action', :JOB_ACTION);
      CALL PLATFORM_DB.PROVISION_ROUTINE.LOG_JOB_DETAILS(:RETURN_LOG);
      RETURN RETURN_LOG;

  WHEN TENANT_EXCEPTION_PARAMETER  THEN
      IS_ERROR := '1';
      JOB_LOG_DESCRIPTION := 'ERROR: COULD NOT RESOLVE TENANT' ;
      RETURN_LOG := OBJECT_CONSTRUCT('tenant',:TENANT,'job_name',:JOB_NAME, 'job_log_description',:JOB_LOG_DESCRIPTION, 'is_error', :IS_ERROR, 'action', :JOB_ACTION);
      CALL PLATFORM_DB.PROVISION_ROUTINE.LOG_JOB_DETAILS(:RETURN_LOG);
      RETURN RETURN_LOG;
  
  WHEN WRAPPER_EXCEPTION  THEN
      IS_ERROR := '1';
      JOB_LOG_DESCRIPTION := 'ERROR: SCHEMA WRAPPER FAILED ' || LOG_AGG ;
      RETURN_LOG := OBJECT_CONSTRUCT('tenant',:TENANT,'job_name',:JOB_NAME, 'job_log_description',:JOB_LOG_DESCRIPTION, 'is_error', :IS_ERROR, 'action', :JOB_ACTION);
      CALL PLATFORM_DB.PROVISION_ROUTINE.LOG_JOB_DETAILS(:RETURN_LOG);
      RETURN RETURN_LOG;

  WHEN OTHER THEN
      IS_ERROR := '1';
      JOB_LOG_DESCRIPTION := 'SQLCODE:' || SQLCODE || ' SQLERRM:' || SQLERRM || ' SQLSTATE:' ||SQLSTATE || LOG_AGG;
      RETURN_LOG := OBJECT_CONSTRUCT('tenant',:TENANT,'job_name',:JOB_NAME, 'job_log_description',:JOB_LOG_DESCRIPTION, 'is_error', :IS_ERROR, 'action', :JOB_ACTION);
      CALL PLATFORM_DB.PROVISION_ROUTINE.LOG_JOB_DETAILS(:RETURN_LOG);
      RETURN RETURN_LOG;
END;
$$;

GRANT USAGE ON PROCEDURE PLATFORM_DB.PROVISION_ROUTINE.SCHEMA_WRAPPER(
    VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR) TO ROLE PLATFORM_DB_PROVISION_ROUTINE_USAGE_ROLE;


/*
     SCHEMA WRAPPER: ACTION - DROP
     1: DROP SCHEMA USER
     2: DROP SCHEMA ROLES
     3: DROP SCHEMAs

*/
USE ROLE SYSADMIN;

CREATE OR REPLACE PROCEDURE PLATFORM_DB.PROVISION_ROUTINE.SCHEMA_WRAPPER(
    P_ACTION                        VARCHAR,
    P_DATABASE_TYPE                 VARCHAR,
    P_DATABASE_NAME                 VARCHAR,
    P_SCHEMA_NAME                   VARCHAR,
    P_USER_COMMENT                  VARCHAR,
    P_TENANT_NAME                   VARCHAR
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
    LOG_AGG VARCHAR DEFAULT '';
    RETURN_LOG VARIANT DEFAULT '';

    SYSADMIN_SUFFIX VARCHAR DEFAULT '_SYSADMIN_ROLE';
    LOCAL_SYSADMIN_ROLE VARCHAR DEFAULT '';
    ROLE_NAME VARCHAR DEFAULT '';
    SP_RETURN_LOG VARCHAR DEFAULT '';
    PERMISSION_EXISTS INTEGER DEFAULT 0;
    LOG ARRAY DEFAULT [];

    LOGS VARCHAR DEFAULT '';
    CURSOR_RESULT ARRAY DEFAULT [];
    SCHEMA_RESULT VARCHAR DEFAULT '';
    GRANT_SQL VARCHAR  DEFAULT '';
    GRANT_SQL_LIST VARCHAR DEFAULT '';
    TENANT_ID VARCHAR DEFAULT '';

BEGIN

    JOB_NAME := 'SCHEMA_WRAPPER';
    IS_ERROR := '0';
    IF(P_TENANT_NAME IS NULL OR TRIM(P_TENANT_NAME) ='') THEN
        RAISE TENANT_EXCEPTION_PARAMETER;
    END IF;
    TENANT := UPPER(P_TENANT_NAME);
    LOCAL_SYSADMIN_ROLE := TENANT || SYSADMIN_SUFFIX;

        
    IF (
        P_ACTION IS NULL OR TRIM(P_ACTION) = '' OR
        P_DATABASE_TYPE IS NULL OR TRIM(P_DATABASE_TYPE) = '' OR
        P_DATABASE_NAME IS NULL OR TRIM(P_DATABASE_NAME) = '' OR
        P_SCHEMA_NAME IS NULL OR TRIM(P_SCHEMA_NAME) = '' OR
        P_USER_COMMENT IS NULL OR TRIM(P_USER_COMMENT) = '') THEN
            RAISE INVALID_PARAMETERS_EXCEPTION;
    END IF;

    IF(CONTAINS(REPLACE(CURRENT_AVAILABLE_ROLES(),SYSADMIN_SUFFIX,''),'SYSADMIN')) THEN
        ROLE_NAME := 'SYSADMIN';
    ELSE
        ROLE_NAME := LOCAL_SYSADMIN_ROLE;
    END IF;

    JOB_ACTION := UPPER(P_ACTION);
    P_DATABASE_TYPE := UPPER(P_DATABASE_TYPE);
    P_DATABASE_NAME := UPPER(P_DATABASE_NAME);
    P_SCHEMA_NAME := UPPER(P_SCHEMA_NAME);

    TENANT := UPPER(P_TENANT_NAME);

    -- Check if Tenant is part of the framework - Control Table
    LET CONTROL_TABLE CURSOR(p) FOR 
        SELECT TENANT_ID , TENANT_ABBREVIATION
               FROM PLATFORM_DB.PROVISION_APP.TENANT_LIST 
               WHERE TENANT_ABBREVIATION = ? AND ACTIVE = 'Y';
    
    OPEN CONTROL_TABLE USING (:TENANT);
    FOR ACTIVE_TENANT IN CONTROL_TABLE DO
        TENANT_ID := ACTIVE_TENANT.TENANT_ID;
    END FOR;
    CLOSE CONTROL_TABLE; 
    IF(TENANT_ID IS NULL) THEN
      RAISE TENANT_EXCEPTION_PARAMETER;
    END IF;

    PERMISSION_EXISTS := (SELECT
        CASE        
            WHEN EXISTS (SELECT 1 FROM PLATFORM_DB.PROVISION_APP.SP_CONTROL CTL 
                INNER JOIN PLATFORM_DB.PROVISION_APP.SP_LIST L ON L.SP_ID = CTL.SP_ID 
            WHERE CTL.ADMIN_ROLE = :ROLE_NAME AND L.SP_NAME = 'SCHEMA_WRAPPER' AND L.SP_ACTION = :JOB_ACTION) THEN 1
        ELSE 0
    END AS PERMISSION_EXISTS);

    IF(JOB_ACTION = 'DROP' AND PERMISSION_EXISTS = 1) THEN

      /*
        Step 1: Identify Users to be dropped
     
        LET USERS_LIST CURSOR(p) FOR 
            SELECT  M.USER_TYPE_ID,M.DATABASETYPEID,DT.DATABASETYPENAME,U.USER_TYPE_NAME,M.MAPPING_RULES 
                    FROM PLATFORM_DB.PROVISION_APP.USER_DATABASE_MAPPING M
                INNER JOIN PLATFORM_DB.PROVISION_APP.DATABASETYPE DT ON DT.DATABASETYPEID=M.DATABASETYPEID
                INNER JOIN  PLATFORM_DB.PROVISION_APP.USER_TYPE U ON U.USER_TYPE_ID=M.USER_TYPE_ID
                WHERE UPPER(DATABASETYPENAME)=? AND M.TENANT_ID = ?;
    
        OPEN USERS_LIST USING (:P_DATABASE_TYPE, :TENANT_ID);
        FOR USER_TO_DROP IN USERS_LIST DO

            LET USER_TYPE_ID INTEGER := USER_TO_DROP.USER_TYPE_ID;
            LET USER_NAME VARCHAR := P_DATABASE_NAME || '_' || P_SCHEMA_NAME || '_' || USER_TO_DROP.USER_TYPE_NAME;
            
            LOG := (CALL PLATFORM_DB.PROVISION_ROUTINE.DROP_USER_SQL_PROC(:USER_NAME));
        
            LOG_AGG := LOG_AGG || LOG[1] || '\n';
        
            -- Error Check
            IF(LOG[0] = '1') THEN
                IS_ERROR := '1';
                RAISE WRAPPER_EXCEPTION;
            END IF;

            SP_RETURN_LOG := SP_RETURN_LOG || ' DROPPED USER: ' || USER_NAME || ', ';
       END FOR;
       CLOSE USERS_LIST;
    */
     /*
        Step 2: Based on Database Type, Schema Type, Tenant identify Schema Roles to be dropped
            Example: 
            _CORE [T] -> MAIN_ROLE, DML_ROLE, READ_ROLE
            [V] -> MAIN_ROLE, READ_ROLE
    */        
        
    LET SCHEMA_LIST CURSOR(p) FOR 
    SELECT S.SCHEMASHORTNAME,S.SCHEMATYPENAME,D.DATABASETYPENAME,S.DATABASETYPEID, S.SCHEMA_TYPEID 
    FROM PLATFORM_DB.PROVISION_APP.DATABASETYPE D 
    INNER JOIN PLATFORM_DB.PROVISION_APP.SCHEMA_TYPE  S 
            ON D.DATABASETYPEID = S.DATABASETYPEID 
    WHERE DATABASETYPENAME = ? AND S.TENANT_ID = ?; 
    
    OPEN SCHEMA_LIST USING (:P_DATABASE_TYPE,:TENANT_ID);
    FOR SCHEMA IN SCHEMA_LIST DO

        LET SCHEMA_SHORT_NAME VARCHAR := SCHEMA.SCHEMASHORTNAME;
        LET SCHEMA_NAME VARCHAR:= P_SCHEMA_NAME || SCHEMA_SHORT_NAME;       
        LET SCHEMATYPE_NAME VARCHAR:= SCHEMA.SCHEMATYPENAME;
        LET DATABASETYPE_NAME VARCHAR:= SCHEMA.DATABASETYPENAME;
        
        LET SCHEMA_ROLES_LIST CURSOR(p) FOR 
            SELECT R.TENANT_ID,ROLENAME_TYPE, DATABASETYPENAME,SCHEMASHORTNAME 
            FROM PLATFORM_DB.PROVISION_APP.ROLE_MATRIX R 
            INNER JOIN PLATFORM_DB.PROVISION_APP.DatabaseType D  
                ON  D.DATABASETYPEID=R.DATABASETYPEID 
            INNER JOIN PLATFORM_DB.PROVISION_APP.Schema_Type  S  
                ON  S.SCHEMA_TYPEID=R.SCHEMA_TYPEID AND S.DATABASETYPEID=R.DATABASETYPEID 
            WHERE DATABASETYPENAME = ? AND SCHEMATYPENAME = ? AND R.TENANT_ID = ?;
    
        OPEN SCHEMA_ROLES_LIST USING (:DATABASETYPE_NAME,:SCHEMATYPE_NAME,:TENANT_ID);
        FOR R IN SCHEMA_ROLES_LIST DO
            
            ROLE_NAME := P_DATABASE_NAME || '_' || SCHEMA_NAME || R.ROLENAME_TYPE;
            LET ROLENAME_TYPE VARCHAR := R.ROLENAME_TYPE;

            LOG := (CALL PLATFORM_DB.PROVISION_ROUTINE.DROP_ROLE_SQL_PROC(:ROLE_NAME, :TENANT));
            LOG_AGG := LOG_AGG || LOG[1] || '\n';
            -- Error Check
            IF(LOG[0] = '1') THEN
                IS_ERROR := '1';
                RAISE WRAPPER_EXCEPTION;
            END IF;

            SP_RETURN_LOG := SP_RETURN_LOG || ' DROPPED ROLE: ' || ROLE_NAME || ', ';

        END FOR;
        CLOSE SCHEMA_ROLES_LIST;
    
    LOG := (CALL PLATFORM_DB.PROVISION_ROUTINE.DROP_SCHEMA_SQL_PROC(:P_DATABASE_NAME, :SCHEMA_NAME,:P_USER_COMMENT, :TENANT ));

    LOG_AGG := LOG_AGG || LOG[1] || '\n';
     -- Error Check
     IF(LOG[0] = '1') THEN
         IS_ERROR := '1';
         RAISE WRAPPER_EXCEPTION;
     END IF;
    
    SP_RETURN_LOG := SP_RETURN_LOG || ' DROPPED SCHEMA: ' || SCHEMA_NAME || ', ';

    END FOR;
    CLOSE SCHEMA_LIST;

    ELSE
        RAISE INVALID_PARAMETERS_EXCEPTION;
    END IF;
    
    IF (LOG_AGG ='') THEN
        RAISE INVALID_PARAMETERS_EXCEPTION;
    END IF;

    RETURN_LOG := OBJECT_CONSTRUCT('tenant',:TENANT,'job_name',:JOB_NAME, 'job_log_description',:SP_RETURN_LOG, 'is_error', :IS_ERROR, 'action', :JOB_ACTION);
    CALL PLATFORM_DB.PROVISION_ROUTINE.LOG_JOB_DETAILS(OBJECT_CONSTRUCT('tenant',:TENANT,'job_name',:JOB_NAME, 'job_log_description',:LOG_AGG, 'is_error', :IS_ERROR, 'action', :JOB_ACTION));

    RETURN RETURN_LOG;
EXCEPTION
  
  WHEN INVALID_PARAMETERS_EXCEPTION  THEN
      IS_ERROR := '1';
      JOB_LOG_DESCRIPTION := 'ERROR: INVALID PARAMETERS' ;
      RETURN_LOG := OBJECT_CONSTRUCT('tenant',:TENANT,'job_name',:JOB_NAME, 'job_log_description',:JOB_LOG_DESCRIPTION, 'is_error', :IS_ERROR, 'action', :JOB_ACTION);
      CALL PLATFORM_DB.PROVISION_ROUTINE.LOG_JOB_DETAILS(:RETURN_LOG);
      RETURN RETURN_LOG;

  WHEN TENANT_EXCEPTION_PARAMETER  THEN
      IS_ERROR := '1';
      JOB_LOG_DESCRIPTION := 'ERROR: COULD NOT RESOLVE TENANT' ;
      RETURN_LOG := OBJECT_CONSTRUCT('tenant',:TENANT,'job_name',:JOB_NAME, 'job_log_description',:JOB_LOG_DESCRIPTION, 'is_error', :IS_ERROR, 'action', :JOB_ACTION);
      CALL PLATFORM_DB.PROVISION_ROUTINE.LOG_JOB_DETAILS(:RETURN_LOG);
      RETURN RETURN_LOG;
  
  WHEN WRAPPER_EXCEPTION  THEN
      IS_ERROR := '1';
      JOB_LOG_DESCRIPTION := 'ERROR: SCHEMA WRAPPER FAILED ' || LOG_AGG ;
      RETURN_LOG := OBJECT_CONSTRUCT('tenant',:TENANT,'job_name',:JOB_NAME, 'job_log_description',:JOB_LOG_DESCRIPTION, 'is_error', :IS_ERROR, 'action', :JOB_ACTION);
      CALL PLATFORM_DB.PROVISION_ROUTINE.LOG_JOB_DETAILS(:RETURN_LOG);
      RETURN RETURN_LOG;

  WHEN OTHER THEN
      IS_ERROR := '1';
      JOB_LOG_DESCRIPTION := 'SQLCODE:' || SQLCODE || ' SQLERRM:' || SQLERRM || ' SQLSTATE:' ||SQLSTATE || LOG_AGG;
      RETURN_LOG := OBJECT_CONSTRUCT('tenant',:TENANT,'job_name',:JOB_NAME, 'job_log_description',:JOB_LOG_DESCRIPTION, 'is_error', :IS_ERROR, 'action', :JOB_ACTION);
      CALL PLATFORM_DB.PROVISION_ROUTINE.LOG_JOB_DETAILS(:RETURN_LOG);
      RETURN RETURN_LOG;
END;
$$;

GRANT USAGE ON PROCEDURE PLATFORM_DB.PROVISION_ROUTINE.SCHEMA_WRAPPER(VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR) TO ROLE PLATFORM_DB_PROVISION_ROUTINE_USAGE_ROLE;


/*
     SCHEMA WRAPPER: ACTION - ALTER
*/
USE ROLE SYSADMIN;

CREATE OR REPLACE PROCEDURE PLATFORM_DB.PROVISION_ROUTINE.SCHEMA_WRAPPER(
    P_ACTION                                VARCHAR,
    P_DATABASE_NAME                         VARCHAR,
    P_SCHEMA_NAME                           VARCHAR,
    P_DATA_RETENTION_TIME_IN_DAYS           VARCHAR,
    P_SCHEMA_COMMENT                        VARCHAR,
    P_MANAGED_ACCESS_SCHEMA                 VARCHAR,
    P_TENANT_NAME                           VARCHAR
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
    LOG_AGG VARCHAR DEFAULT '';
    RETURN_LOG VARIANT DEFAULT '';

    SYSADMIN_SUFFIX VARCHAR DEFAULT '_SYSADMIN_ROLE';
    LOCAL_SYSADMIN_ROLE VARCHAR DEFAULT '';
    ROLE_NAME VARCHAR DEFAULT '';
    PERMISSION_EXISTS INTEGER DEFAULT 0;
    SP_RETURN_LOG VARCHAR DEFAULT '';


    LOG ARRAY DEFAULT [];

    LOGS VARCHAR DEFAULT '';
    CURSOR_RESULT ARRAY DEFAULT [];
    SCHEMA_RESULT VARCHAR DEFAULT '';
    GRANT_SQL VARCHAR  DEFAULT '';
    GRANT_SQL_LIST VARCHAR DEFAULT '';
    TENANT_ID VARCHAR DEFAULT '';

BEGIN

    JOB_NAME := 'SCHEMA_WRAPPER';
    IS_ERROR := '0';
    IF(P_TENANT_NAME IS NULL OR TRIM(P_TENANT_NAME) ='') THEN
        RAISE TENANT_EXCEPTION_PARAMETER;
    END IF;
    TENANT := UPPER(P_TENANT_NAME);

    LOCAL_SYSADMIN_ROLE := TENANT || SYSADMIN_SUFFIX;
    
    IF (
        P_ACTION IS NULL OR TRIM(P_ACTION) = '' OR
        P_DATABASE_NAME IS NULL OR TRIM(P_DATABASE_NAME) = '' OR
        P_SCHEMA_NAME IS NULL OR TRIM(P_SCHEMA_NAME) = '' OR
        P_SCHEMA_COMMENT IS NULL OR TRIM(P_SCHEMA_COMMENT) = '' OR
         NOT STARTSWITH(P_DATABASE_NAME, TENANT)) THEN
            RAISE INVALID_PARAMETERS_EXCEPTION;
    END IF;

    IF(CONTAINS(REPLACE(CURRENT_AVAILABLE_ROLES(),SYSADMIN_SUFFIX,''),'SYSADMIN')) THEN
        ROLE_NAME := 'SYSADMIN';
    ELSE
        ROLE_NAME := LOCAL_SYSADMIN_ROLE;
    END IF;

    JOB_ACTION := UPPER(P_ACTION);
    P_DATABASE_NAME := UPPER(P_DATABASE_NAME);
    P_SCHEMA_NAME := UPPER(P_SCHEMA_NAME);

    TENANT := UPPER(P_TENANT_NAME);

   -- Check if Tenant is part of the framework - Control Table
    TENANT := (SELECT TENANT_ABBREVIATION FROM PLATFORM_DB.PROVISION_APP.TENANT_LIST WHERE TENANT_ABBREVIATION = :TENANT AND ACTIVE = 'Y');

    IF(TENANT IS NULL) THEN
      RAISE TENANT_EXCEPTION_PARAMETER;
    END IF;

    PERMISSION_EXISTS := (SELECT
        CASE        
            WHEN EXISTS (SELECT 1 FROM PLATFORM_DB.PROVISION_APP.SP_CONTROL CTL 
                INNER JOIN PLATFORM_DB.PROVISION_APP.SP_LIST L ON L.SP_ID = CTL.SP_ID 
            WHERE CTL.ADMIN_ROLE = :ROLE_NAME AND L.SP_NAME = 'SCHEMA_WRAPPER' AND L.SP_ACTION = :JOB_ACTION) THEN 1
        ELSE 0
    END AS PERMISSION_EXISTS);


    IF(JOB_ACTION = 'ALTER' AND PERMISSION_EXISTS = 1) THEN

        LOG := (CALL PLATFORM_DB.PROVISION_ROUTINE.ALTER_SCHEMA_SQL_PROC(:P_DATABASE_NAME,:P_SCHEMA_NAME,:P_DATA_RETENTION_TIME_IN_DAYS, :P_SCHEMA_COMMENT, :P_MANAGED_ACCESS_SCHEMA, :TENANT));
        
        LOG_AGG := LOG_AGG || LOG[1];

        -- Error Check
        IF(LOG[0] = '1') THEN
            IS_ERROR := '1';
            RAISE WRAPPER_EXCEPTION;
        END IF;
        SP_RETURN_LOG := ' SCHEMA ALTERED: ' || P_DATABASE_NAME || '.' || P_SCHEMA_NAME;
    ELSE
        RAISE INVALID_PARAMETERS_EXCEPTION;
    END IF;


    RETURN_LOG := OBJECT_CONSTRUCT('tenant',:TENANT,'job_name',:JOB_NAME, 'job_log_description',SP_RETURN_LOG, 'is_error', :IS_ERROR, 'action', :JOB_ACTION);
    CALL PLATFORM_DB.PROVISION_ROUTINE.LOG_JOB_DETAILS(OBJECT_CONSTRUCT('tenant',:TENANT,'job_name',:JOB_NAME, 'job_log_description',:LOG_AGG, 'is_error', :IS_ERROR, 'action', :JOB_ACTION));
    RETURN RETURN_LOG;

EXCEPTION
  
  WHEN INVALID_PARAMETERS_EXCEPTION  THEN
      IS_ERROR := '1';
      JOB_LOG_DESCRIPTION := 'ERROR: INVALID PARAMETERS' ;
      RETURN_LOG := OBJECT_CONSTRUCT('tenant',:TENANT,'job_name',:JOB_NAME, 'job_log_description',:JOB_LOG_DESCRIPTION, 'is_error', :IS_ERROR, 'action', :JOB_ACTION);
      CALL PLATFORM_DB.PROVISION_ROUTINE.LOG_JOB_DETAILS(:RETURN_LOG);
      RETURN RETURN_LOG;

  WHEN TENANT_EXCEPTION_PARAMETER  THEN
      IS_ERROR := '1';
      JOB_LOG_DESCRIPTION := 'ERROR: COULD NOT RESOLVE TENANT' ;
      RETURN_LOG := OBJECT_CONSTRUCT('tenant',:TENANT,'job_name',:JOB_NAME, 'job_log_description',:JOB_LOG_DESCRIPTION, 'is_error', :IS_ERROR, 'action', :JOB_ACTION);
      CALL PLATFORM_DB.PROVISION_ROUTINE.LOG_JOB_DETAILS(:RETURN_LOG);
      RETURN RETURN_LOG;
  
  WHEN WRAPPER_EXCEPTION  THEN
      IS_ERROR := '1';
      JOB_LOG_DESCRIPTION := 'ERROR: SCHEMA WRAPPER FAILED ' || LOG_AGG ;
      RETURN_LOG := OBJECT_CONSTRUCT('tenant',:TENANT,'job_name',:JOB_NAME, 'job_log_description',:JOB_LOG_DESCRIPTION, 'is_error', :IS_ERROR, 'action', :JOB_ACTION);
      CALL PLATFORM_DB.PROVISION_ROUTINE.LOG_JOB_DETAILS(:RETURN_LOG);
      RETURN RETURN_LOG;

  WHEN OTHER THEN
      IS_ERROR := '1';
      JOB_LOG_DESCRIPTION := 'SQLCODE:' || SQLCODE || ' SQLERRM:' || SQLERRM || ' SQLSTATE:' ||SQLSTATE || LOG_AGG;
      RETURN_LOG := OBJECT_CONSTRUCT('TENANT',:TENANT,'JOB_NAME',:JOB_NAME, 'JOB_LOG_DESCRIPTION',:JOB_LOG_DESCRIPTION, 'IS_ERROR', :IS_ERROR, 'ACTION', :JOB_ACTION);
      CALL PLATFORM_DB.PROVISION_ROUTINE.LOG_JOB_DETAILS(:RETURN_LOG);
      RETURN RETURN_LOG;
END;
$$;

GRANT USAGE ON PROCEDURE PLATFORM_DB.PROVISION_ROUTINE.SCHEMA_WRAPPER(VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR) TO ROLE PLATFORM_DB_PROVISION_ROUTINE_USAGE_ROLE;

