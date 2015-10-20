<#
.SYNOPSIS
Produce a statistical analysis of a CSV file.

.DESCRIPTION
TODO

.PARAMETER Source
The CSV file to be processed.

.PARAMETER Destination
The directory to contain the results of the processing.  Default: the current directory ('.').

.PARAMETER Delimiter
The CSV file's delimiter; default: "," (comma)

.PARAMETER PassThru
Return a FileSystemInfo object that represents the Cmdlet's results; default: $false.

.EXAMPLE
Invoke-CsvAnalyzer C:\Users\<user>\export.csv

#>
function Invoke-CsvAnalyzer {

    [CmdletBinding()]
    PARAM(
        [Parameter(Mandatory=$True,Position=1)]
        [Alias('s')]
        [String[]] $Source,

        [Parameter(Mandatory=$False,Position=2)]
        [Alias('d')]
        [String] $Destination='.',

        [Parameter(Mandatory=$False)]
        [String] $Delimiter=",",

        [Switch] $PassThru
    )

    BEGIN {
      # Write-Verbose "Path: $Source"

      $DocumentTemplate=@"
= {0}
:description: data analysis
:author: {1}
:revdate: {2}
:icons: font
:toc:
:toclevels: 3
:toc-placement: left
:source-highlighter: coderay
:data-uri:
:experimental:

== Fields
"@

      $IncludeTemplate=@"
[format="csv",options="header"]
|===================================================
include::{0}[]
|===================================================

"@

      $QueryTemplate=@"
SELECT  [{0}] AS VALUE, COUNT(1) AS RECORDS
INTO    '{1}'
FROM    {2}
GROUP BY [{0}]
ORDER BY count(1) DESC
"@

    }
    PROCESS {

        $SourceItem = Get-Item $Source
        Write-Verbose "Source: $SourceItem"

        # create destination directory if !exists
        if (!(Test-Path $Destination)) {
           New-Item -ErrorAction Ignore -ItemType Directory -Path $Destination
        }
        $DestinationItem = Get-Item $Destination
        Write-Debug "Destination: $DestinationItem"

        $SourcePath = $SourceItem.Directory.Name #Split-Path $Source -Resolve
        Write-Debug "SourcePath: $SourcePath"

        $SourceFile = $SourceItem.Name #Split-Path $Source -Resolve -Leaf
        Write-Debug "SourceFile: $SourceFile"

        $ADoc = (Split-Path $Source -Resolve -Leaf) -Replace '.csv', '.adoc'
        Write-Debug "ADoc: $ADoc"

        $File = (Join-Path -Path $DestinationItem -ChildPath $ADoc)

        # 
        $StreamWriter = New-Object -TypeName System.IO.StreamWriter -ArgumentList (
            $File,
            $False,
            [System.Text.Encoding]::Default
        ) -ErrorAction Stop

        # replace document template variables ({}) with actual values
        $Document = ($DocumentTemplate -f $SourceFile, ([System.security.principal.Windowsidentity]::Getcurrent().name), (Get-Date))
        $StreamWriter.WriteLine($Document)

        $Columns = (Get-Content $Source | Select-Object -First 1).Split($Delimiter)
        $Columns | % {
              Write-Debug $_
              $StreamWriter.WriteLine("=== $_")

              # remove spaces and illegal characters from file name
              $SafeFileName = Invoke-Sanitizer -Value $_ -Spaces -Illegals
              #Write-Verbose $SafeFileName

              # $Query = ($QueryTemplate -f $_, ".\csv\$_.csv", $Source)
              $Query = ($QueryTemplate -f $_, "$Destination\csv\$SafeFileName.csv", $SourceItem.FullName)
              Write-Debug $Query
              & LogParser $Query

              # $Include = ($IncludeTemplate -f $_)
              $Include = ($IncludeTemplate -f ".\csv\$SafeFileName.csv")

              #Write-Verbose $Include
              $StreamWriter.WriteLine($Include)

        }

        # Close open files and cleanup objects
        $StreamWriter.Flush()
        $StreamWriter.Close()
        $StreamWriter.Dispose()

        # begin foreach loop
        # Get-ChildItem $evtxfolder -Filter *.evtx | `
        # Foreach-Object {
        # $LPARGS = ("-i:evt", "-o:syslog", "SELECT STRCAT(`' evt-Time: `', TO_STRING(TimeGenerated, `'dd/MM/yyyy, hh:mm:ss`')),EventID,SourceName,ComputerName,Message INTO $SERVER FROM $CURRENTOBJECT") #obviously, this won't work.

        # $LP = Start-Process -FilePath $LOGPARSER -ArgumentList $LPARGS -Wait -Passthru -NoNewWindow
        # $LP.WaitForExit() # wait for logs to finish

        # return a reference to the ADoc that was created
        If ($PassThru) { Write-Output (Get-Item $File) }
    }
    END {}

}

Set-Alias ica Invoke-CsvAnalyzer
