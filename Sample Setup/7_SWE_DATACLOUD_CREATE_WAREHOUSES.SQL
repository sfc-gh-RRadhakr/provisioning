ALTER SESSION SET QUERY_TAG= 'TICKET#:RITM001874648,CR#:CHG000926911';

use role sysadmin;
set ticket_comment = 'LOB:SWE,SUB_LOB:SWE_DATACLOUD,TICKET#:RITM001874648';
set tenant_name = 'SWE_DATACLOUD';
set rm_name = 'SWE_DATACLOUD_RM';

--create
CALL ACDP_PLATFORM_DB.PLATFORM_ROUTINE.RESOURCE_MONITOR_WRAPPER(
    P_ACTION => 'CREATE'
   ,P_RM_NAME => $rm_name
   ,P_USER_COMMENT => $ticket_comment
   ,P_CREDIT_QUOTA => '250000'
   ,P_FREQUENCY => 'MONTHLY'
   ,P_START_TIMESTOPS => 'IMMEDIATELY'
   ,P_TENANT_NAME => $tenant_name
);


--show resource monitors;

use role sysadmin;

set ticket_comment = 'LOB:SWE,SUB_LOB:SWE_DATACLOUD,TICKET#:RITM001874648';
set tenant_name = 'SWE_DATACLOUD';
set rm_name = 'SWE_DATACLOUD_RM';


set wh_name = 'SWE_DATACLOUD_DATA_ENG_VWH';
select $wh_name, $ticket_comment, $rm_name, $tenant_name;

CALL ACDP_PLATFORM_DB.PLATFORM_ROUTINE.WAREHOUSE_WRAPPER(
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
set wh_name = 'SWE_DATACLOUD_CORE_ETL_VWH';
select $wh_name, $ticket_comment, $rm_name, $tenant_name;

CALL ACDP_PLATFORM_DB.PLATFORM_ROUTINE.WAREHOUSE_WRAPPER(
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
set wh_name = 'SWE_DATACLOUD_DATA_SCIENCE_VWH';
select $wh_name, $ticket_comment, $rm_name, $tenant_name;

CALL ACDP_PLATFORM_DB.PLATFORM_ROUTINE.WAREHOUSE_WRAPPER(
    P_ACTION => 'CREATE',
    P_WH_NAME => $wh_name,
    P_WH_COMMENT => $ticket_comment,
    P_USER_COMMENT => $ticket_comment,
    P_WH_SIZE => 'LARGE',
    P_MAX_CLUSTERS => '1',
    P_MIN_CLUSTERS => '1',
    P_SCALING_POLICY => 'STANDARD',
    P_AUTO_SUSPEND_IN_SECONDS => '60',
    P_STATEMENT_TIMEOUT_IN_SECONDS => '7200',
    P_RESOURCE_MONITOR => $rm_name,
    P_STATEMENT_QUEUED_TIMEOUT_IN_SECONDS  => '7200',
    P_TENANT_NAME => $tenant_name
);

 
 
set wh_name = 'SWE_DATACLOUD_SEMANTIC_VWH';
select $wh_name, $ticket_comment, $rm_name, $tenant_name;

CALL ACDP_PLATFORM_DB.PLATFORM_ROUTINE.WAREHOUSE_WRAPPER(
    P_ACTION => 'CREATE',
    P_WH_NAME => $wh_name,
    P_WH_COMMENT => $ticket_comment,
    P_USER_COMMENT => $ticket_comment,
    P_WH_SIZE => 'SMALL',
    P_MAX_CLUSTERS => '1',
    P_MIN_CLUSTERS => '1',
    P_SCALING_POLICY => 'STANDARD',
    P_AUTO_SUSPEND_IN_SECONDS => '60',
    P_STATEMENT_TIMEOUT_IN_SECONDS => '7200',
    P_RESOURCE_MONITOR => $rm_name,
    P_STATEMENT_QUEUED_TIMEOUT_IN_SECONDS  => '7200',
    P_TENANT_NAME => $tenant_name
);

set wh_name = 'SWE_DATACLOUD_ADHOC_VWH';
select $wh_name, $ticket_comment, $rm_name, $tenant_name;

CALL ACDP_PLATFORM_DB.PLATFORM_ROUTINE.WAREHOUSE_WRAPPER(
    P_ACTION => 'CREATE',
    P_WH_NAME => $wh_name,
    P_WH_COMMENT => $ticket_comment,
    P_USER_COMMENT => $ticket_comment,
    P_WH_SIZE => 'XSMALL',
    P_MAX_CLUSTERS => '1',
    P_MIN_CLUSTERS => '1',
    P_SCALING_POLICY => 'STANDARD',
    P_AUTO_SUSPEND_IN_SECONDS => '60',
    P_STATEMENT_TIMEOUT_IN_SECONDS => '7200',
    P_RESOURCE_MONITOR => $rm_name,
    P_STATEMENT_QUEUED_TIMEOUT_IN_SECONDS  => '7200',
    P_TENANT_NAME => $tenant_name
);

 

ALTER SESSION UNSET QUERY_TAG;

--SHOW WAREHOUSES LIKE 'SWE_DATACLOUD%';