$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Get-CsvColumns" {

$RECORDS=@"
NUMERIC_FIELD,DATE_FIELD,STRING_FIELD
1,3/1/2015,AA
2,4/1/2015,BB
3,5/1/2015,CC
4,5/1/2015,DD
,,
"@

$NO_HEADERS=@"
1,3/1/2015,AA
2,4/1/2015,BB
3,5/1/2015,CC
4,5/1/2015,DD
,,
"@

    Context "When CSV file with column headers is provided" {

      # arrange
      $CSV = New-item "TestDrive:\data.csv" -Type File
      Set-Content $CSV -Value $RECORDS

      # act
      $actual = Get-CsvColumns -p $CSV -Verbose

      It "It correctly identifies the column headers" {
        # assert
        $actual.length | Should Be 3
        $actual[0] | Should Be 'NUMERIC_FIELD'
        $actual[1] | Should Be 'DATE_FIELD'
        $actual[2] | Should Be 'STRING_FIELD'
      }

    }

    Context "When CSV file WITHOUT column headers is provided" {

      # arrange
      $CSV = New-item "TestDrive:\data.csv" -Type File
      Set-Content $CSV -Value $NO_HEADERS

      # act
      $actual = Get-CsvColumns -p $CSV -n -Verbose

      It "It generates the correct generic headers" {
        # assert
        $actual.length | Should Be 3
        $actual[0] | Should Be 'FIELD_0'
        $actual[1] | Should Be 'FIELD_1'
        $actual[2] | Should Be 'FIELD_2'
      }

    }

}
