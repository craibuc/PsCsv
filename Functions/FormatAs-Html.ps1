function FormatAs-Html {

    Param(
        [Parameter(ValueFromPipeline=$True)]
        [PsCustomObject[]]$Columns,
        [string]$File
    )
    
    BEGIN {
        $Document = "<html><head><title>$File</title></head><body><h1>$File</h1>"
    }
    PROCESS {
        ForEach ($Column IN $Columns) {
            $Document += "<h2>$($Column.Name)</h2>"

#            $Scalars = $Column.Measurements | Where-Object {-not $_.Value.GetType().IsArray }
#            $Sets = $Column.Measurements | Where-Object { $_.Value.GetType().IsArray }

            if ( $Column.Scalars ) {
                $Document += "<h3>Scalars</h3>"
                $Document += "<table border='1'>"
                ForEach ($Scalar IN $Column.Scalars) {
                    $Document += "<tr><td>$($Scalar.Name)</td><td>$($Scalar.Value)</td></tr>"
                }
                $Document += "</table>"
            } # If

            if ( $Column.Sets ) {
                ForEach ($Set IN $Column.Sets) {
                    $Document += "<h3>$($Set.Name)</h3>"
                    $Document += "<table border='1'>"
                    ForEach ($Row IN $Set.Value) {
                        $Document += "<tr><td>$($Row.Value)</td><td>$($Row.Records)</td></tr>"
                    }
                    $Document += "</table>"
                }
            }

        } # Foreach
    } # PROCESS
    END {
        $Document += "<body></html>"
        $Document
    }

}