ALTER SESSION SET QUERY_TAG= 'TICKET#:RITM001874648,CR#:CHG000926911';

--Specific to SWE_DATACLOUD - staging database schemas with all objects
---SCHEMA Role with all access

SET V_TENANT_ABBREVIATION = 'CLAIMS_DATACLOUD';
SET V_SCHEMA_OBJECT_TYPE = '-ALL';

SET V_DATABASETYPENAME = 'CORE';
SET V_SCHEMASHORTNAME = '';  --and no postfix

--SCHEMATYPENAME will be SEMANTIC-ALL
SET V_TENANT_ID = (SELECT TENANT_ID FROM PLATFORM_DB.PROVISION_APP.TENANT_LIST WHERE TENANT_ABBREVIATION = $V_TENANT_ABBREVIATION);


SELECT $V_DATABASETYPENAME, $V_TENANT_ABBREVIATION, $V_SCHEMA_OBJECT_TYPE, $V_TENANT_ID;

select * from PLATFORM_DB.PROVISION_APP.SCHEMA_TYPE;

INSERT INTO PLATFORM_DB.PROVISION_APP.SCHEMA_TYPE(DATABASETYPEID,SCHEMATYPENAME, SCHEMASHORTNAME, TENANT_ID)
WITH DATABASETYPE_LIST AS (
   SELECT DATABASETYPEID FROM PLATFORM_DB.PROVISION_APP.DATABASETYPE WHERE DATABASETYPENAME=$V_DATABASETYPENAME
)
SELECT DATABASETYPEID, $V_DATABASETYPENAME || $V_SCHEMA_OBJECT_TYPE,$V_SCHEMASHORTNAME, $V_TENANT_ID FROM DATABASETYPE_LIST;

INSERT INTO PLATFORM_DB.PROVISION_APP.ROLE_MATRIX(DatabaseTypeID,SCHEMA_TYPEID,ROLENAME_TYPE, TENANT_ID )
WITH DatabaseType_list as (
   SELECT DATABASETYPEID FROM PLATFORM_DB.PROVISION_APP.DatabaseType WHERE DATABASETYPENAME=$V_DATABASETYPENAME
),
Schema_Type_list as ( SELECT SCHEMA_TYPEID FROM PLATFORM_DB.PROVISION_APP.Schema_Type
                     WHERE SchemaTypeName= $V_DATABASETYPENAME || $V_SCHEMA_OBJECT_TYPE
                    AND TENANT_ID = $V_TENANT_ID)
SELECT DATABASETYPEID,SCHEMA_TYPEID,'_MAIN_ROLE', $V_TENANT_ID  FROM DatabaseType_list,Schema_Type_list
UNION
SELECT DATABASETYPEID,SCHEMA_TYPEID,'_DML_ROLE', $V_TENANT_ID  FROM DatabaseType_list,Schema_Type_list
UNION
SELECT DATABASETYPEID,SCHEMA_TYPEID,'_READ_ROLE', $V_TENANT_ID  FROM DatabaseType_list,Schema_Type_list;

INSERT INTO PLATFORM_DB.PROVISION_APP.Privileges_matrix(ROLETYPE_ID,DATABASETYPEID,SCHEMA_TYPEID,PRIVILEGEID, TENANT_ID)
WITH DatabaseType_list as (
   SELECT DATABASETYPEID FROM PLATFORM_DB.PROVISION_APP.DatabaseType WHERE DATABASETYPENAME=$V_DATABASETYPENAME
),
Schema_Type_list as (
SELECT S.SCHEMA_TYPEID,S.DATABASETYPEID FROM  PLATFORM_DB.PROVISION_APP.Schema_Type S INNER JOIN DatabaseType_list D
WHERE SchemaTypeName= $V_DATABASETYPENAME || $V_SCHEMA_OBJECT_TYPE AND
 S.DATABASETYPEID=D.DATABASETYPEID AND TENANT_ID = $V_TENANT_ID),
Role_matrix_list as (
SELECT R.* FROM Schema_Type_list S INNER JOIN PLATFORM_DB.PROVISION_APP.ROLE_MATRIX R on R.SCHEMA_TYPEID=S.SCHEMA_TYPEID
and S.DATABASETYPEID=R.DATABASETYPEID and R.ROLENAME_TYPE='_MAIN_ROLE' AND R.TENANT_ID = $V_TENANT_ID)
SELECT R.ROLETYPE_ID,R.DATABASETYPEID,R.SCHEMA_TYPEID,P.PRIVILEGEID, $V_TENANT_ID FROM
Role_matrix_list R, PLATFORM_DB.PROVISION_APP.Privilege_Mapping P where
PRIVILEGE in ('USAGE') and ON_TAG in ('DATABASE','SCHEMA');



--grant create table on schema to main role
INSERT INTO PLATFORM_DB.PROVISION_APP.Privileges_matrix(ROLETYPE_ID,DATABASETYPEID,SCHEMA_TYPEID,PRIVILEGEID, TENANT_ID)
WITH DatabaseType_list as (
   SELECT DATABASETYPEID FROM PLATFORM_DB.PROVISION_APP.DatabaseType WHERE DATABASETYPENAME = $V_DATABASETYPENAME
),
Schema_Type_list as (
SELECT S.SCHEMA_TYPEID,S.DATABASETYPEID FROM  PLATFORM_DB.PROVISION_APP.Schema_Type S INNER JOIN DatabaseType_list D
WHERE SchemaTypeName= $V_DATABASETYPENAME || $V_SCHEMA_OBJECT_TYPE AND
 S.DATABASETYPEID=D.DATABASETYPEID AND TENANT_ID = $V_TENANT_ID),
Role_matrix_list as (
SELECT R.* FROM Schema_Type_list S INNER JOIN PLATFORM_DB.PROVISION_APP.ROLE_MATRIX R on R.SCHEMA_TYPEID=S.SCHEMA_TYPEID
and S.DATABASETYPEID=R.DATABASETYPEID and R.ROLENAME_TYPE='_MAIN_ROLE' AND R.TENANT_ID = $V_TENANT_ID)
SELECT R.ROLETYPE_ID,R.DATABASETYPEID,R.SCHEMA_TYPEID,P.PRIVILEGEID, $V_TENANT_ID FROM
Role_matrix_list R, PLATFORM_DB.PROVISION_APP.Privilege_Mapping P where
PRIVILEGE in ('CREATE TABLE', 'CREATE VIEW', 'CREATE FUNCTION', 'CREATE PROCEDURE', 'CREATE STREAM', 'CREATE TASK', 'CREATE FILE FORMAT', 'CREATE SEQUENCE','CREATE MATERIALIZED VIEW') and ON_TAG in ('SCHEMA')  ;

-- grant DELETE, INSERT,  SELECT, TRUNCATE, UPDATE - TABLES (CURRENT & FUTURE) to main role
INSERT INTO PLATFORM_DB.PROVISION_APP.Privileges_matrix(ROLETYPE_ID,DATABASETYPEID,SCHEMA_TYPEID,PRIVILEGEID, TENANT_ID)
WITH DatabaseType_list as (
   SELECT DATABASETYPEID FROM PLATFORM_DB.PROVISION_APP.DatabaseType WHERE DATABASETYPENAME = $V_DATABASETYPENAME
),
Schema_Type_list as (
SELECT S.SCHEMA_TYPEID,S.DATABASETYPEID FROM  PLATFORM_DB.PROVISION_APP.Schema_Type S INNER JOIN DatabaseType_list D
WHERE SchemaTypeName= $V_DATABASETYPENAME || $V_SCHEMA_OBJECT_TYPE AND
 S.DATABASETYPEID=D.DATABASETYPEID AND TENANT_ID = $V_TENANT_ID),
Role_matrix_list as (
SELECT R.* FROM Schema_Type_list S INNER JOIN PLATFORM_DB.PROVISION_APP.ROLE_MATRIX R on R.SCHEMA_TYPEID=S.SCHEMA_TYPEID
and S.DATABASETYPEID=R.DATABASETYPEID and R.ROLENAME_TYPE='_MAIN_ROLE' AND R.TENANT_ID = $V_TENANT_ID)
SELECT R.ROLETYPE_ID,R.DATABASETYPEID,R.SCHEMA_TYPEID,P.PRIVILEGEID, $V_TENANT_ID FROM
Role_matrix_list R, PLATFORM_DB.PROVISION_APP.Privilege_Mapping P where
PRIVILEGE in ('DELETE','INSERT','SELECT','TRUNCATE','UPDATE') and ON_TAG in ('ALL TABLES','FUTURE TABLES');

--MAIN ROLE - USAGE ON FUNCTIONS, PROCEDURES, SEQUENCE, STATE
INSERT INTO PLATFORM_DB.PROVISION_APP.Privileges_matrix(ROLETYPE_ID,DATABASETYPEID,SCHEMA_TYPEID,PRIVILEGEID, TENANT_ID)
WITH DatabaseType_list as (
   SELECT DATABASETYPEID FROM PLATFORM_DB.PROVISION_APP.DatabaseType WHERE DATABASETYPENAME = $V_DATABASETYPENAME
),
Schema_Type_list as (
SELECT S.SCHEMA_TYPEID,S.DATABASETYPEID FROM  PLATFORM_DB.PROVISION_APP.Schema_Type S INNER JOIN DatabaseType_list D
WHERE SchemaTypeName= $V_DATABASETYPENAME || $V_SCHEMA_OBJECT_TYPE AND
 S.DATABASETYPEID=D.DATABASETYPEID AND TENANT_ID = $V_TENANT_ID),
Role_matrix_list as (
SELECT R.* FROM Schema_Type_list S INNER JOIN PLATFORM_DB.PROVISION_APP.ROLE_MATRIX R on R.SCHEMA_TYPEID=S.SCHEMA_TYPEID
and S.DATABASETYPEID=R.DATABASETYPEID and R.ROLENAME_TYPE='_MAIN_ROLE' AND R.TENANT_ID = $V_TENANT_ID)
SELECT R.ROLETYPE_ID,R.DATABASETYPEID,R.SCHEMA_TYPEID,P.PRIVILEGEID, $V_TENANT_ID FROM
Role_matrix_list R, PLATFORM_DB.PROVISION_APP.Privilege_Mapping P where
PRIVILEGE in ('USAGE') and ON_TAG in ('ALL FILE FORMATS', 'FUTURE FILE FORMATS', 'ALL SEQUENCES', 'FUTURE SEQUENCES', 'ALL FUNCTIONS','FUTURE FUNCTIONS', 'ALL PROCEDURES', 'FUTURE PROCEDURES');

--SELECT streams
INSERT INTO PLATFORM_DB.PROVISION_APP.Privileges_matrix(ROLETYPE_ID,DATABASETYPEID,SCHEMA_TYPEID,PRIVILEGEID, TENANT_ID)
WITH DatabaseType_list as (
   SELECT DATABASETYPEID FROM PLATFORM_DB.PROVISION_APP.DatabaseType WHERE DATABASETYPENAME = $V_DATABASETYPENAME
),
Schema_Type_list as (
SELECT S.SCHEMA_TYPEID,S.DATABASETYPEID FROM  PLATFORM_DB.PROVISION_APP.Schema_Type S INNER JOIN DatabaseType_list D
WHERE SchemaTypeName= $V_DATABASETYPENAME || $V_SCHEMA_OBJECT_TYPE AND
 S.DATABASETYPEID=D.DATABASETYPEID AND TENANT_ID = $V_TENANT_ID),
Role_matrix_list as (
SELECT R.* FROM Schema_Type_list S INNER JOIN PLATFORM_DB.PROVISION_APP.ROLE_MATRIX R on R.SCHEMA_TYPEID=S.SCHEMA_TYPEID
and S.DATABASETYPEID=R.DATABASETYPEID and R.ROLENAME_TYPE='_MAIN_ROLE' AND R.TENANT_ID = $V_TENANT_ID)
SELECT R.ROLETYPE_ID,R.DATABASETYPEID,R.SCHEMA_TYPEID,P.PRIVILEGEID, $V_TENANT_ID FROM
Role_matrix_list R, PLATFORM_DB.PROVISION_APP.Privilege_Mapping P where
PRIVILEGE in ('SELECT') and ON_TAG in ('ALL VIEWS','FUTURE VIEWS','ALL STREAMS','FUTURE STREAMS');


--OPERATE ON PIPES streams
--Bulk grant is not allowed on pipes - as of yet  - 'ALL PIPES','FUTURE PIPES',
--below command is not ran
--OPERATE ON  streams
INSERT INTO PLATFORM_DB.PROVISION_APP.Privileges_matrix(ROLETYPE_ID,DATABASETYPEID,SCHEMA_TYPEID,PRIVILEGEID, TENANT_ID)
WITH DatabaseType_list as (
   SELECT DATABASETYPEID FROM PLATFORM_DB.PROVISION_APP.DatabaseType WHERE DATABASETYPENAME = $V_DATABASETYPENAME
),
Schema_Type_list as (
SELECT S.SCHEMA_TYPEID,S.DATABASETYPEID FROM  PLATFORM_DB.PROVISION_APP.Schema_Type S INNER JOIN DatabaseType_list D
WHERE SchemaTypeName= $V_DATABASETYPENAME || $V_SCHEMA_OBJECT_TYPE AND
 S.DATABASETYPEID=D.DATABASETYPEID AND TENANT_ID = $V_TENANT_ID),
Role_matrix_list as (
SELECT R.* FROM Schema_Type_list S INNER JOIN PLATFORM_DB.PROVISION_APP.ROLE_MATRIX R on R.SCHEMA_TYPEID=S.SCHEMA_TYPEID
and S.DATABASETYPEID=R.DATABASETYPEID and R.ROLENAME_TYPE='_MAIN_ROLE' AND R.TENANT_ID = $V_TENANT_ID)
SELECT R.ROLETYPE_ID,R.DATABASETYPEID,R.SCHEMA_TYPEID,P.PRIVILEGEID, $V_TENANT_ID FROM
Role_matrix_list R, PLATFORM_DB.PROVISION_APP.Privilege_Mapping P where
PRIVILEGE in ('OPERATE') and ON_TAG in ('ALL TASKS','FUTURE TASKS');



INSERT INTO PLATFORM_DB.PROVISION_APP.Privileges_matrix(ROLETYPE_ID,DATABASETYPEID,SCHEMA_TYPEID,PRIVILEGEID, TENANT_ID)
WITH DatabaseType_list as (
   SELECT DATABASETYPEID FROM PLATFORM_DB.PROVISION_APP.DatabaseType WHERE DATABASETYPENAME = $V_DATABASETYPENAME
),
Schema_Type_list as (
SELECT S.SCHEMA_TYPEID,S.DATABASETYPEID FROM  PLATFORM_DB.PROVISION_APP.Schema_Type S INNER JOIN DatabaseType_list D
WHERE SchemaTypeName= $V_DATABASETYPENAME || $V_SCHEMA_OBJECT_TYPE AND
 S.DATABASETYPEID=D.DATABASETYPEID AND TENANT_ID = $V_TENANT_ID),
Role_matrix_list as (
SELECT R.* FROM Schema_Type_list S INNER JOIN PLATFORM_DB.PROVISION_APP.ROLE_MATRIX R on R.SCHEMA_TYPEID=S.SCHEMA_TYPEID
and S.DATABASETYPEID=R.DATABASETYPEID and R.ROLENAME_TYPE='_MAIN_ROLE' AND R.TENANT_ID = $V_TENANT_ID)
SELECT R.ROLETYPE_ID,R.DATABASETYPEID,R.SCHEMA_TYPEID,P.PRIVILEGEID, $V_TENANT_ID FROM
Role_matrix_list R, PLATFORM_DB.PROVISION_APP.Privilege_Mapping P where
PRIVILEGE in ('SELECT') and ON_TAG in ('ALL MATERIALIZED VIEWS','FUTURE MATERIALIZED VIEWS');



--OWNERSHIP

INSERT INTO PLATFORM_DB.PROVISION_APP.Privileges_matrix(ROLETYPE_ID,DATABASETYPEID,SCHEMA_TYPEID,PRIVILEGEID, TENANT_ID)
WITH DatabaseType_list as (
   SELECT DATABASETYPEID FROM PLATFORM_DB.PROVISION_APP.DatabaseType WHERE DATABASETYPENAME = $V_DATABASETYPENAME
),
Schema_Type_list as (
SELECT S.SCHEMA_TYPEID,S.DATABASETYPEID FROM  PLATFORM_DB.PROVISION_APP.Schema_Type S INNER JOIN DatabaseType_list D
WHERE SchemaTypeName= $V_DATABASETYPENAME || $V_SCHEMA_OBJECT_TYPE AND
 S.DATABASETYPEID=D.DATABASETYPEID AND TENANT_ID = $V_TENANT_ID),
Role_matrix_list as (
SELECT R.* FROM Schema_Type_list S INNER JOIN PLATFORM_DB.PROVISION_APP.ROLE_MATRIX R on R.SCHEMA_TYPEID=S.SCHEMA_TYPEID
and S.DATABASETYPEID=R.DATABASETYPEID and R.ROLENAME_TYPE='_MAIN_ROLE' AND R.TENANT_ID = $V_TENANT_ID)
SELECT R.ROLETYPE_ID,R.DATABASETYPEID,R.SCHEMA_TYPEID,P.PRIVILEGEID, $V_TENANT_ID FROM
Role_matrix_list R, PLATFORM_DB.PROVISION_APP.Privilege_Mapping P where
PRIVILEGE in ('OWNERSHIP') and ON_TAG in (
'ALL TABLES','FUTURE TABLES',
'ALL VIEWS','FUTURE VIEWS',
'ALL FUNCTIONS','FUTURE FUNCTIONS',
'ALL PROCEDURES','FUTURE PROCEDURES',
'ALL STREAMS','FUTURE STREAMS',
'ALL FILE FORMATS','FUTURE FILE FORMATS',
'ALL SEQUENCES','FUTURE SEQUENCES',
'ALL TASKS','FUTURE TASKS'
);

--------- DML ROLE


INSERT INTO PLATFORM_DB.PROVISION_APP.Privileges_matrix(ROLETYPE_ID,DATABASETYPEID,SCHEMA_TYPEID,PRIVILEGEID, TENANT_ID)
WITH DatabaseType_list as (
   SELECT DATABASETYPEID FROM PLATFORM_DB.PROVISION_APP.DatabaseType WHERE DATABASETYPENAME=$V_DATABASETYPENAME
),
Schema_Type_list as (
SELECT S.SCHEMA_TYPEID,S.DATABASETYPEID FROM  PLATFORM_DB.PROVISION_APP.Schema_Type S INNER JOIN DatabaseType_list D
WHERE SchemaTypeName= $V_DATABASETYPENAME || $V_SCHEMA_OBJECT_TYPE AND
 S.DATABASETYPEID=D.DATABASETYPEID AND TENANT_ID = $V_TENANT_ID),
Role_matrix_list as (
SELECT R.* FROM Schema_Type_list S INNER JOIN PLATFORM_DB.PROVISION_APP.ROLE_MATRIX R on R.SCHEMA_TYPEID=S.SCHEMA_TYPEID
and S.DATABASETYPEID=R.DATABASETYPEID and R.ROLENAME_TYPE='_DML_ROLE' AND R.TENANT_ID = $V_TENANT_ID)
SELECT R.ROLETYPE_ID,R.DATABASETYPEID,R.SCHEMA_TYPEID,P.PRIVILEGEID, $V_TENANT_ID FROM
Role_matrix_list R, PLATFORM_DB.PROVISION_APP.Privilege_Mapping P where
PRIVILEGE in ('USAGE') and ON_TAG in ('DATABASE','SCHEMA');



-- grant DELETE, INSERT,  SELECT, TRUNCATE, UPDATE - TABLES (CURRENT & FUTURE) to main role
INSERT INTO PLATFORM_DB.PROVISION_APP.Privileges_matrix(ROLETYPE_ID,DATABASETYPEID,SCHEMA_TYPEID,PRIVILEGEID, TENANT_ID)
WITH DatabaseType_list as (
   SELECT DATABASETYPEID FROM PLATFORM_DB.PROVISION_APP.DatabaseType WHERE DATABASETYPENAME = $V_DATABASETYPENAME
),
Schema_Type_list as (
SELECT S.SCHEMA_TYPEID,S.DATABASETYPEID FROM  PLATFORM_DB.PROVISION_APP.Schema_Type S INNER JOIN DatabaseType_list D
WHERE SchemaTypeName= $V_DATABASETYPENAME || $V_SCHEMA_OBJECT_TYPE AND
 S.DATABASETYPEID=D.DATABASETYPEID AND TENANT_ID = $V_TENANT_ID),
Role_matrix_list as (
SELECT R.* FROM Schema_Type_list S INNER JOIN PLATFORM_DB.PROVISION_APP.ROLE_MATRIX R on R.SCHEMA_TYPEID=S.SCHEMA_TYPEID
and S.DATABASETYPEID=R.DATABASETYPEID and R.ROLENAME_TYPE='_DML_ROLE' AND R.TENANT_ID = $V_TENANT_ID)
SELECT R.ROLETYPE_ID,R.DATABASETYPEID,R.SCHEMA_TYPEID,P.PRIVILEGEID, $V_TENANT_ID FROM
Role_matrix_list R, PLATFORM_DB.PROVISION_APP.Privilege_Mapping P where
PRIVILEGE in ('DELETE','INSERT','SELECT','TRUNCATE','UPDATE') and ON_TAG in ('ALL TABLES','FUTURE TABLES');

--MAIN ROLE - USAGE ON FUNCTIONS, PROCEDURES, SEQUENCE, STATE
INSERT INTO PLATFORM_DB.PROVISION_APP.Privileges_matrix(ROLETYPE_ID,DATABASETYPEID,SCHEMA_TYPEID,PRIVILEGEID, TENANT_ID)
WITH DatabaseType_list as (
   SELECT DATABASETYPEID FROM PLATFORM_DB.PROVISION_APP.DatabaseType WHERE DATABASETYPENAME = $V_DATABASETYPENAME
),
Schema_Type_list as (
SELECT S.SCHEMA_TYPEID,S.DATABASETYPEID FROM  PLATFORM_DB.PROVISION_APP.Schema_Type S INNER JOIN DatabaseType_list D
WHERE SchemaTypeName= $V_DATABASETYPENAME || $V_SCHEMA_OBJECT_TYPE AND
 S.DATABASETYPEID=D.DATABASETYPEID AND TENANT_ID = $V_TENANT_ID),
Role_matrix_list as (
SELECT R.* FROM Schema_Type_list S INNER JOIN PLATFORM_DB.PROVISION_APP.ROLE_MATRIX R on R.SCHEMA_TYPEID=S.SCHEMA_TYPEID
and S.DATABASETYPEID=R.DATABASETYPEID and R.ROLENAME_TYPE='_DML_ROLE' AND R.TENANT_ID = $V_TENANT_ID)
SELECT R.ROLETYPE_ID,R.DATABASETYPEID,R.SCHEMA_TYPEID,P.PRIVILEGEID, $V_TENANT_ID FROM
Role_matrix_list R, PLATFORM_DB.PROVISION_APP.Privilege_Mapping P where
PRIVILEGE in ('USAGE') and ON_TAG in ('ALL FILE FORMATS', 'FUTURE FILE FORMATS', 'ALL SEQUENCES', 'FUTURE SEQUENCES', 'ALL FUNCTIONS','FUTURE FUNCTIONS', 'ALL PROCEDURES', 'FUTURE PROCEDURES');


--SELECT streams
INSERT INTO PLATFORM_DB.PROVISION_APP.Privileges_matrix(ROLETYPE_ID,DATABASETYPEID,SCHEMA_TYPEID,PRIVILEGEID, TENANT_ID)
WITH DatabaseType_list as (
   SELECT DATABASETYPEID FROM PLATFORM_DB.PROVISION_APP.DatabaseType WHERE DATABASETYPENAME = $V_DATABASETYPENAME
),
Schema_Type_list as (
SELECT S.SCHEMA_TYPEID,S.DATABASETYPEID FROM  PLATFORM_DB.PROVISION_APP.Schema_Type S INNER JOIN DatabaseType_list D
WHERE SchemaTypeName= $V_DATABASETYPENAME || $V_SCHEMA_OBJECT_TYPE AND
 S.DATABASETYPEID=D.DATABASETYPEID AND TENANT_ID = $V_TENANT_ID),
Role_matrix_list as (
SELECT R.* FROM Schema_Type_list S INNER JOIN PLATFORM_DB.PROVISION_APP.ROLE_MATRIX R on R.SCHEMA_TYPEID=S.SCHEMA_TYPEID
and S.DATABASETYPEID=R.DATABASETYPEID and R.ROLENAME_TYPE='_DML_ROLE' AND R.TENANT_ID = $V_TENANT_ID)
SELECT R.ROLETYPE_ID,R.DATABASETYPEID,R.SCHEMA_TYPEID,P.PRIVILEGEID, $V_TENANT_ID FROM
Role_matrix_list R, PLATFORM_DB.PROVISION_APP.Privilege_Mapping P where
PRIVILEGE in ('SELECT') and ON_TAG in ('ALL VIEWS','FUTURE VIEWS','ALL STREAMS','FUTURE STREAMS');



--OPERATE ON streams
--Bulk grant is not allowed on pipes - as of yet  - 'ALL PIPES','FUTURE PIPES',
--below command is not ran
--OPERATE ON  streams
INSERT INTO PLATFORM_DB.PROVISION_APP.Privileges_matrix(ROLETYPE_ID,DATABASETYPEID,SCHEMA_TYPEID,PRIVILEGEID, TENANT_ID)
WITH DatabaseType_list as (
   SELECT DATABASETYPEID FROM PLATFORM_DB.PROVISION_APP.DatabaseType WHERE DATABASETYPENAME = $V_DATABASETYPENAME
),
Schema_Type_list as (
SELECT S.SCHEMA_TYPEID,S.DATABASETYPEID FROM  PLATFORM_DB.PROVISION_APP.Schema_Type S INNER JOIN DatabaseType_list D
WHERE SchemaTypeName= $V_DATABASETYPENAME || $V_SCHEMA_OBJECT_TYPE AND
 S.DATABASETYPEID=D.DATABASETYPEID AND TENANT_ID = $V_TENANT_ID),
Role_matrix_list as (
SELECT R.* FROM Schema_Type_list S INNER JOIN PLATFORM_DB.PROVISION_APP.ROLE_MATRIX R on R.SCHEMA_TYPEID=S.SCHEMA_TYPEID
and S.DATABASETYPEID=R.DATABASETYPEID and R.ROLENAME_TYPE='_DML_ROLE' AND R.TENANT_ID = $V_TENANT_ID)
SELECT R.ROLETYPE_ID,R.DATABASETYPEID,R.SCHEMA_TYPEID,P.PRIVILEGEID, $V_TENANT_ID FROM
Role_matrix_list R, PLATFORM_DB.PROVISION_APP.Privilege_Mapping P where
PRIVILEGE in ('OPERATE') and ON_TAG in ('ALL TASKS','FUTURE TASKS');


INSERT INTO PLATFORM_DB.PROVISION_APP.Privileges_matrix(ROLETYPE_ID,DATABASETYPEID,SCHEMA_TYPEID,PRIVILEGEID, TENANT_ID)
WITH DatabaseType_list as (
   SELECT DATABASETYPEID FROM PLATFORM_DB.PROVISION_APP.DatabaseType WHERE DATABASETYPENAME = $V_DATABASETYPENAME
),
Schema_Type_list as (
SELECT S.SCHEMA_TYPEID,S.DATABASETYPEID FROM  PLATFORM_DB.PROVISION_APP.Schema_Type S INNER JOIN DatabaseType_list D
WHERE SchemaTypeName= $V_DATABASETYPENAME || $V_SCHEMA_OBJECT_TYPE AND
 S.DATABASETYPEID=D.DATABASETYPEID AND TENANT_ID = $V_TENANT_ID),
Role_matrix_list as (
SELECT R.* FROM Schema_Type_list S INNER JOIN PLATFORM_DB.PROVISION_APP.ROLE_MATRIX R on R.SCHEMA_TYPEID=S.SCHEMA_TYPEID
and S.DATABASETYPEID=R.DATABASETYPEID and R.ROLENAME_TYPE='_DML_ROLE' AND R.TENANT_ID = $V_TENANT_ID)
SELECT R.ROLETYPE_ID,R.DATABASETYPEID,R.SCHEMA_TYPEID,P.PRIVILEGEID, $V_TENANT_ID FROM
Role_matrix_list R, PLATFORM_DB.PROVISION_APP.Privilege_Mapping P where
PRIVILEGE in ('SELECT') and ON_TAG in ('ALL MATERIALIZED VIEWS','FUTURE MATERIALIZED VIEWS');


-- READ ROLE
INSERT INTO PLATFORM_DB.PROVISION_APP.Privileges_matrix(ROLETYPE_ID,DATABASETYPEID,SCHEMA_TYPEID,PRIVILEGEID, TENANT_ID)
WITH DatabaseType_list as (
   SELECT DATABASETYPEID FROM PLATFORM_DB.PROVISION_APP.DatabaseType WHERE DATABASETYPENAME=$V_DATABASETYPENAME
),
Schema_Type_list as (
SELECT S.SCHEMA_TYPEID,S.DATABASETYPEID FROM  PLATFORM_DB.PROVISION_APP.Schema_Type S INNER JOIN DatabaseType_list D
WHERE SchemaTypeName= $V_DATABASETYPENAME || $V_SCHEMA_OBJECT_TYPE AND
 S.DATABASETYPEID=D.DATABASETYPEID AND TENANT_ID = $V_TENANT_ID),
Role_matrix_list as (
SELECT R.* FROM Schema_Type_list S INNER JOIN PLATFORM_DB.PROVISION_APP.ROLE_MATRIX R on R.SCHEMA_TYPEID=S.SCHEMA_TYPEID
and S.DATABASETYPEID=R.DATABASETYPEID and R.ROLENAME_TYPE='_READ_ROLE' AND R.TENANT_ID = $V_TENANT_ID)
SELECT R.ROLETYPE_ID,R.DATABASETYPEID,R.SCHEMA_TYPEID,P.PRIVILEGEID, $V_TENANT_ID FROM
Role_matrix_list R, PLATFORM_DB.PROVISION_APP.Privilege_Mapping P where
PRIVILEGE in ('USAGE') and ON_TAG in ('DATABASE','SCHEMA');

-- grant DELETE, INSERT,  SELECT, TRUNCATE, UPDATE - TABLES (CURRENT & FUTURE) to main role
INSERT INTO PLATFORM_DB.PROVISION_APP.Privileges_matrix(ROLETYPE_ID,DATABASETYPEID,SCHEMA_TYPEID,PRIVILEGEID, TENANT_ID)
WITH DatabaseType_list as (
   SELECT DATABASETYPEID FROM PLATFORM_DB.PROVISION_APP.DatabaseType WHERE DATABASETYPENAME = $V_DATABASETYPENAME
),
Schema_Type_list as (
SELECT S.SCHEMA_TYPEID,S.DATABASETYPEID FROM  PLATFORM_DB.PROVISION_APP.Schema_Type S INNER JOIN DatabaseType_list D
WHERE SchemaTypeName= $V_DATABASETYPENAME || $V_SCHEMA_OBJECT_TYPE AND
 S.DATABASETYPEID=D.DATABASETYPEID AND TENANT_ID = $V_TENANT_ID),
Role_matrix_list as (
SELECT R.* FROM Schema_Type_list S INNER JOIN PLATFORM_DB.PROVISION_APP.ROLE_MATRIX R on R.SCHEMA_TYPEID=S.SCHEMA_TYPEID
and S.DATABASETYPEID=R.DATABASETYPEID and R.ROLENAME_TYPE='_READ_ROLE' AND R.TENANT_ID = $V_TENANT_ID)
SELECT R.ROLETYPE_ID,R.DATABASETYPEID,R.SCHEMA_TYPEID,P.PRIVILEGEID, $V_TENANT_ID FROM
Role_matrix_list R, PLATFORM_DB.PROVISION_APP.Privilege_Mapping P where
PRIVILEGE in ('SELECT') and ON_TAG in ('ALL TABLES','FUTURE TABLES');

--MAIN ROLE - USAGE ON FUNCTIONS, PROCEDURES, SEQUENCE, STATE
INSERT INTO PLATFORM_DB.PROVISION_APP.Privileges_matrix(ROLETYPE_ID,DATABASETYPEID,SCHEMA_TYPEID,PRIVILEGEID, TENANT_ID)
WITH DatabaseType_list as (
   SELECT DATABASETYPEID FROM PLATFORM_DB.PROVISION_APP.DatabaseType WHERE DATABASETYPENAME = $V_DATABASETYPENAME
),
Schema_Type_list as (
SELECT S.SCHEMA_TYPEID,S.DATABASETYPEID FROM  PLATFORM_DB.PROVISION_APP.Schema_Type S INNER JOIN DatabaseType_list D
WHERE SchemaTypeName= $V_DATABASETYPENAME || $V_SCHEMA_OBJECT_TYPE AND
 S.DATABASETYPEID=D.DATABASETYPEID AND TENANT_ID = $V_TENANT_ID),
Role_matrix_list as (
SELECT R.* FROM Schema_Type_list S INNER JOIN PLATFORM_DB.PROVISION_APP.ROLE_MATRIX R on R.SCHEMA_TYPEID=S.SCHEMA_TYPEID
and S.DATABASETYPEID=R.DATABASETYPEID and R.ROLENAME_TYPE='_READ_ROLE' AND R.TENANT_ID = $V_TENANT_ID)
SELECT R.ROLETYPE_ID,R.DATABASETYPEID,R.SCHEMA_TYPEID,P.PRIVILEGEID, $V_TENANT_ID FROM
Role_matrix_list R, PLATFORM_DB.PROVISION_APP.Privilege_Mapping P where
PRIVILEGE in ('USAGE') and ON_TAG in ('ALL FILE FORMATS', 'FUTURE FILE FORMATS', 'ALL SEQUENCES', 'FUTURE SEQUENCES', 'ALL FUNCTIONS','FUTURE FUNCTIONS', 'ALL PROCEDURES', 'FUTURE PROCEDURES');


--SELECT streams
INSERT INTO PLATFORM_DB.PROVISION_APP.Privileges_matrix(ROLETYPE_ID,DATABASETYPEID,SCHEMA_TYPEID,PRIVILEGEID, TENANT_ID)
WITH DatabaseType_list as (
   SELECT DATABASETYPEID FROM PLATFORM_DB.PROVISION_APP.DatabaseType WHERE DATABASETYPENAME = $V_DATABASETYPENAME
),
Schema_Type_list as (
SELECT S.SCHEMA_TYPEID,S.DATABASETYPEID FROM  PLATFORM_DB.PROVISION_APP.Schema_Type S INNER JOIN DatabaseType_list D
WHERE SchemaTypeName= $V_DATABASETYPENAME || $V_SCHEMA_OBJECT_TYPE AND
 S.DATABASETYPEID=D.DATABASETYPEID AND TENANT_ID = $V_TENANT_ID),
Role_matrix_list as (
SELECT R.* FROM Schema_Type_list S INNER JOIN PLATFORM_DB.PROVISION_APP.ROLE_MATRIX R on R.SCHEMA_TYPEID=S.SCHEMA_TYPEID
and S.DATABASETYPEID=R.DATABASETYPEID and R.ROLENAME_TYPE='_READ_ROLE' AND R.TENANT_ID = $V_TENANT_ID)
SELECT R.ROLETYPE_ID,R.DATABASETYPEID,R.SCHEMA_TYPEID,P.PRIVILEGEID, $V_TENANT_ID FROM
Role_matrix_list R, PLATFORM_DB.PROVISION_APP.Privilege_Mapping P where
PRIVILEGE in ('SELECT') and ON_TAG in ('ALL VIEWS','FUTURE VIEWS','ALL STREAMS','FUTURE STREAMS');




--OPERATE ON streams
--Bulk grant is not allowed on pipes - as of yet  - 'ALL PIPES','FUTURE PIPES',
--below command is not ran
--OPERATE ON  streams

INSERT INTO PLATFORM_DB.PROVISION_APP.Privileges_matrix(ROLETYPE_ID,DATABASETYPEID,SCHEMA_TYPEID,PRIVILEGEID, TENANT_ID)
WITH DatabaseType_list as (
   SELECT DATABASETYPEID FROM PLATFORM_DB.PROVISION_APP.DatabaseType WHERE DATABASETYPENAME = $V_DATABASETYPENAME
),
Schema_Type_list as (
SELECT S.SCHEMA_TYPEID,S.DATABASETYPEID FROM  PLATFORM_DB.PROVISION_APP.Schema_Type S INNER JOIN DatabaseType_list D
WHERE SchemaTypeName= $V_DATABASETYPENAME || $V_SCHEMA_OBJECT_TYPE AND
 S.DATABASETYPEID=D.DATABASETYPEID AND TENANT_ID = $V_TENANT_ID),
Role_matrix_list as (
SELECT R.* FROM Schema_Type_list S INNER JOIN PLATFORM_DB.PROVISION_APP.ROLE_MATRIX R on R.SCHEMA_TYPEID=S.SCHEMA_TYPEID
and S.DATABASETYPEID=R.DATABASETYPEID and R.ROLENAME_TYPE='_READ_ROLE' AND R.TENANT_ID = $V_TENANT_ID)
SELECT R.ROLETYPE_ID,R.DATABASETYPEID,R.SCHEMA_TYPEID,P.PRIVILEGEID, $V_TENANT_ID FROM
Role_matrix_list R, PLATFORM_DB.PROVISION_APP.Privilege_Mapping P where
PRIVILEGE in ('MONITOR') and ON_TAG in ('ALL TASKS','FUTURE TASKS');


INSERT INTO PLATFORM_DB.PROVISION_APP.Privileges_matrix(ROLETYPE_ID,DATABASETYPEID,SCHEMA_TYPEID,PRIVILEGEID, TENANT_ID)
WITH DatabaseType_list as (
   SELECT DATABASETYPEID FROM PLATFORM_DB.PROVISION_APP.DatabaseType WHERE DATABASETYPENAME = $V_DATABASETYPENAME
),
Schema_Type_list as (
SELECT S.SCHEMA_TYPEID,S.DATABASETYPEID FROM  PLATFORM_DB.PROVISION_APP.Schema_Type S INNER JOIN DatabaseType_list D
WHERE SchemaTypeName= $V_DATABASETYPENAME || $V_SCHEMA_OBJECT_TYPE AND
 S.DATABASETYPEID=D.DATABASETYPEID AND TENANT_ID = $V_TENANT_ID),
Role_matrix_list as (
SELECT R.* FROM Schema_Type_list S INNER JOIN PLATFORM_DB.PROVISION_APP.ROLE_MATRIX R on R.SCHEMA_TYPEID=S.SCHEMA_TYPEID
and S.DATABASETYPEID=R.DATABASETYPEID and R.ROLENAME_TYPE='_READ_ROLE' AND R.TENANT_ID = $V_TENANT_ID)
SELECT R.ROLETYPE_ID,R.DATABASETYPEID,R.SCHEMA_TYPEID,P.PRIVILEGEID, $V_TENANT_ID FROM
Role_matrix_list R, PLATFORM_DB.PROVISION_APP.Privilege_Mapping P where
PRIVILEGE in ('SELECT') and ON_TAG in ('ALL MATERIALIZED VIEWS','FUTURE MATERIALIZED VIEWS');

ALTER SESSION UNSET QUERY_TAG;