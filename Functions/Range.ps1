Filter Range {

    param (
        [String] $File
    )

    $Query = "SELECT Min([$($_.Name)]) AS Minimum, Max([$($_.Name)]) AS Maximum FROM '$File'"

    [xml] $xml = & logparser $Query -stats:off -o:xml

    $Measurement=[PsCustomObject]@{'Name'='Minimum';Value=$xml.root.row.Minimum.Trim()}
    $_.Scalars+=$Measurement

    $Measurement=[PsCustomObject]@{'Name'='Maximum';Value=$xml.root.row.Maximum.Trim()}
    $_.Scalars+=$Measurement

    # return object to pipeline
    # $_

}
