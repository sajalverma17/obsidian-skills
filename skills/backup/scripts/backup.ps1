<#
.SYNOPSIS
    Backs up a folder using robocopy, excluding hidden folders.

.PARAMETER SourceDirectory
    Path to the folder to back up.

.PARAMETER BackupDirectory
    Path where the backup folder will be created.

.EXAMPLE
    .\backup-vault.ps1 -SourceDirectory "U:\Drive\D\Vault" -BackupDirectory "G:\D\VaultBackups"
#>

param(
    [Parameter(Mandatory)][string]$SourceDirectory,
    [Parameter(Mandatory)][string]$BackupDirectory
)

$SourceDirectory = $SourceDirectory.TrimEnd('\', '/')
$BackupDirectory = $BackupDirectory.TrimEnd('\', '/')
$Date = Get-Date -Format "yyyy-MM-dd"
$BackupFolderName = "Backup-$Date"
$Destination = Join-Path $BackupDirectory $BackupFolderName
$LogFile = Join-Path $BackupDirectory "$BackupFolderName-robocopy.log"

Write-Host "Source      : $SourceDirectory"
Write-Host "Destination : $Destination"
Write-Host "Log         : $LogFile"
Write-Host ""

if (-not (Test-Path $SourceDirectory)) {
    Write-Error "Source path not found: $SourceDirectory"
    exit 1
}

# Collect hidden directories (names starting with '.') to exclude
$ExcludeDirs = Get-ChildItem -Path $SourceDirectory -Directory |
    Where-Object { $_.Name -like ".*" } |
    ForEach-Object { $_.FullName }

$RobocopyArgs = @(
    $SourceDirectory,
    $Destination,
    "/E",       # Copy all subdirectories, including empty ones
    "/R:3",     # Retry 3 times on failure
    "/W:5",     # Wait 5 seconds between retries
    "/NP",      # No progress percentage in output
    "/TEE",     # Output to console and log file
    "/LOG+:$LogFile"
)

if ($ExcludeDirs.Count -gt 0) {
    Write-Host "Excluding hidden folders:"
    $ExcludeDirs | ForEach-Object { Write-Host "  $_" }
    Write-Host ""
    $RobocopyArgs += "/XD"
    $RobocopyArgs += $ExcludeDirs
}

robocopy @RobocopyArgs

# Robocopy exit codes: 0-7 are success/informational, 8+ indicate errors
$ExitCode = $LASTEXITCODE
if ($ExitCode -le 7) {
    Write-Host ""
    Write-Host "Backup completed successfully. (robocopy exit code: $ExitCode)"
} else {
    Write-Host ""
    Write-Error "Backup encountered errors. (robocopy exit code: $ExitCode) Check log: $LogFile"
    exit $ExitCode
}
