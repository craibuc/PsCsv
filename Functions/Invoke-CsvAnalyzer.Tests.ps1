$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe -tag 'analyzer' "Invoke-CsvAnalyzer" {

    $RECORDS=@"
NUMERIC_FIELD,DATE_FIELD,STRING_FIELD
1,3/1/2015,BB
2,5/1/2015,BB
3,5/1/2015,BB
4,5/1/2015,BB
NULL,NULL,NULL
"@

    Context "Given that the source parameter is supplied" {

        # arrange
        $Source = New-item "TestDrive:\data.csv" -Type File
        Set-Content $Source -Value $RECORDS

        $Destination = Split-Path $Source -Resolve -Parent

        # act
        # $Adoc = Invoke-CsvAnalyzer -Source $Source -Destination $Destination -PassThru -Verbose
        Invoke-CsvAnalyzer -File $Source -Range -Verbose

        It -skip "Should produce a summary document in AsciiDoc format" {
            # assert
            #$Adoc.fullname | Should Exist
            $False | Should Be $true
        }

    }

}
