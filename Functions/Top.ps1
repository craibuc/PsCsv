<#
.SYNOPSIS
Calculate the unique value of the specified fields.

.PARAMETER Path
The CSV file to be processed.

.PARAMETER Fields
Array of fields to be processed.

.EXAMPLE
PS> Unique -p path\to\file.csv -f 'FIELD_0','FIELD_1'

.RETURNS
PSCustomObject

#>
Function Unique {

    param (
        [Parameter(Mandatory=$True,Position=1)]
        [alias('p')]
        [String] $Path,

        [Parameter(Mandatory=$True,Position=2)]
        [alias('f')]
        [String[]] $Fields,

        [Parameter(Mandatory=$False,Position=3)]
        [alias('t')]
        [int] $Top

    )

    BEGIN {
$QueryTemplate=@"
SELECT  $(if ($Top) {"TOP $Top"}) [{0}] AS VALUE, COUNT(1) AS RECORDS
FROM    {1}
GROUP BY [{0}]
ORDER BY count(1) DESC
"@
        Write-Debug $querytemplate

    }
    PROCESS {

        # for each field-array value
        Foreach ($Field in $Fields) {
          Write-Verbose $Field

            $Query = ($QueryTemplate -f $Field, $Path)
            Write-Debug $Query

            # create standard container
            $Container = [PSCustomObject]@{Field=$Field;Computation='Unique';Values=$null}

            # excute query; generate xml
            [xml] $xml = & logparser $Query -stats:off -o:xml

            # process results; assign to container's Value property
            $Container.values = $xml.root.row | Foreach {
                Write-Verbose "Value: $( if ($_.Value.Trim()) {$_.Value.Trim()} else {'<NULL>'} ); Records: $($_.Records.Trim())"
                # subcontainer
                [PSCustomObject]@{
                    Value=if ($_.Value.Trim()) {$_.Value.Trim()} else {'<NULL>'}; 
                    Records=$_.Records.Trim()
                }
            }

            # return container to pipeline
            $Container

        } #Foreach

    } # PROCESS
    END {}

}
