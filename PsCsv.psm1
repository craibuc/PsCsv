Write-Host "Importing module PsCsv..."

#
# load (dot-source) *.PS1 files, excluding unit-test scripts (*.Tests.*), and disabled scripts (__*)
#
Get-ChildItem "$PSScriptRoot\Functions\*.ps1" | 
    Where-Object { $_.Name -like '*.ps1' -and $_.Name -notlike '__*' -and $_.Name -notlike '*.Tests*' } | 
    % { . $_ }

# commands
Export-ModuleMember ConvertTo-AsciiDoc, Get-CsvColumns, Invoke-CsvAnalyzer, Invoke-CsvCleanser, Invoke-CsvDistiller, Remove-CsvColumns #, FormatAs-Html

# aliases
Export-ModuleMember -Alias gcc, ica, icc, icd, rcc