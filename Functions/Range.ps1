<#
.SYNOPSIS
Calculate the minimum and maximum value of the specified fields.

.PARAMETER Path
The CSV file to be processed.

.PARAMETER Fields
Array of fields to be processed.

.EXAMPLE
PS> Range -p path\to\file.csv -f 'FIELD_0','FIELD_1'

.RETURNS
PSCustomObject

#>
Function Range {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True,Position=1)]
        [alias('p')]
        [String] $Path,

        [Parameter(Mandatory=$True,Position=2)]
        [alias('f')]
        [String[]] $Fields
    )

    BEGIN {
$QueryTemplate=@"
    SELECT  Min({0}) AS MINIMUM, Max({0}) AS MAXIMUM
    FROM    {1}
"@

#    WHERE   {0} <> 'NULL'

        Write-Debug $querytemplate

    }
    PROCESS {

        Foreach ($Field in $Fields) {
          Write-Verbose $Field

            $Query = ($QueryTemplate -f $Field, $Path)
            Write-Debug $Query

            # create standard container
            $Container = [PSCustomObject]@{Field=$Field;Computation='Range';Values=$null}

            [xml] $xml = & logparser $Query -stats:off -o:xml

            # process results; assign to container's Value property
            $Container.values = $xml.root.row | Foreach {
                Write-Verbose "Minimum: $($_.Minimum.Trim()); Maximum: $($_.Maximum.Trim())"
                [PSCustomObject]@{
                    Minimum=$_.Minimum.Trim(); 
                    Maximum=$_.Maximum.Trim()
                }
            }

            # return container to pipeline
            $Container

        } #Foreach

    } # PROCESS
    END {}

}
