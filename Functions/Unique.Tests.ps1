$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Unique" {

$RECORDS=@"
NUMERIC_FIELD,DATE_FIELD,STRING_FIELD
1,3/1/2015,AA
2,5/1/2015,BB
3,5/1/2015,BB
4,5/1/2015,DD
,,
"@

    # arrange
    $CSV = New-item "TestDrive:\data.csv" -Type File
    Set-Content $CSV -Value $RECORDS

  Context "When default properties are supplied" {

    # act
    $actual = Unique -p $CSV -f 'DATE_FIELD' -Verbose

    It "Should return the correct unique values" {
      # assert
      $actual.values[0].value | Should Be '5/1/2015'
      $actual.values[2].value | Should Be '3/1/2015'
      $actual.values[1].value | Should Be '<null>'
    }

    It "Should return the correct counts" {
      # assert
      $actual.values[0].records | Should Be 3
      $actual.values[1].records | Should Be 1
      $actual.values[2].records | Should Be 1
    }

  }

  Context "When the Top parameter is also supplied" {

    # act
    $actual = Unique -p $CSV -f 'DATE_FIELD' -t 2 -Verbose

    It "Should return the correct number of results" {
      # assert
      $actual.values.length | Should Be 2
    }

  }
}