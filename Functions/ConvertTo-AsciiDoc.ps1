function ConvertTo-AsciiDoc {

    [CmdletBinding()]
    PARAM(
        [Parameter(Mandatory=$True,Position=1)]
        [Alias('s')]
        [String[]] $Source,

        [Parameter(Mandatory=$False,Position=2)]
        [Alias('d')]
        [String] $Destination='.',

        [Switch] $PassThru
    )

    BEGIN {
      # Write-Verbose "Path: $Source"

      $DocumentTemplate=@"
= {0}
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
    } # BEGIN
    PROCESS {

        # 
        $StreamWriter = New-Object -TypeName System.IO.StreamWriter -ArgumentList (
            $File,
            $False,
            [System.Text.Encoding]::Default
        ) -ErrorAction Stop

        # replace document template variables ({}) with actual values
        $Document = ($DocumentTemplate -f $SourceFile, ([System.security.principal.Windowsidentity]::Getcurrent().name), (Get-Date))
        $StreamWriter.WriteLine($Document)

        # Close open files and cleanup objects
        $StreamWriter.Flush()
        $StreamWriter.Close()
        $StreamWriter.Dispose()

        # return a reference to the ADoc that was created
        If ($PassThru) { Write-Output (Get-Item $File) }

    } # PROCESS
    END {}

}
