<#
.SYNOPSIS
Produce a statistical analysis of a CSV file.

.DESCRIPTION
TODO

.PARAMETER File
The CSV file to be processed.

.PARAMETER Included
String array of columns to be included from processing.  If not specified, all columns are included.

.PARAMETER Excluded
String array of columns to be excluded from processing.  If not specified, no columns are excluded.

.PARAMETER Range
Calculates the minimum and maximum value for each of the CSV's columns; default: $false.

.PARAMETER Top
Performs a Top N query on each of the CSV's columns (-1 performs the calculation for every value in the column); default: $false.

.EXAMPLE
Invoke-CsvAnalyzer C:\Users\<user>\export.csv -Range

Calculate minimum and maximum values for every column.

.EXAMPLE
Invoke-CsvAnalyzer C:\Users\<user>\export.csv -Include 'COL_A','COL_B' -Range

Calculate minimum and maximum values for columns COL_A and COL_B only.

.EXAMPLE
Invoke-CsvAnalyzer C:\Users\<user>\export.csv -Exclude 'COL_C','COL_D' -Range

Calculate minimum and maximum values for all columns, excluding COL_C and COL_D.

.EXAMPLE
Invoke-CsvAnalyzer C:\Users\<user>\export.csv -Range -Top 5

Calculates the Top 5 values for all columns.

.EXAMPLE
Invoke-CsvAnalyzer C:\Users\<user>\export.csv -Range -Top -1

Calculates the minimum, maximum, and Top all values for all columns.

#>
function Invoke-CsvAnalyzer {

    [CmdletBinding()]
    PARAM(
        [Parameter(Mandatory=$True,Position=1)]
        [alias('f')]
        [String]
        $File,

        [Parameter(Mandatory=$False,Position=2)]
        [alias('i')]
        [String[]]
        $Included,

        [Parameter(Mandatory=$False,Position=3)]
        [alias('e')]
        [String[]]
        $Excluded,

        [Switch] $Range,
        [int] $Top
    )

    BEGIN {
      Write-Debug "File: $File"
      Write-Debug "Included: $Included"
      Write-Debug "Excluded: $Excluded"
      Write-Debug "Range: $Range"
      Write-Debug "Top: $Top"
    }
    PROCESS {

      # get list of fields from file if none are specified
      if (-not $Included) {
          $Included = (Get-Content $File | Select-Object -First 1).Split(',')
      }

      # remove excluded fields
      $Included = $Included | Where-Object { $Excluded -NotContains $_ }

      $Included | ForEach-Object {

          Write-Verbose $_

          # create a hash that represents each column; initialize values
          $Column = [PsCustomObject]@{'Name'=$_;'Scalars'=@();'Sets'=@()}

          if ($Range) { $Column | Range -File $File }
          if ($Top) { $Column | Top -File $File -N $Top }
          # add to pipeline
          $Column

      }
    }
    END {}

}

Set-Alias ica Invoke-CsvAnalyzer
