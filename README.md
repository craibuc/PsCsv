# PsCsv

PowerShell module to perform various tasks on a CSV file.

## Dependencies

- PowerShell v3 - `Invoke-CsvAnalyzer`, `Invoke-CsvCleanser`, `Invoke-CsvDistiller`, `Remove-CsvColumns`
- [Microsoft’s logparser](https://technet.microsoft.com/en-us/scriptcenter/dd919274.aspx) - `Invoke-CsvAnalyzer`, `Invoke-CsvDistiller`
- [Pester](https://github.com/pester/Pester) - unit testing
- [AsciiDoctor](http://asciidoctor.org/) - generating `Invoke-CsvAnalyzer`'s HTML report
- [Ruby](https://www.ruby-lang.org/en/) - AsciiDoctor is a Ruby Gem

## Installation

### Dependencies
#### PowerShell

- https://www.microsoft.com/en-us/download/details.aspx?id=34595
- execute `PS> Set-ExecutionPolicy RemoteSigned –Scope CurrentUser`

#### Logparser

- Install [Microsoft’s logparser](https://technet.microsoft.com/en-us/scriptcenter/dd919274.aspx) 
- Add 'C:\Program Files (x86)\Log Parser 2.2' to your system's `Path` environment variable

#### Ruby

- Install [Ruby for Windows](http://rubyinstaller.org/)

#### AsciiDoctor

From within the Ruby shell:

 - `$ gem install asciidoctor`
 - `$ gem install coderay`
 
### Module

-	Download https://github.com/craibuc/PsCsv/archive/master.zip; extract contents
-	Rename folder from `PsCsv-master` to `PsCsv`
-	Move folder to your PowerShell `Modules` folder (C:\Users\<user> \Documents\WindowsPowerShell\Modules)

## Cmdlets

### ConvertTo-AsciiDoc

Converts the results of `Invoke-CsvAnalyzer` Cmdlet to an AsciiDoc document.

#### Motivation

I needed a nice way to display the results of the `Invoke-CsvAnalyzer` Cmdlet.

#### Usage

```powershell
# import the module
PS> Import-Module PsCsv -Force

# Calculate minimum and maximum values for every column, saving output in AsciiDoc syntax.
PS> Invoke-CsvAnalyzer C:\Users\<user>\export.csv -Range | ConvertTo-AsciiDoc -Title export.csv | Out-File C:\Users\<user>\export.adoc -Encoding UTF8

# assuming that AsciiDoctor is installed, convert document to HTML 
PS> asciidoctor export.adoc

### Invoke-CsvAnalyzer

Generates an HTML report of all the CSV file's columns and .

#### Motivation
I was researching ways to ‘cleanse’ my CSV files of NULLs and milliseconds so that they are more-easily consumed by Excel users.

While I decided to write my own script to handle this, I stumbled upon Microsoft’s logparser.  It (both command line and DLL interfaces) was built to query large web logs, using a SQL-like syntax; I figured that I could use it for my purposes.

`Invoke-CsvAnalyzer` generates a PsCustomObject that represents each column header in the CSV file.  Each column object is added to the pipeline, where it is passed one or more filters for processing.

Each filter makes use of the logparser to run a query for each column object in the pipefile.  The results of the queries are add to the column object's measurement collections.

#### Usage

```powershell
# import the module
PS> Import-Module PsCsv -Force

# Calculate minimum and maximum values for every column, saving output in AsciiDoc syntax.
PS> Invoke-CsvAnalyzer C:\Users\<user>\export.csv -Range | ConvertTo-AsciiDoc -Title export.csv | Out-File C:\Users\<user>\export.adoc -Encoding UTF8

# Calculate minimum and maximum values for columns COL_A and COL_B only, saving output in AsciiDoc syntax.
PS> Invoke-CsvAnalyzer C:\Users\<user>\export.csv -Include 'COL_A','COL_B' -Range | ConvertTo-AsciiDoc -Title export.csv | Out-File C:\Users\<user>\export.adoc -Encoding UTF8

# Calculate minimum and maximum values for all columns, excluding COL_C and COL_D, saving output in AsciiDoc syntax.
PS> Invoke-CsvAnalyzer C:\Users\<user>\export.csv -Exclude 'COL_C','COL_D' -Range | ConvertTo-AsciiDoc -Title export.csv | Out-File C:\Users\<user>\export.adoc -Encoding UTF8

# Calculates the Top 5 values for all columns, saving output in AsciiDoc syntax.
PS> Invoke-CsvAnalyzer C:\Users\<user>\export.csv -Range -Top 5 | ConvertTo-AsciiDoc -Title export.csv | Out-File C:\Users\<user>\export.adoc -Encoding UTF8

# Calculates the minimum, maximum, and Top all values for all columns, saving output in AsciiDoc syntax.
PS> Invoke-CsvAnalyzer C:\Users\<user>\export.csv -Range -Top -1 | ConvertTo-AsciiDoc -Title export.csv | Out-File C:\Users\<user>\export.adoc -Encoding UTF8
```

#### Enhancements

-	Exclude columns by name
-	Add other types of queries (e.g. MIN/MAX) and assign them to selected columns (by data type)
-	Add logparser charting support
-	Add d3.js visualization support?

### Invoke-CsvCleanser
Use PowerShell to remove unwanted characters from a CSV file.

#### Motivation

SQL Server Management Studio (SSMS) 2012 adds the following to CSV files created by its `Save Results As...` feature:

- the word 'NULL' to represent a `NULL` value; e.g `Foo,NULL,Bar`, rather than `Foo,,Bar`
- adds milliseconds to `datetime` values; e.g `Foo,2015-07-24 00:00:00.0000,Bar`, rather than `Foo,2015-07-24 00:00:00,Bar`

This behavior also occurs with `sqlcmd`.

Issues:

- including the word 'NULL' inflates the size of the CSV file
- Excel doesn't automatically recognize a value like `2015-07-24 00:00:00.0000` as a `datetime`, so formatting isn't applied correctly.

#### Usage

```powershell
# import the module
PS> Import-Module PsCsv -Force

# excute the script
PS> Invoke-CsvCleanser path\to\csv\file.csv -Nulls -Milliseconds
```

### Invoke-CsvDistiller

Generate the `DISTINCT` records for all columns in a CSV file, including a record count for each combination.

#### Motivation

#### Usage

```powershell
# import the module
PS> Import-Module PsCsv -Force

# excute the script
PS> Invoke-CsvDistiller path\to\csv\file.csv -Include 'COL_A','COL_B','COL_C' -Exclude 'COL_D'
```

### Remove-CsvColumns

Use PowerShell to remove unwanted columns from a CSV file.

#### Motivation

Needed a quick way to remove [protected-health information (PHI)](https://en.wikipedia.org/wiki/Protected_health_information) from a CSV file to distributed to others.

#### Usage

```powershell
# import the module
PS> Import-Module PsCsv -Force

# excute the script
PS> Remove-CsvColumns path\to\csv\file.csv -Exclude 'COL_A','COL_B','COL_C'
```
## Filters

A PowerShell `Filter` is invoked for each item in the pipeline.

### Range

Calculates the minimum and maximum for each column object it receives.  Invoked by using the `-Range` parameter with the `Invoke-CsvAnalyzer` Cmdlet.

### Top

Generates a PsCustomObject collection of Value/Records each column object it receives.  Invoked by using the `-Top <N>` parameter with the `Invoke-CsvAnalyzer` Cmdlet.  An `N` value of `-1` will generate results for all values; an `N` value > 0 will generate the `Top N` records.

## Contributing

- Fork the project
- Clone the repository (`git clone git@github.com:<your github name here>/PsCsv.git`) to your `Modules` folder (C:\Users\<user> \Documents\WindowsPowerShell\Modules)
- Add code; try to align with enhancements and fixes to items on the issues list
- Add unit tests (Pester); ensure that all test pass
- Push changes to your github account
- Create a pull request
