function FormatAs-Html {

    Param(
        [Parameter(ValueFromPipeline=$True)]
        [PsCustomObject[]]$Columns,

        [alias('t')]
        [string]$Title='Untitled'
    )
    
    BEGIN {

        [string[]]$B=@()

        $B += "<!DOCTYPE html><html lang='en'><head>"
        $B += "<title>$Title</title>"
        $B += "<meta charset='UTF-8'>"
        $B += "<meta name='viewport' content='width=device-width, initial-scale=1.0'>"
        $B += "<meta name='author' content='$([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)'>"
        $B += "<link rel='stylesheet' href='https://fonts.googleapis.com/css?family=Open+Sans:300,300italic,400,400italic,600,600italic%7CNoto+Serif:400,400italic,700,700italic%7CDroid+Sans+Mono:400'>"
        $B += "<link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.2.0/css/font-awesome.min.css'>"
        # $B += "<link rel='stylesheet' href='.\asciidoctor.css'>"
        $B += "<style>"
        $B += ( Get-Content '..\asciidoctor.css' -Raw )
        $B += "</style>"
        $B += "</head>"
        $B += "<body class='article'>"

$B += @"
<div id="header">
    <h1>$Title</h1>
    <div class='details'>
        <span id='author' class='author'>$([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)</span><br>
        <span id='revdate'>$(Get-Date)</span>
    </div>
</div>
<div id='content'>
"@

    }
    PROCESS {

        ForEach ($Column IN $Columns) {
            $B += "<div class='sect1'>"
            $B += "<h2 id='_$($Column.Name.ToLower())'>$($Column.Name)</h2>"
            $B += "<div class='sectionbody'>"

            if ( $Column.Scalars ) {
                $B += "<div class='sect2'><h3>Scalars</h3>"
                $B += "<table class='tableblock frame-all grid-all'>"
                $B += "<colgroup><col><col></colgroup>"
                $B += "<tbody>"
                ForEach ($Scalar IN $Column.Scalars) {
                    $B += "<tr>"
                    $B += "<td class='tableblock halign-left valign-top'><p class='tableblock'>$($Scalar.Name)<p/></td>"
                    $B += "<td class='tableblock halign-left valign-top'><p class='tableblock'>$($Scalar.Value)</p></td>"
                    $B += "</tr>"
                }
                $B += "</tbody></table></div>"
            } # If

            if ( $Column.Sets ) {
                ForEach ($Set IN $Column.Sets) {
                    $B += "<div class='sect3'><h3>$($Set.Name)</h3>"
                    $B += "<table class='tableblock frame-all grid-all'>"
                    $B += "<colgroup><col><col></colgroup>"
                    $B += "<tbody>"
                    ForEach ($Row IN $Set.Value) {
                        $B += "<tr>"
                        $B += "<td class='tableblock halign-left valign-top'><p class='tableblock'>$($Row.Value)</p></td>"
                        $B += "<td class='tableblock halign-left valign-top'><p class='tableblock'>$($Row.Records)<p/></td>"
                        $B += "</tr>"
                    }
                    $B += "</tbody></table></div>"
                }
            }

            $B += "</div></div>"
        } # Foreach
    } # PROCESS
    END {

        $B += "</div>"
        $B += @"
<div id='footer'>
    <div id='footer-text'>
        <span id='revdate'>$(Get-Date)</span>
    </div>
</div>
</body></html>
"@

        $B -Join [Environment]::NewLine

    }

}