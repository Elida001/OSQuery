/**************************** Sophos.com/RapidResponse ****************************\
| DESCRIPTION                                                                      |
| Lists connection and data transfer information about an IP address or a specific |
| process from a SophosPID.                                                        |
|                                                                                  |
| VARIABLES                                                                        |
| start_time(date) = datetime of when to start hunting                             |
| end_time(date) = datetime of when to stop hunting                                |
| SophosPID(SophosPID) = SophosPID of the process                                  |
| ip_address (IP Address) = The IP address to query                                |
|                                                                                  |
| Author: Sophos MDR | Elida Leite                                                 |
| github.com/SophosRapidResponse                                                   |
\**********************************************************************************/


SELECT
    STRFTIME('%Y-%m-%dT%H:%M:%SZ', DATETIME(network_journal.time, 'unixepoch')) AS date_time,
    users.username,
    CAST(process_journal.sid AS TEXT) AS sid,
    CAST(process_journal.process_name AS TEXT) AS process_name,
    CAST(process_journal.cmd_line AS TEXT) AS cmd_line,
    network_journal.sophos_pid,
    network_journal.source,
    network_journal.source_port,
    network_journal.destination,
    network_journal.destination_port,
    SUM(network_journal.data_sent) AS total_data_sent,
    SUM(network_journal.data_recv) AS total_data_recv
FROM sophos_network_journal AS network_journal
LEFT JOIN sophos_process_journal AS process_journal
    USING (sophos_pid)
LEFT JOIN users
    ON process_journal.sid = users.uuid
WHERE    
    network_journal.sophos_pid LIKE '$$sophos_pid$$'
    AND ( 
        network_journal.source LIKE '$$ip_address$$'
        OR
        network_journal.destination LIKE '$$ip_address$$'
    )
    AND network_journal.time >= $$start_time$$
    AND network_journal.time <= $$end_time$$
GROUP BY
    network_journal.sophos_pid,
    network_journal.source,
    network_journal.source_port,
    network_journal.destination,
    network_journal.destination_port
