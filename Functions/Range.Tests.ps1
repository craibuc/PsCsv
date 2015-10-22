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

    # arrange
    $Column = [PsCustomObject]@{'Name'='DATE_FIELD';'Scalars'=@();'Sets'=@()}

    # act
    $Column | Range -File $CSV 

    It "Calculates the minimum and maximum values" {
      # assert
      $Column.Scalars[0].Value | Should Be '3/1/2015'
      $Column.Scalars[1].Value | Should Be '5/1/2015'
    }

  }

  Context "When a numeric field is supplied" {

    # arrange
    $Column = [PsCustomObject]@{'Name'='NUMERIC_FIELD';'Scalars'=@();'Sets'=@()}

    # act
    $Column | Range -File $CSV 

    It "Calculates the minimum and maximum values" {
      # assert
      $Column.Scalars[0].Value | Should Be '1'
      $Column.Scalars[1].Value | Should Be '4'
    }

  }

  Context "When a string field is supplied" {

    # arrange
    $Column = [PsCustomObject]@{'Name'='STRING_FIELD';'Scalars'=@();'Sets'=@()}

    # act
    $Column | Range -File $CSV 

    It "Calculates the minimum and maximum values" {
      # assert
      $Column.Scalars[0].Value | Should Be 'AA'
      $Column.Scalars[1].Value | Should Be 'DD'
    }

  }

}