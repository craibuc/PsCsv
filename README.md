# PsCsv

PowerShell module to perform various tasks on a CSV file.

## Dependencies

- PowerShell v3 - `Invoke-CsvAnalyzer`, `Invoke-CsvCleanser`, `Invoke-CsvDistiller`, `Remove-CsvColumns`
- [Microsoft’s logparser](https://technet.microsoft.com/en-us/scriptcenter/dd919274.aspx) - `Invoke-CsvAnalyzer`, `Invoke-CsvDistiller`
- [Pester](https://github.com/pester/Pester) - unit testing
- [AsciiDoctor](http://asciidoctor.org/) - generating `Invoke-CsvAnalyzer`'s HTML report
- [Ruby](https://www.ruby-lang.org/en/) - AsciiDoctor is a Ruby Gem

## Installation

-	Install dependencies
-	Download https://github.com/craibuc/PsCsv/archive/master.zip; extract contents
-	Rename folder from `PsCsv-master` to `PsCsv`
-	Move folder to your PowerShell `Modules` folder (C:\Users\<user> \Documents\WindowsPowerShell\Modules)

## Cmdlets

### Invoke-CsvAnalyzer

Generates an HTML report of all the CSV file's columns and .

#### Motivation
I was researching ways to ‘cleanse’ my CSV files of NULLs and milliseconds so that they are more-easily consumed by Excel users.

While I decided to write my own script to handle this, I stumbled upon Microsoft’s logparser.  It (both command line and DLL interfaces) was built to query large web logs, using a SQL-like syntax; I figured that I could use it for my purposes.

`Invoke-CsvAnalyzer` uses the logparser to repeatedly run a `SELECT DISTINCT` query for each column header in the CSV file.  The results of the queries, CSV files themselves, are referenced in a template file (in AsciiDoc fomat).  An AsciiDoc processor is used to generate the summary (HTML) document.

#### Usage

```powershell
# import the module
PS> Import-Module PsCsv -Force

# excute the script
PS> Invoke-CsvAnalyzer path\to\csv\file.csv
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

Not implemented yet.

#### Motivation

#### Usage

```powershell
# import the module
PS> Import-Module PsCsv -Force

# excute the script
PS> Remove-CsvColumns path\to\csv\file.csv 'COL_A','COL_B','COL_C'
```

## Contributing

- Fork the project
- Clone the repository (`git clone git@github.com:<your github name here>/PsCsv.git`) to your `Modules` folder (C:\Users\<user> \Documents\WindowsPowerShell\Modules)
- Add code; try to align with enhancements and fixes to items on the issues list
- Add unit tests (Pester); ensure that all test pass
- Push changes to your github account
- Create a pull request
