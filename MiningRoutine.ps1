[CmdletBinding()]
param (
    [Parameter(Mandatory)][string]$processName,
    [Parameter(Mandatory)][string]$ScheduleJson,
    [Parameter(Mandatory)][string]$executablePath,
    [Parameter(Mandatory)][string]$executableArgs
)

# Void period
$ElectricitySchedule = Get-Content $ScheduleJson | ConvertFrom-Json

# Function that checks if a process is running. If it is returns the info about the process, if not it doesn't return anything
function CheckProcess {
    [CmdletBinding()]
    param (
        $processName
    )
    $process = get-process -Name $processName -ErrorAction SilentlyContinue
    $parentProcessID = ( Get-CimInstance win32_process | Where-Object processid -eq  $process.Id).parentprocessid
    return $parentProcessID, $process.Id
}

# Function that stops a process based on a process and reports back informing the process was terminated
function StopProcess {
    [CmdletBinding()]
    param (
        $processId
    )
    Stop-Process -Id $processId -Force
    Write-Host "Job terminated!"
}

# Function that puts the computer to sleep
function SleepingBeauty {
    # load assembly System.Windows.Forms which will be used
    Add-Type -AssemblyName System.Windows.Forms
    # so you can wake up your computer from sleep
    $DisableWake = $false;
    # set powerstate to suspend (sleep mode)
    $PowerState = [System.Windows.Forms.PowerState]::Suspend;
    # do not force putting Windows to sleep
    $Force = $false;
    # do it! Set computer to sleep
    [System.Windows.Forms.Application]::SetSuspendState($PowerState, $Force, $DisableWake);
}

# Assigns the day object to a variable
$Monday = $ElectricitySchedule.Monday
$Tuesday = $ElectricitySchedule.Tuesday
$Wednesday = $ElectricitySchedule.Wednesday
$Thursday = $ElectricitySchedule.Thursday
$Friday = $ElectricitySchedule.Friday
$Saturday = $ElectricitySchedule.Saturday
$Sunday = $ElectricitySchedule.Sunday

# Gets the current date for the timer
$EndTime = Get-Date

while ($true) {

    # Check day of the week
    $dayOfWeek = $(get-date).DayOfWeek
    
    # Assigns the day interval to a variable
    switch ($dayOfWeek) {
        "Monday" { $Intervals = $Monday }
        "Tuesday" { $Intervals = $Tuesday }
        "Wednesday" { $Intervals = $Wednesday }
        "Thursday" { $Intervals = $Thursday }
        "Friday" { $Intervals = $Friday }
        "Saturday" { $Intervals = $Saturday }
        "Sunday" { $Intervals = $Sunday }
    }

    # Check current interval
    $members = $intervals | Get-Member -MemberType NoteProperty

    # Assigns the minimum and maximum values of each interval to a separate array
    $minTimes = @()
    $maxTimes = @()
    foreach ($member in $members) {
        $minTimes += $([datetime]::parseexact($($($Intervals.($member.Name)[0]).ToString()), "HH:mm", $null)).TimeOfDay.TotalMinutes
        $maxTimes += $([datetime]::parseexact($($($Intervals.($member.Name)[1]).ToString()), "HH:mm", $null)).TimeOfDay.TotalMinutes
    }

    $startMining = 0
    For ($i = 0; $i -lt $minTimes.Length; $i++) {

        if ([int]((get-date).TimeOfDay.TotalMinutes) -in $minTimes[$i]..$maxTimes[$i]) {
            $startMining = 1
        }
    }

    if ($startMining -eq 1 ) {
        # Check process is running
        $checkProcessRunning = CheckProcess -processName $processName
        if (!$checkProcessRunning[1]) {
            # Start mining job  
            Start-Process -FilePath $executablePath -ArgumentList $executableArgs
        }
        else {
            Write-Host "$processName is running!"
        }
    }
    if ($startMining -eq 0 ) {
        # Check process is running
        $checkProcessRunning = CheckProcess -processName $processName
        # Kill mining job
        if ($checkProcessRunning[1]) {
            StopProcess -processId $checkProcessRunning[1]
            Start-Sleep -Seconds 300
            Start-Job -ScriptBlock ${Function:SleepingBeauty}
        }
    }

    # Runs the while loop every 5 minutes to decrease CPU consumption
    $EndTime = $(get-date).AddMinutes(5)
    Write-Host "Running in the background..."
    Start-Sleep -Seconds $(New-TimeSpan -End $EndTime).TotalSeconds
}