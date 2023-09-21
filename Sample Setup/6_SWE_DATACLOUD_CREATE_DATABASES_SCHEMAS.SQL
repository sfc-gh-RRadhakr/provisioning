ALTER SESSION SET QUERY_TAG= 'TICKET#:RITM001874648,CR#:CHG000926911';

use role sysadmin;


set ticket_comment = 'LOB:SWE,SUB_LOB:SWE_DATACLOUD,TICKET#:RITM001874648';
set tenant_name = 'SWE_DATACLOUD';

set db_name = 'SWE_DATACLOUD_SEMANTIC_DB';

CALL ACDP_PLATFORM_DB.PLATFORM_ROUTINE.DATABASE_WRAPPER(
    P_ACTION => 'CREATE',
    P_DB_NAME => $db_name,
    P_DB_COMMENT => $ticket_comment,
    P_USER_COMMENT =>  $ticket_comment,
    P_DATA_RETENTION_TIME_IN_DAYS => '14',
    P_TENANT_NAME => $tenant_name
);

set db_name = 'SWE_DATACLOUD_CORE_DB';

CALL ACDP_PLATFORM_DB.PLATFORM_ROUTINE.DATABASE_WRAPPER(
    P_ACTION => 'CREATE',
    P_DB_NAME => $db_name,
    P_DB_COMMENT => $ticket_comment,
    P_USER_COMMENT =>  $ticket_comment,
    P_DATA_RETENTION_TIME_IN_DAYS => '14',
    P_TENANT_NAME => $tenant_name
);

set db_name = 'SWE_DATACLOUD_STAGING_DB';

CALL ACDP_PLATFORM_DB.PLATFORM_ROUTINE.DATABASE_WRAPPER(
    P_ACTION => 'CREATE',
    P_DB_NAME => $db_name,
    P_DB_COMMENT => $ticket_comment,
    P_USER_COMMENT =>  $ticket_comment,
    P_DATA_RETENTION_TIME_IN_DAYS => '5',
    P_TENANT_NAME => $tenant_name
);

set db_name = 'SWE_DATACLOUD_DATA_ENG_DB';

CALL ACDP_PLATFORM_DB.PLATFORM_ROUTINE.DATABASE_WRAPPER(
    P_ACTION => 'CREATE',
    P_DB_NAME => $db_name,
    P_DB_COMMENT => $ticket_comment,
    P_USER_COMMENT =>  $ticket_comment,
    P_DATA_RETENTION_TIME_IN_DAYS => '14',
    P_TENANT_NAME => $tenant_name
);

set db_name = 'SWE_DATACLOUD_DATA_LAKE_DB';

CALL ACDP_PLATFORM_DB.PLATFORM_ROUTINE.DATABASE_WRAPPER(
    P_ACTION => 'CREATE',
    P_DB_NAME => $db_name,
    P_DB_COMMENT => $ticket_comment,
    P_USER_COMMENT =>  $ticket_comment,
    P_DATA_RETENTION_TIME_IN_DAYS => '14',
    P_TENANT_NAME => $tenant_name
);

ALTER SESSION UNSET QUERY_TAG;

------------------------------------------------------------------------


 
  USE ROLE SYSADMIN;

  set tenant_name = 'SWE_DATACLOUD';
  set ticket_comment = 'LOB:SWE,SUB_LOB:SWE_DATACLOUD,TICKET#:RITM001874648';

  set db_type = 'STAGE';
  set db_name = 'SWE_DATACLOUD_STAGING_DB';


set sc_name = 'OS_SCHEDULE';
CALL ACDP_PLATFORM_DB.PLATFORM_ROUTINE.SCHEMA_WRAPPER(
   P_ACTION => 'CREATE'
  ,P_DATABASE_TYPE => $db_type
  ,P_DATABASE_NAME => $db_name
  ,P_SCHEMA_NAME => $sc_name
  ,P_DATA_RETENTION_TIME_IN_DAYS => '5'
  ,P_SCHEMA_COMMENT  => $ticket_comment
  ,P_USER_COMMENT  => $ticket_comment
  ,P_USER_PASSWORD => ''
  ,P_MANAGED_ACCESS_SCHEMA => ''
  ,P_TENANT_NAME => $tenant_name
);
set sc_name = 'OS_LIVABILITY';
CALL ACDP_PLATFORM_DB.PLATFORM_ROUTINE.SCHEMA_WRAPPER(
   P_ACTION => 'CREATE'
  ,P_DATABASE_TYPE => $db_type
  ,P_DATABASE_NAME => $db_name
  ,P_SCHEMA_NAME => $sc_name
  ,P_DATA_RETENTION_TIME_IN_DAYS => '5'
  ,P_SCHEMA_COMMENT  => $ticket_comment
  ,P_USER_COMMENT  => $ticket_comment
  ,P_USER_PASSWORD => ''
  ,P_MANAGED_ACCESS_SCHEMA => ''
  ,P_TENANT_NAME => $tenant_name
);
set sc_name = 'LUXON';
CALL ACDP_PLATFORM_DB.PLATFORM_ROUTINE.SCHEMA_WRAPPER(
   P_ACTION => 'CREATE'
  ,P_DATABASE_TYPE => $db_type
  ,P_DATABASE_NAME => $db_name
  ,P_SCHEMA_NAME => $sc_name
  ,P_DATA_RETENTION_TIME_IN_DAYS => '5'
  ,P_SCHEMA_COMMENT  => $ticket_comment
  ,P_USER_COMMENT  => $ticket_comment
  ,P_USER_PASSWORD => ''
  ,P_MANAGED_ACCESS_SCHEMA => ''
  ,P_TENANT_NAME => $tenant_name
);
set sc_name = 'RADAR';
CALL ACDP_PLATFORM_DB.PLATFORM_ROUTINE.SCHEMA_WRAPPER(
   P_ACTION => 'CREATE'
  ,P_DATABASE_TYPE => $db_type
  ,P_DATABASE_NAME => $db_name
  ,P_SCHEMA_NAME => $sc_name
  ,P_DATA_RETENTION_TIME_IN_DAYS => '5'
  ,P_SCHEMA_COMMENT  => $ticket_comment
  ,P_USER_COMMENT  => $ticket_comment
  ,P_USER_PASSWORD => ''
  ,P_MANAGED_ACCESS_SCHEMA => ''
  ,P_TENANT_NAME => $tenant_name
);
set sc_name = 'XBS';
CALL ACDP_PLATFORM_DB.PLATFORM_ROUTINE.SCHEMA_WRAPPER(
   P_ACTION => 'CREATE'
  ,P_DATABASE_TYPE => $db_type
  ,P_DATABASE_NAME => $db_name
  ,P_SCHEMA_NAME => $sc_name
  ,P_DATA_RETENTION_TIME_IN_DAYS => '5'
  ,P_SCHEMA_COMMENT  => $ticket_comment
  ,P_USER_COMMENT  => $ticket_comment
  ,P_USER_PASSWORD => ''
  ,P_MANAGED_ACCESS_SCHEMA => ''
  ,P_TENANT_NAME => $tenant_name
);
/*
 
SWE_DATACLOUD_STAGING_DB.MONORAIL
SWE_DATACLOUD_STAGING_DB.BATS
SWE_DATACLOUD_STAGING_DB.ATP
SWE_DATACLOUD_STAGING_DB.SKYWAGON_CORP
SWE_DATACLOUD_STAGING_DB.RESULTS_SERVICE
*/
set sc_name = 'GUARDIAN';
CALL ACDP_PLATFORM_DB.PLATFORM_ROUTINE.SCHEMA_WRAPPER(
   P_ACTION => 'CREATE'
  ,P_DATABASE_TYPE => $db_type
  ,P_DATABASE_NAME => $db_name
  ,P_SCHEMA_NAME => $sc_name
  ,P_DATA_RETENTION_TIME_IN_DAYS => '7'
  ,P_SCHEMA_COMMENT  => $ticket_comment
  ,P_USER_COMMENT  => $ticket_comment
  ,P_USER_PASSWORD => ''
  ,P_MANAGED_ACCESS_SCHEMA => ''
  ,P_TENANT_NAME => $tenant_name
);
set sc_name = 'TRAINSTATION';
CALL ACDP_PLATFORM_DB.PLATFORM_ROUTINE.SCHEMA_WRAPPER(
   P_ACTION => 'CREATE'
  ,P_DATABASE_TYPE => $db_type
  ,P_DATABASE_NAME => $db_name
  ,P_SCHEMA_NAME => $sc_name
  ,P_DATA_RETENTION_TIME_IN_DAYS => '7'
  ,P_SCHEMA_COMMENT  => $ticket_comment
  ,P_USER_COMMENT  => $ticket_comment
  ,P_USER_PASSWORD => ''
  ,P_MANAGED_ACCESS_SCHEMA => ''
  ,P_TENANT_NAME => $tenant_name
);
set sc_name = 'PROJECT_SETS';
CALL ACDP_PLATFORM_DB.PLATFORM_ROUTINE.SCHEMA_WRAPPER(
   P_ACTION => 'CREATE'
  ,P_DATABASE_TYPE => $db_type
  ,P_DATABASE_NAME => $db_name
  ,P_SCHEMA_NAME => $sc_name
  ,P_DATA_RETENTION_TIME_IN_DAYS => '7'
  ,P_SCHEMA_COMMENT  => $ticket_comment
  ,P_USER_COMMENT  => $ticket_comment
  ,P_USER_PASSWORD => ''
  ,P_MANAGED_ACCESS_SCHEMA => ''
  ,P_TENANT_NAME => $tenant_name
);
set sc_name = 'GITHUB';
CALL ACDP_PLATFORM_DB.PLATFORM_ROUTINE.SCHEMA_WRAPPER(
   P_ACTION => 'CREATE'
  ,P_DATABASE_TYPE => $db_type
  ,P_DATABASE_NAME => $db_name
  ,P_SCHEMA_NAME => $sc_name
  ,P_DATA_RETENTION_TIME_IN_DAYS => '7'
  ,P_SCHEMA_COMMENT  => $ticket_comment
  ,P_USER_COMMENT  => $ticket_comment
  ,P_USER_PASSWORD => ''
  ,P_MANAGED_ACCESS_SCHEMA => ''
  ,P_TENANT_NAME => $tenant_name
);
set sc_name = 'BITBUCKET';
CALL ACDP_PLATFORM_DB.PLATFORM_ROUTINE.SCHEMA_WRAPPER(
   P_ACTION => 'CREATE'
  ,P_DATABASE_TYPE => $db_type
  ,P_DATABASE_NAME => $db_name
  ,P_SCHEMA_NAME => $sc_name
  ,P_DATA_RETENTION_TIME_IN_DAYS => '7'
  ,P_SCHEMA_COMMENT  => $ticket_comment
  ,P_USER_COMMENT  => $ticket_comment
  ,P_USER_PASSWORD => ''
  ,P_MANAGED_ACCESS_SCHEMA => ''
  ,P_TENANT_NAME => $tenant_name
);

 
set sc_name = 'MONORAIL';
CALL ACDP_PLATFORM_DB.PLATFORM_ROUTINE.SCHEMA_WRAPPER(
   P_ACTION => 'CREATE'
  ,P_DATABASE_TYPE => $db_type
  ,P_DATABASE_NAME => $db_name
  ,P_SCHEMA_NAME => $sc_name
  ,P_DATA_RETENTION_TIME_IN_DAYS => '7'
  ,P_SCHEMA_COMMENT  => $ticket_comment
  ,P_USER_COMMENT  => $ticket_comment
  ,P_USER_PASSWORD => ''
  ,P_MANAGED_ACCESS_SCHEMA => ''
  ,P_TENANT_NAME => $tenant_name
);
set sc_name = 'BATS';
CALL ACDP_PLATFORM_DB.PLATFORM_ROUTINE.SCHEMA_WRAPPER(
   P_ACTION => 'CREATE'
  ,P_DATABASE_TYPE => $db_type
  ,P_DATABASE_NAME => $db_name
  ,P_SCHEMA_NAME => $sc_name
  ,P_DATA_RETENTION_TIME_IN_DAYS => '7'
  ,P_SCHEMA_COMMENT  => $ticket_comment
  ,P_USER_COMMENT  => $ticket_comment
  ,P_USER_PASSWORD => ''
  ,P_MANAGED_ACCESS_SCHEMA => ''
  ,P_TENANT_NAME => $tenant_name
);
set sc_name = 'ATP';
CALL ACDP_PLATFORM_DB.PLATFORM_ROUTINE.SCHEMA_WRAPPER(
   P_ACTION => 'CREATE'
  ,P_DATABASE_TYPE => $db_type
  ,P_DATABASE_NAME => $db_name
  ,P_SCHEMA_NAME => $sc_name
  ,P_DATA_RETENTION_TIME_IN_DAYS => '7'
  ,P_SCHEMA_COMMENT  => $ticket_comment
  ,P_USER_COMMENT  => $ticket_comment
  ,P_USER_PASSWORD => ''
  ,P_MANAGED_ACCESS_SCHEMA => ''
  ,P_TENANT_NAME => $tenant_name
);
set sc_name = 'SKYWAGON_CORP';
CALL ACDP_PLATFORM_DB.PLATFORM_ROUTINE.SCHEMA_WRAPPER(
   P_ACTION => 'CREATE'
  ,P_DATABASE_TYPE => $db_type
  ,P_DATABASE_NAME => $db_name
  ,P_SCHEMA_NAME => $sc_name
  ,P_DATA_RETENTION_TIME_IN_DAYS => '7'
  ,P_SCHEMA_COMMENT  => $ticket_comment
  ,P_USER_COMMENT  => $ticket_comment
  ,P_USER_PASSWORD => ''
  ,P_MANAGED_ACCESS_SCHEMA => ''
  ,P_TENANT_NAME => $tenant_name
);
set sc_name = 'RESULTS_SERVICE';
CALL ACDP_PLATFORM_DB.PLATFORM_ROUTINE.SCHEMA_WRAPPER(
   P_ACTION => 'CREATE'
  ,P_DATABASE_TYPE => $db_type
  ,P_DATABASE_NAME => $db_name
  ,P_SCHEMA_NAME => $sc_name
  ,P_DATA_RETENTION_TIME_IN_DAYS => '7'
  ,P_SCHEMA_COMMENT  => $ticket_comment
  ,P_USER_COMMENT  => $ticket_comment
  ,P_USER_PASSWORD => ''
  ,P_MANAGED_ACCESS_SCHEMA => ''
  ,P_TENANT_NAME => $tenant_name
);

 

-- -------------------------------------
 set db_type = 'CORE';
set sc_name = 'BASE';
set db_name = 'SWE_DATACLOUD_CORE_DB';
CALL ACDP_PLATFORM_DB.PLATFORM_ROUTINE.SCHEMA_WRAPPER(
   P_ACTION => 'CREATE'
  ,P_DATABASE_TYPE => $db_type
  ,P_DATABASE_NAME => $db_name
  ,P_SCHEMA_NAME => $sc_name
  ,P_DATA_RETENTION_TIME_IN_DAYS => '7'
  ,P_SCHEMA_COMMENT  => $ticket_comment
  ,P_USER_COMMENT  => $ticket_comment
  ,P_USER_PASSWORD => ''
  ,P_MANAGED_ACCESS_SCHEMA => ''
  ,P_TENANT_NAME => $tenant_name
);

set db_type = 'SEMANTIC';
set sc_name = 'SWE_ANALYTICS';
set db_name = 'SWE_DATACLOUD_SEMANTIC_DB';
CALL ACDP_PLATFORM_DB.PLATFORM_ROUTINE.SCHEMA_WRAPPER(
   P_ACTION => 'CREATE'
  ,P_DATABASE_TYPE => $db_type
  ,P_DATABASE_NAME => $db_name
  ,P_SCHEMA_NAME => $sc_name
  ,P_DATA_RETENTION_TIME_IN_DAYS => '7'
  ,P_SCHEMA_COMMENT  => $ticket_comment
  ,P_USER_COMMENT  => $ticket_comment
  ,P_USER_PASSWORD => ''
  ,P_MANAGED_ACCESS_SCHEMA => ''
  ,P_TENANT_NAME => $tenant_name
);

 
set db_type = 'DATAENG';
set db_name = 'SWE_DATACLOUD_DATA_ENG_DB';

set sc_name = 'CICD';
CALL ACDP_PLATFORM_DB.PLATFORM_ROUTINE.SCHEMA_WRAPPER(
   P_ACTION => 'CREATE'
  ,P_DATABASE_TYPE => $db_type
  ,P_DATABASE_NAME => $db_name
  ,P_SCHEMA_NAME => $sc_name
  ,P_DATA_RETENTION_TIME_IN_DAYS => '7'
  ,P_SCHEMA_COMMENT  => $ticket_comment
  ,P_USER_COMMENT  => $ticket_comment
  ,P_USER_PASSWORD => ''
  ,P_MANAGED_ACCESS_SCHEMA => ''
  ,P_TENANT_NAME => $tenant_name
);
set sc_name = 'GH_ROBERTS';
CALL ACDP_PLATFORM_DB.PLATFORM_ROUTINE.SCHEMA_WRAPPER(
   P_ACTION => 'CREATE'
  ,P_DATABASE_TYPE => $db_type
  ,P_DATABASE_NAME => $db_name
  ,P_SCHEMA_NAME => $sc_name
  ,P_DATA_RETENTION_TIME_IN_DAYS => '7'
  ,P_SCHEMA_COMMENT  => $ticket_comment
  ,P_USER_COMMENT  => $ticket_comment
  ,P_USER_PASSWORD => ''
  ,P_MANAGED_ACCESS_SCHEMA => ''
  ,P_TENANT_NAME => $tenant_name
);
set sc_name = 'NHUNT';
CALL ACDP_PLATFORM_DB.PLATFORM_ROUTINE.SCHEMA_WRAPPER(
   P_ACTION => 'CREATE'
  ,P_DATABASE_TYPE => $db_type
  ,P_DATABASE_NAME => $db_name
  ,P_SCHEMA_NAME => $sc_name
  ,P_DATA_RETENTION_TIME_IN_DAYS => '7'
  ,P_SCHEMA_COMMENT  => $ticket_comment
  ,P_USER_COMMENT  => $ticket_comment
  ,P_USER_PASSWORD => ''
  ,P_MANAGED_ACCESS_SCHEMA => ''
  ,P_TENANT_NAME => $tenant_name
);

---------------------------
SWE_DATACLOUD_DATA_LAKE_DB.OS_SCHEDULE_S3
SWE_DATACLOUD_DATA_LAKE_DB.OS_LIVABILITY_S3
SWE_DATACLOUD_DATA_LAKE_DB.LUXON_S3
SWE_DATACLOUD_DATA_LAKE_DB.RADAR_S3
SWE_DATACLOUD_DATA_LAKE_DB.XBS_S3
SWE_DATACLOUD_DATA_LAKE_DB.GUARDIAN_S3
SWE_DATACLOUD_DATA_LAKE_DB.TRAINSTATION_S3
SWE_DATACLOUD_DATA_LAKE_DB.PROJECT_SETS_S3
SWE_DATACLOUD_DATA_LAKE_DB.GITHUB_S3
SWE_DATACLOUD_DATA_LAKE_DB.BITBUCKET_S3
SWE_DATACLOUD_DATA_LAKE_DB.MONORAIL_S3
SWE_DATACLOUD_DATA_LAKE_DB.BATS_S3
SWE_DATACLOUD_DATA_LAKE_DB.ATP_S3
SWE_DATACLOUD_DATA_LAKE_DB.SKYWAGON_CORP_S3
SWE_DATACLOUD_DATA_LAKE_DB.RESULTS_SERVICE_S3

set db_type = 'DATALAKE';
set db_name = 'SWE_DATACLOUD_DATA_LAKE_DB';

set sc_name = 'OS_SCHEDULE_S3';
CALL ACDP_PLATFORM_DB.PLATFORM_ROUTINE.SCHEMA_WRAPPER(
   P_ACTION => 'CREATE'
  ,P_DATABASE_TYPE => $db_type
  ,P_DATABASE_NAME => $db_name
  ,P_SCHEMA_NAME => $sc_name
  ,P_DATA_RETENTION_TIME_IN_DAYS => '7'
  ,P_SCHEMA_COMMENT  => $ticket_comment
  ,P_USER_COMMENT  => $ticket_comment
  ,P_USER_PASSWORD => ''
  ,P_MANAGED_ACCESS_SCHEMA => ''
  ,P_TENANT_NAME => $tenant_name
);
set sc_name = 'OS_LIVABILITY_S3';
CALL ACDP_PLATFORM_DB.PLATFORM_ROUTINE.SCHEMA_WRAPPER(
   P_ACTION => 'CREATE'
  ,P_DATABASE_TYPE => $db_type
  ,P_DATABASE_NAME => $db_name
  ,P_SCHEMA_NAME => $sc_name
  ,P_DATA_RETENTION_TIME_IN_DAYS => '7'
  ,P_SCHEMA_COMMENT  => $ticket_comment
  ,P_USER_COMMENT  => $ticket_comment
  ,P_USER_PASSWORD => ''
  ,P_MANAGED_ACCESS_SCHEMA => ''
  ,P_TENANT_NAME => $tenant_name
);

set sc_name = 'LUXON_S3';
CALL ACDP_PLATFORM_DB.PLATFORM_ROUTINE.SCHEMA_WRAPPER(
   P_ACTION => 'CREATE'
  ,P_DATABASE_TYPE => $db_type
  ,P_DATABASE_NAME => $db_name
  ,P_SCHEMA_NAME => $sc_name
  ,P_DATA_RETENTION_TIME_IN_DAYS => '7'
  ,P_SCHEMA_COMMENT  => $ticket_comment
  ,P_USER_COMMENT  => $ticket_comment
  ,P_USER_PASSWORD => ''
  ,P_MANAGED_ACCESS_SCHEMA => ''
  ,P_TENANT_NAME => $tenant_name
);
set sc_name = 'RADAR_S3';
CALL ACDP_PLATFORM_DB.PLATFORM_ROUTINE.SCHEMA_WRAPPER(
   P_ACTION => 'CREATE'
  ,P_DATABASE_TYPE => $db_type
  ,P_DATABASE_NAME => $db_name
  ,P_SCHEMA_NAME => $sc_name
  ,P_DATA_RETENTION_TIME_IN_DAYS => '7'
  ,P_SCHEMA_COMMENT  => $ticket_comment
  ,P_USER_COMMENT  => $ticket_comment
  ,P_USER_PASSWORD => ''
  ,P_MANAGED_ACCESS_SCHEMA => ''
  ,P_TENANT_NAME => $tenant_name
);
set sc_name = 'XBS_S3';
CALL ACDP_PLATFORM_DB.PLATFORM_ROUTINE.SCHEMA_WRAPPER(
   P_ACTION => 'CREATE'
  ,P_DATABASE_TYPE => $db_type
  ,P_DATABASE_NAME => $db_name
  ,P_SCHEMA_NAME => $sc_name
  ,P_DATA_RETENTION_TIME_IN_DAYS => '7'
  ,P_SCHEMA_COMMENT  => $ticket_comment
  ,P_USER_COMMENT  => $ticket_comment
  ,P_USER_PASSWORD => ''
  ,P_MANAGED_ACCESS_SCHEMA => ''
  ,P_TENANT_NAME => $tenant_name
);
set sc_name = 'GUARDIAN_S3';
CALL ACDP_PLATFORM_DB.PLATFORM_ROUTINE.SCHEMA_WRAPPER(
   P_ACTION => 'CREATE'
  ,P_DATABASE_TYPE => $db_type
  ,P_DATABASE_NAME => $db_name
  ,P_SCHEMA_NAME => $sc_name
  ,P_DATA_RETENTION_TIME_IN_DAYS => '7'
  ,P_SCHEMA_COMMENT  => $ticket_comment
  ,P_USER_COMMENT  => $ticket_comment
  ,P_USER_PASSWORD => ''
  ,P_MANAGED_ACCESS_SCHEMA => ''
  ,P_TENANT_NAME => $tenant_name
);
set sc_name = 'TRAINSTATION_S3';
CALL ACDP_PLATFORM_DB.PLATFORM_ROUTINE.SCHEMA_WRAPPER(
   P_ACTION => 'CREATE'
  ,P_DATABASE_TYPE => $db_type
  ,P_DATABASE_NAME => $db_name
  ,P_SCHEMA_NAME => $sc_name
  ,P_DATA_RETENTION_TIME_IN_DAYS => '7'
  ,P_SCHEMA_COMMENT  => $ticket_comment
  ,P_USER_COMMENT  => $ticket_comment
  ,P_USER_PASSWORD => ''
  ,P_MANAGED_ACCESS_SCHEMA => ''
  ,P_TENANT_NAME => $tenant_name
);
set sc_name = 'PROJECT_SETS_S3';
CALL ACDP_PLATFORM_DB.PLATFORM_ROUTINE.SCHEMA_WRAPPER(
   P_ACTION => 'CREATE'
  ,P_DATABASE_TYPE => $db_type
  ,P_DATABASE_NAME => $db_name
  ,P_SCHEMA_NAME => $sc_name
  ,P_DATA_RETENTION_TIME_IN_DAYS => '7'
  ,P_SCHEMA_COMMENT  => $ticket_comment
  ,P_USER_COMMENT  => $ticket_comment
  ,P_USER_PASSWORD => ''
  ,P_MANAGED_ACCESS_SCHEMA => ''
  ,P_TENANT_NAME => $tenant_name
);

set sc_name = 'GITHUB_S3';
CALL ACDP_PLATFORM_DB.PLATFORM_ROUTINE.SCHEMA_WRAPPER(
   P_ACTION => 'CREATE'
  ,P_DATABASE_TYPE => $db_type
  ,P_DATABASE_NAME => $db_name
  ,P_SCHEMA_NAME => $sc_name
  ,P_DATA_RETENTION_TIME_IN_DAYS => '7'
  ,P_SCHEMA_COMMENT  => $ticket_comment
  ,P_USER_COMMENT  => $ticket_comment
  ,P_USER_PASSWORD => ''
  ,P_MANAGED_ACCESS_SCHEMA => ''
  ,P_TENANT_NAME => $tenant_name
);
set sc_name = 'BITBUCKET_S3';
CALL ACDP_PLATFORM_DB.PLATFORM_ROUTINE.SCHEMA_WRAPPER(
   P_ACTION => 'CREATE'
  ,P_DATABASE_TYPE => $db_type
  ,P_DATABASE_NAME => $db_name
  ,P_SCHEMA_NAME => $sc_name
  ,P_DATA_RETENTION_TIME_IN_DAYS => '7'
  ,P_SCHEMA_COMMENT  => $ticket_comment
  ,P_USER_COMMENT  => $ticket_comment
  ,P_USER_PASSWORD => ''
  ,P_MANAGED_ACCESS_SCHEMA => ''
  ,P_TENANT_NAME => $tenant_name
);

set sc_name = 'MONORAIL_S3';
CALL ACDP_PLATFORM_DB.PLATFORM_ROUTINE.SCHEMA_WRAPPER(
   P_ACTION => 'CREATE'
  ,P_DATABASE_TYPE => $db_type
  ,P_DATABASE_NAME => $db_name
  ,P_SCHEMA_NAME => $sc_name
  ,P_DATA_RETENTION_TIME_IN_DAYS => '7'
  ,P_SCHEMA_COMMENT  => $ticket_comment
  ,P_USER_COMMENT  => $ticket_comment
  ,P_USER_PASSWORD => ''
  ,P_MANAGED_ACCESS_SCHEMA => ''
  ,P_TENANT_NAME => $tenant_name
);

set sc_name = 'BATS_S3';
CALL ACDP_PLATFORM_DB.PLATFORM_ROUTINE.SCHEMA_WRAPPER(
   P_ACTION => 'CREATE'
  ,P_DATABASE_TYPE => $db_type
  ,P_DATABASE_NAME => $db_name
  ,P_SCHEMA_NAME => $sc_name
  ,P_DATA_RETENTION_TIME_IN_DAYS => '7'
  ,P_SCHEMA_COMMENT  => $ticket_comment
  ,P_USER_COMMENT  => $ticket_comment
  ,P_USER_PASSWORD => ''
  ,P_MANAGED_ACCESS_SCHEMA => ''
  ,P_TENANT_NAME => $tenant_name
);

set sc_name = 'ATP_S3';
CALL ACDP_PLATFORM_DB.PLATFORM_ROUTINE.SCHEMA_WRAPPER(
   P_ACTION => 'CREATE'
  ,P_DATABASE_TYPE => $db_type
  ,P_DATABASE_NAME => $db_name
  ,P_SCHEMA_NAME => $sc_name
  ,P_DATA_RETENTION_TIME_IN_DAYS => '7'
  ,P_SCHEMA_COMMENT  => $ticket_comment
  ,P_USER_COMMENT  => $ticket_comment
  ,P_USER_PASSWORD => ''
  ,P_MANAGED_ACCESS_SCHEMA => ''
  ,P_TENANT_NAME => $tenant_name
);

set sc_name = 'SKYWAGON_CORP_S3';
CALL ACDP_PLATFORM_DB.PLATFORM_ROUTINE.SCHEMA_WRAPPER(
   P_ACTION => 'CREATE'
  ,P_DATABASE_TYPE => $db_type
  ,P_DATABASE_NAME => $db_name
  ,P_SCHEMA_NAME => $sc_name
  ,P_DATA_RETENTION_TIME_IN_DAYS => '7'
  ,P_SCHEMA_COMMENT  => $ticket_comment
  ,P_USER_COMMENT  => $ticket_comment
  ,P_USER_PASSWORD => ''
  ,P_MANAGED_ACCESS_SCHEMA => ''
  ,P_TENANT_NAME => $tenant_name
);.
set sc_name = 'RESULTS_SERVICE_S3';
CALL ACDP_PLATFORM_DB.PLATFORM_ROUTINE.SCHEMA_WRAPPER(
   P_ACTION => 'CREATE'
  ,P_DATABASE_TYPE => $db_type
  ,P_DATABASE_NAME => $db_name
  ,P_SCHEMA_NAME => $sc_name
  ,P_DATA_RETENTION_TIME_IN_DAYS => '7'
  ,P_SCHEMA_COMMENT  => $ticket_comment
  ,P_USER_COMMENT  => $ticket_comment
  ,P_USER_PASSWORD => ''
  ,P_MANAGED_ACCESS_SCHEMA => ''
  ,P_TENANT_NAME => $tenant_name
);


