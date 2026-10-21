$ErrorActionPreference = 'Stop'

$deployPath = 'C:\deploy'
$markerFile = Join-Path $deployPath 'ntlm V1.txt'
$backupFile = Join-Path $deployPath 'NTLMv1SSO-backup.reg'
$registryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0'
$registryNativePath = 'HKLM\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0'
$backupSource = 'HKLM\SYSTEM\CurrentControlSet\Control\Lsa'

# Skip if the configuration has already been applied.
if (Test-Path -LiteralPath $markerFile) {
    exit 0
}

try {
    if (-not (Test-Path -LiteralPath $deployPath)) {
        New-Item -Path $deployPath -ItemType Directory -Force | Out-Null
    }

    # Back up the existing registry; preserve an existing backup.
    if (-not (Test-Path -LiteralPath $backupFile)) {
        if (Test-Path -LiteralPath $registryPath) {
            $backupSource = $registryNativePath
        }
        & reg.exe export $backupSource $backupFile /y | Out-Null
        if ($LASTEXITCODE -ne 0) {
            throw 'Registry Backup Failed '
        }
    }

    # Create the registry key if it does not exist.
    if (-not (Test-Path -LiteralPath $registryPath)) {
        New-Item -Path $registryPath -ItemType Directory | Out-Null
    }

    # Add or set only BlockNtlmv1SSO; preserve all other registry values.
    New-ItemProperty `
        -Path $registryPath `
        -Name 'BlockNtlmv1SSO' `
        -PropertyType DWord `
        -Value 0 `
        -Force | Out-Null

    # Create the marker file last to confirm the registry change completed.
    Set-Content -LiteralPath $markerFile -Value 'NTLMv1 registry setting applied.' -Encoding UTF8
    exit 0
}
catch {
    exit 1
}
