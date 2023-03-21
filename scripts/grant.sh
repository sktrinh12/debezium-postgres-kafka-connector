#!/bin/bash

sqlplus / as sysdba <<EOF
  CREATE TABLESPACE logminer_tbs DATAFILE '/oradata/ORA_DM/logminer_tbs.dbf'
    SIZE 25M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED;
  exit;
EOF

sqlplus / as sysdba <<EOF
  CREATE USER c##dbzuser IDENTIFIED BY dbz
    DEFAULT TABLESPACE logminer_tbs
    QUOTA UNLIMITED ON logminer_tbs
    ;

  GRANT CREATE SESSION TO c##dbzuser ; 
  GRANT SET CONTAINER TO c##dbzuser ; 
  GRANT SELECT ON V_$DATABASE to c##dbzuser ; 
  GRANT FLASHBACK ANY TABLE TO c##dbzuser ; 
  GRANT SELECT ANY TABLE TO c##dbzuser ; 
  GRANT SELECT_CATALOG_ROLE TO c##dbzuser ; 
  GRANT EXECUTE_CATALOG_ROLE TO c##dbzuser ; 
  GRANT SELECT ANY TRANSACTION TO c##dbzuser ; 
  GRANT LOGMINING TO c##dbzuser ; 

  GRANT CREATE TABLE TO c##dbzuser ; 
  GRANT LOCK ANY TABLE TO c##dbzuser ; 
  GRANT CREATE SEQUENCE TO c##dbzuser ; 

  GRANT EXECUTE ON DBMS_LOGMNR TO c##dbzuser ; 
  GRANT EXECUTE ON DBMS_LOGMNR_D TO c##dbzuser ; 

  GRANT SELECT ON V_$LOG TO c##dbzuser ; 
  GRANT SELECT ON V_$LOG_HISTORY TO c##dbzuser ; 
  GRANT SELECT ON V_$LOGMNR_LOGS TO c##dbzuser ; 
  GRANT SELECT ON V_$LOGMNR_CONTENTS TO c##dbzuser ; 
  GRANT SELECT ON V_$LOGMNR_PARAMETERS TO c##dbzuser ; 
  GRANT SELECT ON V_$LOGFILE TO c##dbzuser ; 
  GRANT SELECT ON V_$ARCHIVED_LOG TO c##dbzuser ; 
  GRANT SELECT ON V_$ARCHIVE_DEST_STATUS TO c##dbzuser ; 
  GRANT SELECT ON V_$TRANSACTION TO c##dbzuser ; 

EOF
