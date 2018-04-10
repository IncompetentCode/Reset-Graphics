# Check if we're running as admin
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{   
    Write-Host "Not running as administrator, re-launching as one..." -F Red
    Start-Sleep -Seconds 2
    $arguments = "& '" + $myinvocation.mycommand.definition + "'"
    Start-Process powershell -Verb runAs -ArgumentList $arguments
    Exit
}

# Variables
$DisplayAdapters = @()
$Selection = 0

# Functions
function Reset-PnpDevice
{
    Param([Parameter(Mandatory=$true)][CimInstance]$Device)

    Disable-PnpDevice -InstanceId $Device.InstanceId -Confirm:$false

    Enable-PnpDevice -InstanceId $Device.InstanceId -Confirm:$false
}

function Prompt-Displays
{
    $global:DisplayAdapters += Get-PnpDevice | Where Class -eq "Display"

    foreach($DisplayAdapter in $global:DisplayAdapters)
    {
        Write-Host "[$($global:DisplayAdapters.IndexOf($DisplayAdapter) + 1)]" -NoNewline
        Write-Host " $($DisplayAdapter.FriendlyName)" -F Yellow
    }

    while ( ($global:Selection -lt 1) -or ($global:Selection -gt $global:DisplayAdapters.Length) )
    {
        $global:Selection = Read-Host -Prompt "Select display device"
    }
}

# Start
Write-Warning "This script may cause you to lose your display."

Prompt-Displays

Reset-PnpDevice -Device $global:DisplayAdapters[$global:Selection - 1]

