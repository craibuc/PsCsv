$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Invoke-CsvCleanser" {

    $nl = [Environment]::NewLine
    $content = '"DATE_COLUMN","DATETIME_COLUMN","TEXT_COLUMN"' + $nl + '2015-05-01,2015-05-01 23:00:00.000,LOREM IPSUM' + $nl + 'NULL,null,nuLL'

    Context "Switches" {

        # BeforeEach {
        #     Write-Host 'BeforeEach'

        #     $CSV = New-item "TestDrive:\0000.csv" -Type File
        #     Set-Content $CSV -Value $content

        # }

        # AfterEach {
        #     Write-Host 'AfterEach'

        #     Remove-Item $CSV

        # }

        It "Should remove all instances of the word 'NULL' if -Nulls set" {

            # arrange
            $CSV = New-item "TestDrive:\Nulls.csv" -Type File
            Set-Content $CSV -Value $content

            # act
            Invoke-CsvCleanser $CSV -Nulls -Verbose

            # assert
            $actual = (Get-Content $CSV) -join $nl
            $expected = '"DATE_COLUMN","DATETIME_COLUMN","TEXT_COLUMN"' + $nl + '2015-05-01,2015-05-01 23:00:00.000,LOREM IPSUM' + $nl + ',,'

            $actual | Should Be $expected
        }

        It "Should remove milliseconds from all datetimes if -Milliseconds set" {

            # arrange
            $CSV = New-item "TestDrive:\Milliseconds.csv" -Type File
            Set-Content $CSV -Value $content

            # act
            Invoke-CsvCleanser $CSV -Milliseconds -Verbose

            # assert
            $actual = (Get-Content $CSV) -join $nl
            $expected = '"DATE_COLUMN","DATETIME_COLUMN","TEXT_COLUMN"' + $nl + '2015-05-01,2015-05-01 23:00:00,LOREM IPSUM' + $nl + 'NULL,null,nuLL'

            $actual | Should Be $expected
        }

        It "Should remove double quotes if -DoubleQuotes set" {

            # arrange
            $CSV = New-item "TestDrive:\DoubleQuotes.csv" -Type File
            Set-Content $CSV -Value $content

            # act
            Invoke-CsvCleanser $CSV -DoubleQuotes -Verbose

            # assert
            $actual = (Get-Content $CSV) -join $nl
            $expected = 'DATE_COLUMN,DATETIME_COLUMN,TEXT_COLUMN' + $nl + '2015-05-01,2015-05-01 23:00:00.000,LOREM IPSUM' + $nl + 'NULL,null,nuLL'

            $actual | Should Be $expected

        }

        It "Should play a system sound if -Alert set" {

            # arrange
            $CSV = New-item "TestDrive:\Alert.csv" -Type File
            Set-Content $CSV -Value $content

            # act
            Invoke-CsvCleanser $CSV -Nulls -Alert -Verbose

            # assert
            $true | Should Be $true
        }

        It "Should return a FileInfo object if -PassThru set" {

            # arrange
            $CSV = New-item "TestDrive:\PassThru.csv" -Type File
            Set-Content $CSV -Value $content

            # act
            $actual = Invoke-CsvCleanser $CSV -Nulls -PassThru -Verbose
            # Write-Host "GT: $($actual.GetType().name)"

            # assert
            ($actual).GetType() | Should Be System.IO.FileInfo
        }

    } # Switches

    Context "Operations" {

        It "Should process multiple items" {

            # arrange
            $CSV0 = New-item "TestDrive:\CSV0.csv" -Type File
            Set-Content $CSV0 -Value $content

            $CSV1 = New-item "TestDrive:\CSV1.csv" -Type File
            Set-Content $CSV1 -Value $content

            # act
            Get-ChildItem $TestDrive | Invoke-CsvCleanser -Null -Verbose

            # assert
            $actual0 = (Get-Content $CSV0) -join $nl
            $actual1 = (Get-Content $CSV1) -join $nl
            $expected = '"DATE_COLUMN","DATETIME_COLUMN","TEXT_COLUMN"' + $nl + '2015-05-01,2015-05-01 23:00:00.000,LOREM IPSUM' + $nl + ',,'

            $actual0 | Should Be $expected
            $actual1 | Should Be $expected

        }

    } # Operations

} # Describe
