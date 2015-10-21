Filter Top {

    param (
        [String] $File,
        [int] $N
    )
<#
$QueryTemplate=@"
SELECT  $(if ($N) {"TOP $N"}) [{0}] AS VALUE, COUNT(1) AS RECORDS
FROM    '{1}'
GROUP BY [{0}]
ORDER BY count(1) DESC
"@
#>
$Query = @"
SELECT $(if ($N -and ($N -gt 0)) {"TOP $N"}) [$($_.Name)] AS Value, Count(1) AS Records 
FROM '$File' 
GROUP BY [$($_.Name)] 
ORDER BY count(1) DESC
"@

#    $Query = ($QueryTemplate -f $Field, $File)
#    $Query = "SELECT $(if ($N -and ($N -gt 0)) {"TOP $N"}) [$($_.Name)] AS Value, Count(1) AS Records FROM '$File' GROUP BY [$($_.Name)] ORDER BY count(1) DESC"
#    Write-Host $Query

    # excute query; generate xml
    [xml] $xml = & logparser $Query -stats:off -o:xml

    # process results; assign to container's Value property
    $Measurement=[PsCustomObject]@{'Name'="Top $( if ($N -eq -1) {'All'} else {$N})";Value=$null}
    $Measurement.Value = $xml.root.row | Foreach {
        #Write-Host "Value: $( if ($_.Value.Trim()) {$_.Value.Trim()} else {'<NULL>'} ); Records: $($_.Records.Trim())"
        # subcontainer
        [PSCustomObject]@{
            Value=if ($_.Value.Trim()) {$_.Value.Trim()} else {'<NULL>'}; 
            Records=$_.Records.Trim()
        }
    }
    $_.Sets+=$Measurement
    # return container to pipeline
    # $_

}
