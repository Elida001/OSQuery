/*************************** Sophos.com/RapidResponse ***************************\
| DESCRIPTION                                                                    |
| Looks for autodiscover.json abuse and the presence of web shells.              |
|                                                                                |
| NOTE                                                                           |
| A common artifact seen in these logs for abuse of CVE-2021-34473 is the        |
| presence of &Email=autodiscover/autodiscover.json in the request path to       |
| confuse the Exchange proxy to erroneously strip the wrong part from the URL.   |
|                                                                                |
| E.g. GET /autodiscover/autodiscover.json @evilcorp/ews/exchange.asmx?&Email=   |
| autodiscover/autodiscover.json%3F@evil.corp                                    |
|                                                                                |
| The below XDR query for live Windows devices will query the IIS logs on disk   |
| for any lines that contain the string ‘autodiscover.json’.                     |
|                                                                                |
| Should you later identify web shells, this same query can be repurposed to     |
| query for the web shell file name to reveal requests made to the web           |
| shell – simply change ‘autodiscover.json’ to ‘webshell_name.aspx’. Please note |
| that this query can be slow depending on the volume of logs it needs to parse. |
|                                                                                |
| MORE INFO                                                                      |
| shorturl.at/dnrCS - ProxyShell vulnerabilities in Microsoft Exchange           |
|                                                                                |
| Version: 1.0                                                                   |
| Author: @AltShiftPrtScn & Sophos MTR                                           |
| github.com/SophosRapidResponse                                                 |
\********************************************************************************/

SELECT grep.*
FROM file
CROSS JOIN grep ON (grep.path = file.path)
WHERE
file.path LIKE 'C:\inetpub\logs\LogFiles\W3SVC%\u_ex%'
AND grep.pattern = 'autodiscover.json'