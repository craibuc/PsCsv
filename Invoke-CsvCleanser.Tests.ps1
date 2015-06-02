$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Invoke-CsvCleanser" {

    $nl = [Environment]::NewLine

    # create CSV file; populate it with data
    $csv = "TestDrive:\0000.csv"
    Set-Content $csv -Value 'DATE_COLUMN,DATETIME_COLUMN,TEXT_COLUMN'
    Add-Content $csv -Value '2015-05-01,2015-05-01 23:00:00.000,LOREM IPSUM'
    Add-Content $csv -Value 'NULL,null,nuLL'
       
    It "Should remove all instances of the word 'NULL'" {
        Invoke-CsvCleanser -path $csv -nulls

        $actual = Get-Content $csv
        Write-Host $actual
        $expected = '"DATE_COLUMN","DATETIME_COLUMN","TEXT_COLUMN"' + $nl + '"2015-05-01","2015-05-01 23:00:00.000","LOREM IPSUM"' + $nl + '"","","",""'

        $actual | Should Be $expected
    }

    It "Should remove milliseconds from all datetimes" {
        Invoke-CsvCleanser -path $csv -Milliseconds

        $actual = Get-Content $csv
        Write-Host $actual
        $expected = '"DATE_COLUMN","DATETIME_COLUMN","TEXT_COLUMN"' + $nl + '"2015-05-01","2015-05-01 23:00:00","LOREM IPSUM"' + $nl + '"NULL","null","nuLL"'

        $actual | Should Be $expected
    }

}
