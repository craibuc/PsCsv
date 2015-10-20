$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Range" {

$RECORDS=@"
NUMERIC_FIELD,DATE_FIELD,STRING_FIELD
1,3/1/2015,AA
2,4/1/2015,BB
3,5/1/2015,CC
4,5/1/2015,DD
,,
"@

    # arrange
    $CSV = New-item "TestDrive:\data.csv" -Type File
    Set-Content $CSV -Value $RECORDS

  Context "When a date field is supplied" {

    # act
    $actual = Range -p $CSV -f 'DATE_FIELD' -Verbose

    It "Calculates the minimum and maximum values" {
      # assert
      $actual[0].values.minimum | Should Be '3/1/2015'
      $actual[0].values.maximum | Should Be '5/1/2015'
    }

  }

  Context "When a numeric field is supplied" {

    # act
    $actual = Range -p $CSV -f 'NUMERIC_FIELD' -Verbose

    It "Calculates the minimum and maximum values" {
      # assert
      $actual[0].values.minimum | Should Be '1'
      $actual[0].values.maximum | Should Be '4'
    }

  }

  Context "When a string field is supplied" {

    # act
    $actual = Range -p $CSV -f 'STRING_FIELD' -Verbose

    It "Calculates the minimum and maximum values" {
      # assert
      $actual[0].values.minimum | Should Be 'AA'
      $actual[0].values.maximum | Should Be 'DD'
    }

  }

}