<#
.SYNOPSIS
Removes selected columns from a CSV file.

.PARAMETER Path
The CSV file to be processed.

.PARAMETER Excluded
Array of columns to be removed from the CSV file.

.PARAMETER PassThru
Return a FileSystemInfo object that represents the Cmdlet's results; default: $false.

.EXAMPLE
PS> Remove-CsvColumns -p path\to\file.csv -e 'COLUMN_0','COLUMN_1'

#>
function Remove-CsvColumns {

    [CmdletBinding()]
    Param
    (
        # [Parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName = $true)]
        # [Alias('FullName','f')]
        # [ValidateNotNullOrEmpty()]
        # [string[]]$Files,
        [Parameter(Mandatory=$True,Position=1)]
        [alias('p')]
        [String] $Path,

        [Parameter(Mandatory=$False,Position=2)]
        [alias('e')]
        [String[]] $Excluded,

        # [Parameter(ValueFromPipelineByPropertyName = $true)]
        # [Alias('e')]
        # [string]$Encoding = 'Default'

        [switch]$PassThru

    )

    BEGIN {
        Write-Debug "$($MyInvocation.MyCommand.Name)::Begin"

        # get list of fields from file if none are specified
        $Included = Get-CsvColumns -Path $Path

        # remove excluded fields
        $Included = $Included | Where-Object { $Excluded -NotContains $_ }

$QueryTemplate=@"
SELECT  $( $Included -Join ',')
INTO    '{1}'
FROM    '{0}'
"@
        Write-Debug $QueryTemplate

        # # Set default encoding
        # if($Encoding -eq 'Default') {
        #     $FileEncoding = [System.Text.Encoding]::Default
        # }
        # # Try to set user-specified encoding
        # else {
        #     try {
        #         $FileEncoding = [System.Text.Encoding]::GetEncoding($Encoding)
        #     }
        #     catch {
        #         throw "Not valid encoding: $Encoding"
        #     }
        # }

        # Write-Debug "Encoding: $FileEncoding"

    }

    PROCESS {
        Write-Debug "$($MyInvocation.MyCommand.Name)::Process"

        $Query = ($QueryTemplate -f $Path, $Path)
        Write-Verbose $Query

        & logparser $Query -stats:off -o:csv

        # return a reference to the ADoc that was created
        If ($PassThru) { Write-Output (Get-Item $File) }

    } # PROCESS

    END { Write-Debug "$($MyInvocation.MyCommand.Name)::End" }

}

Set-Alias rcc Remove-CsvColumns
