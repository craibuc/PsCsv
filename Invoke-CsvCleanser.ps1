function Invoke-CsvCleanser {

    [CmdletBinding()]
    Param
    (
        [Parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName = $true)][Alias('FullName','Path')]
        <#
        [ValidateScript({
            if(!(Test-Path -LiteralPath $_ -PathType Container))
            {
                throw "Input folder doesn't exist: $_"
            }
            $true
        })]
        #>
        [ValidateNotNullOrEmpty()]
        [string[]]$Files, # = (Get-Location -PSProvider FileSystem).Path,

        <#
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateScript({
            if(!(Test-Path -LiteralPath $_ -PathType Container))
            {
                try
                {
                    New-Item -ItemType Directory -Path $_ -Force
                }
                catch
                {
                    throw "Can't create output folder: $_"
                }
            }
            $true
        })]
        [ValidateNotNullOrEmpty()]
        [string]$OutPath,
        #>

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]$Encoding = 'Default',

        [switch]$Nulls,

        [switch]$Milliseconds,

        [switch]$DoubleQuotes
    )

    BEGIN {
        Write-Verbose "$($MyInvocation.MyCommand.Name)::Begin"

        # Set default encoding
        if($Encoding -eq 'Default') {
            $FileEncoding = [System.Text.Encoding]::Default
        }
        # Try to set user-specified encoding
        else {
            try {
                $FileEncoding = [System.Text.Encoding]::GetEncoding($Encoding)
            }
            catch {
                throw "Not valid encoding: $Encoding"
            }
        }

        Write-Verbose "Encoding: $FileEncoding"
        Write-Verbose "Nulls: $Nulls"
        Write-Verbose "Milliseconds: $Milliseconds"
        Write-Verbose "DoubleQuotes: $DoubleQuotes"

        $DQuotes = '"'
        $Separator = ','
        # http://stackoverflow.com/questions/15927291/how-to-split-a-string-by-comma-ignoring-comma-in-double-quotes
        $SplitRegex = "$Separator(?=(?:[^$DQuotes]|$DQuotes[^$DQuotes]*$DQuotes)*$)"
        # Regef to match NULL
        $NullRegex = '^NULL$'
        # Regex to match milliseconds: 23:00:00.000
        $MillisecondsRegex = '(\d{2}:\d{2}:\d{2})(\.\d{3})'

    } # BEGIN

  PROCESS {
        Write-Verbose "$($MyInvocation.MyCommand.Name)::Process"

        Foreach ($File In $Files) {

            $InFile = New-Object -TypeName System.IO.StreamReader -ArgumentList (
                #$_.FullName,
                $File,
                $FileEncoding
            ) -ErrorAction Stop

            Write-Verbose 'Created INPUT StreamReader'

            $tempFile = "$env:temp\TEMP-$(Get-Date -format 'yyyy-MM-dd hh-mm-ss').csv"
            # $tempFile = (Join-Path -Path $OutPath -ChildPath $_.Name)

            $OutFile = New-Object -TypeName System.IO.StreamWriter -ArgumentList (
                $tempFile,
                $false,
                $FileEncoding
            ) -ErrorAction Stop

            Write-Verbose 'Created OUTPUT StreamWriter'

            Write-Verbose "Processing $File..."

            while(($line = $InFile.ReadLine()) -ne $null) {

                Write-Debug "Raw: $line"

                $tmp = $line -split $SplitRegex | ForEach-Object {

                    # Strip surrounding quotes
                    if($DoubleQuotes) { $_ = $_.Trim($DQuotes) }

                    # Strip NULL strings
                    if($Nulls) { $_ = $_ -replace $NullRegex, '' }

                    # Strip milliseconds
                    if($Milliseconds) { $_ = $_ -replace $MillisecondsRegex, '$1' }

                    # Output current object to pipeline
                    $_

                } # Foreach

                Write-Debug "Clean: $($tmp -join $Separator)"

                # Write line to the new CSV file
                $OutFile.WriteLine($tmp -join $Separator)

            } # While

            Write-Verbose "Finished processing file: $($_.FullName)"
            # Write-Verbose "Processed file is saved as: $($OutFile.BaseStream.Name)"

            # Close open files and cleanup objects
            $OutFile.Flush()
            $OutFile.Close()
            $OutFile.Dispose()
            
            $InFile.Close()
            $InFile.Dispose()

            # move and replace
            Move-Item $tempFile $File -Force

        } # Foreach

    } # PROCESS

    END { Write-Verbose "$($MyInvocation.MyCommand.Name)::End"}

}