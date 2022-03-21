# TMG-backup
TMG (Microsoft Forefront Threat Management Gateway) backup.


## Features

- backup
- compress
- copy to SMB share
- Send e-mail with attached backup

Add to Windows sheduler:

```
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
-file "D:\tmg_backup\tmg_backup.ps1"
```