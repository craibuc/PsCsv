$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"
# $here = Split-Path -Parent $MyInvocation.MyCommand.Path

# Import-Module PsCsvDistiller -Force

Describe -tag 'distiller' "Invoke-CsvDistiller" {

    # arrange
    $nl = [Environment]::NewLine

    $RECORDS=@"
NUMERIC_FIELD,DATE_FIELD,STRING_FIELD
1,3/1/2015,BB
2,5/1/2015,BB
3,5/1/2015,BB
4,5/1/2015,BB
NULL,NULL,NULL
"@

    $CSV = New-item "TestDrive:\data.csv" -Type File
    Set-Content $CSV -Value $RECORDS

    Context "When -Included parameter's value is supplied" {

      #arrange
      $expected=@"
DATE_FIELD,STRING_FIELD,RECORDS
5/1/2015,BB,3
NULL,NULL,1
3/1/2015,BB,1
"@

      # act
      $actual = (Invoke-CsvDistiller -p $CSV -Include 'DATE_FIELD','STRING_FIELD' -Verbose) -Join "`n"

      It "Should return the correct unique values" {
        # assert
        $actual | Should Be $Expected
      }

    } # Context

    Context "When -Excluded parameter's value is supplied" {

      #arrange
      $expected=@"
DATE_FIELD,STRING_FIELD,RECORDS
5/1/2015,BB,3
NULL,NULL,1
3/1/2015,BB,1
"@

      # act
      $actual = (Invoke-CsvDistiller -p $CSV -Exclude 'NUMERIC_FIELD' -Verbose) -Join "`n"

      It "Should return the correct unique values" {
        # assert
        $actual | Should Be $Expected
      }

    } # Context

}
