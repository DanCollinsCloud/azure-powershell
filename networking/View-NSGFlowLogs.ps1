[CmdletBinding()]
param (
    [Parameter()]
    [String]
    $Path
)
$output = @()
if ((Test-path $path) -eq $false -or ($path.EndsWith(".JSON")) -eq "False") { write-host " Error: File does not exist or not JSON format...." -ForegroundColor Red }else { 

    $logs = (Get-Content $path | ConvertFrom-Json -Depth 30)

    foreach($log in $logs.records.properties.flows){
        foreach($record in $log.flows.flowtuples){
            $a = $record -split ','
            $data = New-Object -TypeName PSObject
            $data | Add-Member -MemberType NoteProperty -Name Source -Value $a[1]
            $data | Add-Member -MemberType NoteProperty -Name Destination -Value $a[2]
            $data | Add-Member -MemberType NoteProperty -Name SourcePort -Value $a[3]
            $data | Add-Member -MemberType NoteProperty -Name DestinationPort -Value $a[4]
            $data | Add-Member -MemberType NoteProperty -Name Protocol -Value $a[5]
            $data | Add-Member -MemberType NoteProperty -Name Direction -Value $a[6]
            $data | Add-Member -MemberType NoteProperty -Name Decision -Value $a[7]
            $data | Add-Member -MemberType NoteProperty -Name Rule -Value $log.rule
            
            $output += $data
        }
    }
}

return $output
#test
