# Invoke-CsvCleanser
Use PowerShell to remove unwanted characters from a CSV file.

SQL Server Management Studio (SSMS) 2012 adds the following to CSV files created by its `Save Results As...` feature:

- the word 'NULL' to represent a `NULL` value; e.g `Foo,NULL,Bar`, rather than `Foo,,Bar`
- adds milliseconds to `datetime` values; e.g `Foo,2015-07-24 00:00:00.0000,Bar`, rather than `Foo,2015-07-24 00:00:00,Bar`

This behavior also occurs with `sqlcmd`.

Issues:

- including the word 'NULL' inflates the size of the CSV file
- Excel doesn't automatically recognize a value like `2015-07-24 00:00:00.0000` as a `datetime`, so formatting isn't applied correctly.
