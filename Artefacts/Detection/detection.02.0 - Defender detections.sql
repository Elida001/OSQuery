/*************************** Sophos.com/RapidResponse ***************************\
| DESCRIPTION                                                                    |
| Gets detection events from the Windows Defender/Operational logs, focusing on  |
| Event IDs 1006, 1007, 1008, 1009, 1010, 1011, 1116, 1117, and 1118.            |
|                                                                                |
| Query Type: Endpoint                                                           |
| Version: 1.0                                                                   |
| Author: The Rapid Response Team                                                |
| github.com/SophosRapidResponse                                                 |
\********************************************************************************/

SELECT
strftime('%Y-%m-%dT%H:%M:%SZ',datetime) AS date_time,
source,
eventid,
JSON_EXTRACT(data, '$.EventData.Category Name') AS category,
JSON_EXTRACT(data, '$.EventData.Threat Name') AS threat_name,
JSON_EXTRACT(data, '$.EventData.Path') AS path,
data as raw_data,
'EVTX' source_data,
'detection.02.0' AS query
FROM sophos_windows_events 
WHERE source = 'Microsoft-Windows-Windows Defender/Operational' 
AND eventid in ('1006', '1007', '1008', '1009', '1010', '1011' , '1116' , '1117' , '1118')
AND time > 0
ORDER BY time DESC