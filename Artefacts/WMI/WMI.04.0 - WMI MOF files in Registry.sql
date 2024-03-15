/************************** Sophos.com/RapidResponse *************************\
| DESCRIPTION                                                                 |
| Retrieves data from the registry key that stores data from Autorecover MOF  |
| files that are not in the system32\WBEM\ folder.                            |
|                                                                             |
| Query Type: Endpoint                                                        |
| Version: 1.0                                                                |
| Author: The Rapid Response Team                                             |
| github.com/SophosRapidResponse                                              |
\*****************************************************************************/



WITH RECURSIVE SplitLines AS (
SELECT
key_name,
value_name,
SUBSTR(value, 1, INSTR(value, ' ') - 1) AS line,
SUBSTR(value, INSTR(value, ' ') + 1) AS remaining_data
FROM
sophos_registry_journal
WHERE
key_name LIKE '\REGISTRY\MACHINE\SOFTWARE\Microsoft\Wbem\CIMOM' AND value_name = 'Autorecover MOFs'
AND time >= $$start_time$$ AND time <= $$end_time$$
and value != ''

UNION ALL

  SELECT
    key_name,
    value_name,
    SUBSTR(remaining_data, 1, INSTR(remaining_data, ' ') - 1),
    SUBSTR(remaining_data, INSTR(remaining_data, ' ') + 1)
  FROM
    SplitLines
  WHERE
    INSTR(remaining_data, ' ') > 0
    
  UNION ALL

  SELECT
    key_name,
    value_name,
    remaining_data AS line,
    NULL AS remaining_data
  FROM
    SplitLines
  WHERE
    INSTR(remaining_data, ' ') = 0
)

SELECT 
key_name,
value_name,
line 
FROM SplitLines
WHERE line NOT LIKE '%\system32\wbem\%'