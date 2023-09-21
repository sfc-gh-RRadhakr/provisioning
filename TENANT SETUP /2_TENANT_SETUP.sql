


/*
Example 1: Schema  as PRODUCT :
TENANT : CIDE_BOM

DATABASE :
    CIDE_BOM_SEMANTIC_DB
        -- APP1_SEMANTIC --> Schema 

Roles : Following roles are created
CIDE_BOM_SYSADMIN_ROLE
CIDE_BOM_SEMANTIC_DB_ALL_DML_ROLE
CIDE_BOM_SEMANTIC_DB_ALL_MAIN_ROLE
CIDE_BOM_SEMANTIC_DB_ALL_READ_ROLE

CIDE_BOM_SEMANTIC_DB_APP1_SEMANTIC_DML_ROLE
CIDE_BOM_SEMANTIC_DB_APP1_SEMANTIC_MAIN_ROLE
CIDE_BOM_SEMANTIC_DB_APP1_SEMANTIC_READ_ROLE

*/

-- Create Database 
use role sysadmin;
set ticket_comment = 'LOB:CIDE_BOM,SUB_LOB:CIDE_BOM,TICKET#:RITM001874648';
set tenant_name = 'CIDE_BOM';
set db_name = 'CIDE_BOM_SEMANTIC_DB';
set db_type='SEMANTIC';
 
CALL PLATFORM_DB.PROVISION_ROUTINE.DATABASE_WRAPPER(
    P_ACTION => 'CREATE',
    P_DB_NAME => $db_name,
    P_DB_TYPE=>$db_type ,
    P_DB_COMMENT => $ticket_comment,
    P_USER_COMMENT =>  $ticket_comment,
    P_DATA_RETENTION_TIME_IN_DAYS => '14',
    P_TENANT_NAME => $tenant_name
);


use ROLE SYSADMIN;
set tenant_name = 'CIDE_BOM';
set ticket_comment = 'LOB:KP,SUB_LOB:HI,TICKET#:RITM001874648';
set db_type = 'SEMANTIC'; -- Important to match the Database Type
set sc_type = 'SEMANTIC';
set db_name = 'CIDE_BOM_SEMANTIC_DB';-- Important
set sc_name = 'APP1_SEMANTIC';

CALL PLATFORM_DB.PROVISION_ROUTINE.SCHEMA_WRAPPER(
   P_ACTION => 'CREATE'
  ,P_DATABASE_TYPE => $db_type
  ,P_DATABASE_NAME => $db_name
  ,P_SCHEMA_TYPE => $sc_type
  ,P_SCHEMA_NAME => $sc_name
  ,P_DATA_RETENTION_TIME_IN_DAYS => '7'
  ,P_SCHEMA_COMMENT  => $ticket_comment
  ,P_USER_COMMENT  => $ticket_comment
  ,P_MANAGED_ACCESS_SCHEMA => ''
  ,P_TENANT_NAME => $tenant_name
);


/*
Example 2: Database  as PRODUCT :
TENANT : KP_WIS
KP_WIS_DB —>   DATABSE /TENANT
    STAGE   — > Schema 
    ENRICHED — > Schema 
    CURATED  — > Schema 
KP_WIS_DB_ALL_DML_ROLE
KP_WIS_DB_ALL_MAIN_ROLE
KP_WIS_DB_ALL_READ_ROLE
KP_WIS_DB_WIS_STAGE_DML_ROLE
KP_WIS_DB_WIS_STAGE_MAIN_ROLE
KP_WIS_DB_WIS_STAGE_READ_ROLE
KP_WIS_SYSADMIN_ROLE

*/

use role sysadmin;
set ticket_comment = 'LOB:KP_WIS,SUB_LOB:KP_WIS,TICKET#:RITM001874648';
set tenant_name = 'KP_WIS';  
set db_name = 'KP_WIS_DB';
set db_type='ALL';
 
CALL PLATFORM_DB.PROVISION_ROUTINE.DATABASE_WRAPPER(
    P_ACTION => 'CREATE',
    P_DB_NAME => $db_name,
    P_DB_TYPE=>$db_type ,
    P_DB_COMMENT => $ticket_comment,
    P_USER_COMMENT =>  $ticket_comment,
    P_DATA_RETENTION_TIME_IN_DAYS => '14',
    P_TENANT_NAME => $tenant_name
);

use ROLE SYSADMIN;
set tenant_name = 'KP_WIS';
set ticket_comment = 'LOB:KP,SUB_LOB:HI,TICKET#:RITM001874648';
set db_type = 'ALL';  
set sc_type = 'STAGE';
set db_name = 'KP_WIS_DB';-- Important
set sc_name = 'WIS_STAGE';

CALL PLATFORM_DB.PROVISION_ROUTINE.SCHEMA_WRAPPER(
   P_ACTION => 'CREATE'
  ,P_DATABASE_TYPE => $db_type
  ,P_DATABASE_NAME => $db_name
  ,P_SCHEMA_TYPE => $sc_type
  ,P_SCHEMA_NAME => $sc_name
  ,P_DATA_RETENTION_TIME_IN_DAYS => '7'
  ,P_SCHEMA_COMMENT  => $ticket_comment
  ,P_USER_COMMENT  => $ticket_comment
  ,P_MANAGED_ACCESS_SCHEMA => ''
  ,P_TENANT_NAME => $tenant_name
);

/*
RESOURCE MONITOR & WAREHOUSE 
tenant_name = 'KP_WIS';
*/


use role sysadmin;
set ticket_comment = 'LOB:KP,SUB_LOB:WIS,TICKET#:RITM001874648';
set tenant_name = 'KP_WIS';
set rm_name = 'KP_WIS_STAGE_RM'; 
set wh_name = 'KP_WIS_STAGE_VWH';
select $wh_name, $ticket_comment, $rm_name, $tenant_name;

CALL PLATFORM_DB.PROVISION_ROUTINE.WAREHOUSE_WRAPPER(
    P_ACTION => 'CREATE',
    P_WH_NAME => $wh_name,
    P_WH_COMMENT => $ticket_comment,
    P_USER_COMMENT => $ticket_comment,
    P_WH_SIZE => 'MEDIUM',
    P_MAX_CLUSTERS => '1',
    P_MIN_CLUSTERS => '1',
    P_SCALING_POLICY => 'STANDARD',
    P_AUTO_SUSPEND_IN_SECONDS => '60',
    P_STATEMENT_TIMEOUT_IN_SECONDS => '7200',
    P_RESOURCE_MONITOR => $rm_name,
    P_STATEMENT_QUEUED_TIMEOUT_IN_SECONDS  => '7200',
    P_TENANT_NAME => $tenant_name
);