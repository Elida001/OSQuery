/*************************** Sophos.com/RapidResponse ***************************\
| DESCRIPTION                                                                    |
| The query search for malicious use of bitsadmin.exe by looking at the command  |
| line parameter associated with a BITS job. The query also detects powershell   |
| cmdlet used to start a bits job                                                |
|                                                                                |
| VARIABLES                                                                      |
| begin(date) = datetime of when to start the hunt                               |
| end(date) = datetime of when to end the hunt                                   |
|                                                                                |
|                                                                                |
| Author: The Rapid Response Team                                                |
| github.com/SophosRapidResponse                                                 |
\********************************************************************************/

SELECT 
 strftime('%Y-%m-%dT%H:%M:%SZ',datetime(spj.process_start_time,'unixepoch')) AS datetime,
 spj.path AS path, 
 spj.cmd_line AS cmd_line,
 spj.sophos_pid AS sophos_PID, 
 CAST (spj.process_name AS TEXT) process_name,
 strftime('%Y-%m-%dT%H:%M:%SZ',datetime(spj.process_start_time,'unixepoch')) AS process_start_time, 
 CASE WHEN spj.end_time = 0 THEN '' ELSE strftime('%Y-%m-%dT%H:%M:%SZ',datetime(spj.end_time,'unixepoch')) END AS process_end_time, 
 CAST ( (Select u.username from users u where spj.sid = u.uuid) AS text) username,
 spj.sid AS sid,
 spj.sha256 AS sha256,
 spj.file_size AS file_size, 
 CAST ( (Select strftime('%Y-%m-%dT%H:%M:%SZ',datetime(f.btime,'unixepoch')) from file f where f.path = spj.path) AS text) First_Created_On_Disk,
 CAST ( (Select strftime('%Y-%m-%dT%H:%M:%SZ',datetime(f.ctime,'unixepoch')) from file f where f.path = spj.path) AS text) Last_Changed,
 CAST ( (Select strftime('%Y-%m-%dT%H:%M:%SZ',datetime(f.mtime,'unixepoch')) from file f where f.path = spj.path) AS text) Last_Modified,
 CAST ( (Select strftime('%Y-%m-%dT%H:%M:%SZ',datetime(f.atime,'unixepoch')) from file f where f.path = spj.path) AS text) Last_Accessed,
 spj.parent_sophos_pid AS sophos_parent_PID, 
 CAST ( (Select spj2.path from sophos_process_journal spj2 where spj2.sophos_pid = spj.parent_sophos_pid) AS text) parent_path, 
 CAST ( (Select spj2.process_name from sophos_process_journal spj2 where spj2.sophospid = spj.parent_sophos_pid) AS text) parent_process,
 CAST ( (Select spj2.cmd_line from sophos_process_journal spj2 where spj2.sophospid = spj.parent_sophos_pid) AS text) parent_cmd_line,
 'Medium' As Potential_FP_chance,
 'Detected a commandline associated with the creation/transfer of a BITS job' As Description,
 'Process Journal/File/Users' AS Data_Source,
 'T1197 - BITS Jobs' AS Query 
FROM sophos_process_journal spj 
WHERE (process_name = 'bitsadmin.exe' OR process_name = 'powershell.exe')
AND (cmd_line like '%Transfer%' 
    OR cmd_line like '%Create%' 
    OR cmd_line like '%AddFile%' 
    OR cmd_line like '%SetNotifyCmdLine%' 
    OR cmd_line like '%SetMinRetryDelay%' 
    OR cmd_line like '%Resume%'
    OR cmd_line like '%Start-BitsTransfer%')
AND spj.time > $$begin$$ 
AND spj.time < $$end$$