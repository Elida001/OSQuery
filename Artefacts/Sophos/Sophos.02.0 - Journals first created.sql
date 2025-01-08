/*************************** Sophos.com/RapidResponse ***************************\
| DESCRIPTION                                                                    |
<<<<<<< HEAD
| Checks when the Sophos Journals were first created. Use this if you aren't     |
| getting the data you expected.                                                 |
=======
| Checks when the Sophos Journals were first created. This is a useful check if  |
| you aren't arn't getting the data you expected.                                |
>>>>>>> a8093f4ae14831501e8f44f244c80fffaef4dd67
|                                                                                |
| Version: 1.0                                                                   |
| Author: @AltShiftPrtScn                                                        |
| github.com/SophosRapidResponse                                                 |
\********************************************************************************/

SELECT
strftime('%Y-%m-%dT%H:%M:%SZ',datetime(btime,'unixepoch')) AS Journals_Created,
'File' AS Data_Source,
'Sophos.02.0' AS Query
FROM file WHERE directory LIKE 'C:\ProgramData\Sophos\Endpoint Defense\Data\Event Journals\'