$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe -tag 'remove' "Remove-CsvColumns" {

$content = @"
DATE_COLUMN,DATETIME_COLUMN,TEXT_COLUMN,NUMERIC_COLUMN
2015-05-01,2015-05-01 23:00:00,'LOREM IPSUM 0',0
2015-05-02,2015-05-02 23:00:00,'LOREM IPSUM 1',1
2015-05-03,2015-05-03 23:00:00,'LOREM IPSUM 2',2
"@

  Context "Mulitple columns specified" {

      # arrange
      $CSV = New-item "TestDrive:\data.csv" -Type File
      Set-Content $CSV -Value $content

$expected = @"
DATETIME_COLUMN,NUMERIC_COLUMN
2015-05-01 23:00:00,0
2015-05-02 23:00:00,1
2015-05-03 23:00:00,2
"@

      It "Should produce a file with the expected column of data" {

          # act
          Remove-CsvColumns $CSV 'TEXT_COLUMN','DATE_COLUMN' -Verbose

          # assert
          $actual = (Get-Content $CSV) -join "`n"
          $actual | Should Be $expected
      }

  } # Operations

} # Describe

