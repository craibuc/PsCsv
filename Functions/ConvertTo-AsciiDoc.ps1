Function ConvertTo-AsciiDoc {

    [CmdletBinding()]
    PARAM(
        [Parameter(ValueFromPipeline=$True)]
        [PsCustomObject[]]$Columns,

        [alias('t')]
        [string]$Title='Untitled'
    )

    BEGIN {
      # Write-Verbose "Path: $Source"

        $nl = [Environment]::NewLine

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

"@

        # replace document-template variables ({0},{1},{2}) with actual values
        $Document = ($DocumentTemplate -f $Title, ([System.security.principal.Windowsidentity]::Getcurrent().name), (Get-Date)) + $nl
        $Document += "== Fields" + $nl

    } # BEGIN
    PROCESS {

        ForEach ($Column IN $Columns) {

            $Document += "=== $($Column.Name)" + $nl

            if ( $Column.Scalars ) {
                $Document += "==== Scalars" + $nl
                $Document += "[cols='',opts='autowidth']" + $nl
                $Document += "|===" + $nl
                ForEach ($Scalar IN $Column.Scalars) {
                    $Document += "|$($Scalar.Name)|$($Scalar.Value)" + $nl
                }
                $Document += "|===" + $nl
            } # If

            if ( $Column.Sets ) {
                ForEach ($Set IN $Column.Sets) {
                    $Document += "==== $($Set.Name)" + $nl
                    $Document += "[cols='',opts='autowidth']" + $nl
                    $Document += "|===" + $nl
                    ForEach ($Row IN $Set.Value) {
                        $Document += "|$($Row.Value)|$($Row.Records)" + $nl
                    }
                    $Document += "|===" + $nl
                }
            } # If
        } # Foreach

    } # PROCESS
    END {
        $Document
    }

}
