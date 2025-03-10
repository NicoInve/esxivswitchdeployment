# Import VMware PowerCLI module
if (-not (Get-Module -ListAvailable -Name VMware.PowerCLI)) {
    Install-Module -Name VMware.PowerCLI -Scope CurrentUser -Force
}
Import-Module VMware.PowerCLI

# Disable confirmation prompts for invalid certificates
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false

# Get script directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# CSV file paths
$hostsCsvPath = "$scriptDir\hosts.csv"
$vswitchCsvPath = "$scriptDir\vswitches.csv"

# Verify that the files exist
if (-Not (Test-Path $vswitchCsvPath)) {
    Write-Host "ERROR: The file vswitches.csv does not exist at $vswitchCsvPath" -ForegroundColor Red
    exit
}

if (-Not (Test-Path $hostsCsvPath)) {
    Write-Host "ERROR: The file hosts.csv does not exist at $hostsCsvPath" -ForegroundColor Red
    exit
}

# Import data from CSV files
$hosts = Import-Csv -Path $hostsCsvPath
$vswitches = Import-Csv -Path $vswitchCsvPath

# Check if hosts are present in the CSV
if ($hosts.Count -eq 0) {
    Write-Host "WARNING: No hosts found in the hosts.csv file. Exiting..." -ForegroundColor Yellow
    exit
}

# Display the found hosts
Write-Host "Found hosts:"
$hosts | ForEach-Object { Write-Host $_.ESXiHost }

# Prompt for ESXi credentials
$cred = Get-Credential -Message "Enter credentials for ESXi hosts"

# Iterate over ESXi hosts
foreach ($esxi in $hosts) {
    $esxiHost = $esxi.ESXiHost.Trim()

    if ([string]::IsNullOrEmpty($esxiHost)) {
        Write-Host "WARNING: Empty host, skipping..." -ForegroundColor Yellow
        continue
    }

    Write-Host "Connecting to $esxiHost..."
    $esxiConnection = Connect-VIServer -Server $esxiHost -Credential $cred -ErrorAction SilentlyContinue

    if ($esxiConnection) {
        foreach ($vs in $vswitches) {
            $vswitchName = $vs.VSwitch
            $mtu = $vs.MTU
            $nicList = $vs.NICs -split ","

            # Check if the vSwitch already exists
            $existingVSwitch = Get-VMHost -Name $esxiHost | Get-VirtualSwitch | Where-Object { $_.Name -eq $vswitchName }

            if ($existingVSwitch) {
                Write-Host "WARNING: vSwitch '$vswitchName' already exists on $esxiHost, skipping..." -ForegroundColor Yellow
                continue
            }

            # Create vSwitch
            Write-Host "Creating vSwitch '$vswitchName' with MTU $mtu on $esxiHost..."
            $newVSwitch = New-VirtualSwitch -VMHost $esxiHost -Name $vswitchName -Mtu $mtu -Nic $nicList -ErrorAction SilentlyContinue
            
            if ($newVSwitch) {
                Write-Host "SUCCESS: vSwitch '$vswitchName' created on $esxiHost!" -ForegroundColor Green
            } else {
                Write-Host "ERROR: Failed to create vSwitch '$vswitchName' on $esxiHost." -ForegroundColor Red
            }
        }

        # Disconnect from host
        Disconnect-VIServer -Server $esxiHost -Confirm:$false -Force
    } else {
        Write-Host "ERROR: Failed to connect to $esxiHost, skipping..." -ForegroundColor Red
    }
}

# Final message
Write-Host "Operation completed successfully!" -ForegroundColor Green

