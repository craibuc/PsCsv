$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Top" {

$RECORDS=@"
NUMERIC_FIELD,DATE_FIELD,STRING_FIELD
1,3/1/2015,AA
2,5/1/2015,BB
3,5/1/2015,BB
4,5/1/2015,DD
"@

    # arrange
    $CSV = New-item "TestDrive:\data.csv" -Type File
    Set-Content $CSV -Value $RECORDS

  Context "When a Top parameter > 0 is supplied" {

    # arrange
    $Column = [PsCustomObject]@{'Name'='DATE_FIELD';'Scalars'=@();'Sets'=@()}

    # act
    $Column | Top 1 -File $CSV 

    It "Should return the correct unique values" {
      # assert
      $Column.Sets[0].Value.Value | Should Be '5/1/2015'
    }

    It "Should return the correct counts" {
      # assert
      $Column.Sets[0].Value.Records | Should Be 3
    }

  }

  Context "When the Top -1 parameter is also supplied" {

    # arrange
    $Column2 = [PsCustomObject]@{'Name'='DATE_FIELD';'Scalars'=@();'Sets'=@()}

    # act
    $Column2 | Top -1 -File $CSV 

    It "Should return the correct number of results" {
      # assert
      $Column2.Sets[0].Value.Length | Should Be 2
    }

  }
}