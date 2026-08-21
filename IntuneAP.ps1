<#
.SYNOPSIS
    Collects hardware hash and registers device to Windows Autopilot via Microsoft Graph
    using app-only (client credentials) authentication — no interactive sign-in.
.NOTES
    Run as Administrator.
#>

param(
    [Parameter(Mandatory = $true, HelpMessage = "Company short code, e.g. TAG")]
    [string]$GroupTag,

    [Parameter(Mandatory = $false)]
    [string]$AssignedUser
)

# --- App registration details ---
# TESTING ONLY: hardcoding here for convenience. Move these to a secure
# vault / secret store before using this outside of testing.
$TenantId     = "8f10db80-e89f-460b-9a09-6b7d950d938c"
$AppId        = "ed860dce-1971-4103-a6d7-014e23027533"
$AppSecret    = "X278Q~vtsqAbyCZfgyv.HAeTdMW8.F2yskpKddaB"

# 1. Ensure required components are present
if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
    Install-PackageProvider -Name NuGet -Force -Scope CurrentUser | Out-Null
}

if (-not (Get-InstalledScript -Name Get-WindowsAutoPilotInfo -ErrorAction SilentlyContinue)) {
    Install-Script -Name Get-WindowsAutoPilotInfo -Force -Scope CurrentUser
}

# 2. Build parameters
$params = @{
    Online   = $true
    GroupTag = $GroupTag
    TenantId = $TenantId
    AppId    = $AppId
    AppSecret = $AppSecret
}

if ($AssignedUser) {
    $params.Add("AssignedUser", $AssignedUser)
}

# 3. Run the collection + upload
Write-Host "Collecting hardware hash and uploading to Intune Autopilot (app-only auth), Group Tag '$GroupTag'..." -ForegroundColor Cyan

$scriptPath = Get-InstalledScript -Name Get-WindowsAutoPilotInfo | Select-Object -ExpandProperty InstalledLocation
& "$scriptPath\Get-WindowsAutoPilotInfo.ps1" @params

Write-Host "Done" -ForegroundColor Green