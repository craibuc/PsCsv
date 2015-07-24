$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Invoke-CsvCleanser" {

    $nl = [Environment]::NewLine
    $content = '"DATE_COLUMN","DATETIME_COLUMN","TEXT_COLUMN"' + $nl + '2015-05-01,2015-05-01 23:00:00.000,LOREM IPSUM' + $nl + 'NULL,null,nuLL'

    It "Should remove all instances of the word 'NULL'" {

        # arrange
        $0000 = New-item "TestDrive:\0000.csv" -Type File
        Set-Content $0000 -Value $content

        # act
        Invoke-CsvCleanser $0000 -Nulls -Verbose

        # assert
        $actual = (Get-Content $0000) -join $nl
        $expected = '"DATE_COLUMN","DATETIME_COLUMN","TEXT_COLUMN"' + $nl + '2015-05-01,2015-05-01 23:00:00.000,LOREM IPSUM' + $nl + ',,'

        $actual | Should Be $expected
    }

    It "Should remove milliseconds from all datetimes" {

        # arrange
        $0001 = New-item "TestDrive:\0001.csv" -Type File
        Set-Content $0001 -Value $content

        # act
        Invoke-CsvCleanser $0001 -Milliseconds -Verbose

        # assert
        $actual = (Get-Content $0001) -join $nl
        $expected = '"DATE_COLUMN","DATETIME_COLUMN","TEXT_COLUMN"' + $nl + '2015-05-01,2015-05-01 23:00:00,LOREM IPSUM' + $nl + 'NULL,null,nuLL'

        $actual | Should Be $expected
    }

    It "Should remove double quotes" {

        # arrange
        $0002 = New-item "TestDrive:\0002.csv" -Type File
        Set-Content $0002 -Value $content

        # act
        Invoke-CsvCleanser $0002 -DoubleQuotes -Verbose

        # assert
        $actual = (Get-Content $0002) -join $nl
        $expected = 'DATE_COLUMN,DATETIME_COLUMN,TEXT_COLUMN' + $nl + '2015-05-01,2015-05-01 23:00:00.000,LOREM IPSUM' + $nl + 'NULL,null,nuLL'

        $actual | Should Be $expected

    }

}

Describe "Aliases" {

    It "Invoke-CsvCleanser alias should exist" {
        (Get-Alias -Definition Invoke-CsvCleanser).name | Should Be "icc"
    }

}