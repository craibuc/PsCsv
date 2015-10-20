function Remove-CsvColumns {

    [CmdletBinding()]
    Param
    (
        [Parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName = $true)]
        [Alias('FullName','f')]
        [ValidateNotNullOrEmpty()]
        [string[]]$Files,

        #[Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('c')]
        [string[]]$Columns

        # [Parameter(ValueFromPipelineByPropertyName = $true)]
        # [Alias('e')]
        # [string]$Encoding = 'Default'

    )

    BEGIN {
        Write-Verbose "$($MyInvocation.MyCommand.Name)::Begin"

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
      Write-Verbose "$($MyInvocation.MyCommand.Name)::Process"

      Foreach ($File In $Files) {

        [DateTime] $started = Get-Date

        $Item = (Get-Item $File)

        $tempFile = "$env:temp\TEMP-$(Get-Date -format 'yyyy-MM-dd hh-mm-ss').csv"

        $OutFile = New-Object -TypeName System.IO.StreamWriter -ArgumentList (
            $tempFile,
            $false,
            $FileEncoding
        ) -ErrorAction Stop

        # progress indicator
        #$Activity = "Processing $Item..."
        #$Length = $Item.Length

        # export
        Import-Csv $File | SELECT * -ExcludeProperty ($Columns -Join ',') | `
          Convertto-Csv -notypeinformation
        # Export-csv $tempFile -NoTypeInformation

        # move and replace
        Move-Item $tempFile $Item.FullName -Force

        # [DateTime] $ended = Get-Date

        $item.Length
        [TimeSpan] $duration = (Get-Date) - $started

        Write-Host ("Processed {0} ({1:N0} bytes) in {2}" -f $Item, $Item.Length, $duration)

        # Close open files and cleanup objects
        $OutFile.Flush()
        $OutFile.Close()
        $OutFile.Dispose()

      } # Foreach

    } # PROCESS

    END { Write-Verbose "$($MyInvocation.MyCommand.Name)::End"}

}

Set-Alias rcc Remove-CsvColumns
