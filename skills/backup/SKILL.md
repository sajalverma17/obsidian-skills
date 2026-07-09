---

name: backup
description: Backup a folder using robocopy to one or more directory locations, excluding hidden folders. Use when the user requests a "backup" or "run a backup" or "back up my vault".

---

This skill backs up a folder using `robocopy`. Hidden folders (starting with `.`) are automatically detected and excluded. A date-stamped backup folder `Backup-YYYY-MM-DD` is created automatically inside each `BackupDirectory`. A robocopy log is written alongside it as `Backup-YYYY-MM-DD-robocopy.log`.

## Execution

Run the script once per row, in sequence, using the default values below. If the user specifies a different source or backup directory, override the defaults accordingly. If a backup directory is not present or its path does not exist, skip it and inform the user.

| `-SourceDirectory` | `-BackupDirectory` |
|---|---|
| U:\D\Vault | G:\D\Vault |
| U:\D\Vault | H:\D\Vault |

```powershell
.\backup.ps1 -SourceDirectory "<SourceDirectory>" -BackupDirectory "<BackupDirectory>"
```

If any backup fails, continue with the remaining backups and report all results at the end.

## Notes
- Hidden folders are discovered on each execution
- Robocopy exit codes 0–7 are treated as success
- `/TEE` flag mirrors output to both terminal and log file