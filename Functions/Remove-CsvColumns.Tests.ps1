$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Remove-CsvColumns" {

  Context "Operations" {

      $nl = [Environment]::NewLine
      $content = '"DATE_COLUMN","DATETIME_COLUMN","TEXT_COLUMN"' + $nl + '2015-05-01,2015-05-01 23:00:00.000,LOREM IPSUM' + $nl + 'NULL,null,nuLL'

      It "Should remove a column by name" {

          # arrange
          $0000 = New-item "TestDrive:\0000.csv" -Type File
          Set-Content $0000 -Value $content

          # act
          Remove-CsvColumns $0000 'TEXT_COLUMN'

          # assert
          $actual = (Get-Content $0000) -join $nl
          $expected = '"DATE_COLUMN","DATETIME_COLUMN"' + $nl + '2015-05-01,2015-05-01 23:00:00.000' + $nl + ','

          $actual | Should Be $expected
      }

  } # Operations

  Context "Alias" {

    It "Should define an alias" {
        (Get-Alias -Definition Remove-CsvColumns).name | Should Be "rcc"
    }

  } # Alias

} # Describe

