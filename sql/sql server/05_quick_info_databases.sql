SELECT
    sd.NAME AS [DB_Name]
   ,sf .type_desc AS [File Type]
   ,sd .snapshot_isolation_state_desc AS [Snapshot Isolation]
   ,sd .database_id AS [Database_Id]
   ,sf .physical_name AS [Files]
   ,sf .state_desc AS [Status]
   ,sf .size AS [Size (MG)]
   ,sd .user_access_desc AS [Mode]
   ,sd .recovery_model_desc AS [Recovery_model]
   ,sd .compatibility_level AS [Compatibility_level]
   ,sd .page_verify_option_desc AS [Torn Page Detection]
   ,sd .user_access_desc AS [User Access Mode]
   ,sd .collation_name AS [Collation]
   ,'Disks_on_SAN' = CASE WHEN sf.physical_name LIKE '%C:\%' THEN 'N'
                          ELSE 'Y'
                     END
FROM
    sys. master_files sf
    JOIN sys.databases sd ON sf .database_id = sd.database_id