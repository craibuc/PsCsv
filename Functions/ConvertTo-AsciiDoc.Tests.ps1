$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "ConvertTo-AsciiDoc" {

    $RECORDS=@"
NUMERIC_FIELD,DATE_FIELD,STRING_FIELD
1,3/1/2015,BB
2,5/1/2015,BB
3,5/1/2015,BB
4,5/1/2015,BB
NULL,NULL,NULL
"@

    Context "Given that a valid PsCustomObject is supplied" {

      # arrange
      $Source = New-item "TestDrive:\data.csv" -Type File
      Set-Content $Source -Value $RECORDS

      # act
      # $Collection = Invoke-CsvAnalyzer -File $Source -Range -Verbose

        It -skip "Should produce a document in AsciiDoc format" {
            # assert
            #$Adoc.fullname | Should Exist
            $False | Should Be $true
        }
    }

}
