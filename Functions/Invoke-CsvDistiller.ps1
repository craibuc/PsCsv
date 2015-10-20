<#
.SYNOPSIS
Condenses a CSV into its unique combination of records.

.PARAMETER Path
The CSV file to be processed.

.PARAMETER Included
Array of fields to be included in the results.  All fields are include if this field is null

.PARAMETER Excluded
Array of fields to be excluded from the results.

.EXAMPLE
PS> Invoke-CsvDistiller -p path\to\file.csv -f 'FIELD_0','FIELD_1'

.RETURNS
PSCustomObject

#>
Function Invoke-CsvDistiller {

    param (
        [Parameter(Mandatory=$True,Position=1)]
        [alias('p')]
        [String] $Path,

        [Parameter(Mandatory=$False,Position=2)]
        [alias('i')]
        [String[]] $Included,

        [Parameter(Mandatory=$False,Position=3)]
        [alias('e')]
        [String[]] $Excluded

    )

    BEGIN {

        # get list of fields from file if none are specified
        if ( -not $Included ) { $Included = Get-CsvColumns -Path $Path }

        # remove excluded fields
        $Included = $Included | Where-Object { $Excluded -NotContains $_ }

$QueryTemplate=@"
SELECT  $( $Included -Join ','), Count(1) AS RECORDS
FROM    {0}
GROUP BY $( $Included -Join ',')
ORDER BY count(1) DESC
"@
        Write-Debug $QueryTemplate

    }
    PROCESS {

        $Query = ($QueryTemplate -f $Path)
        Write-Verbose $Query

        $csv = & logparser $Query -stats:off -o:csv
        $csv

    } # PROCESS
    END {}

}

Set-Alias icd Invoke-CsvDistiller
