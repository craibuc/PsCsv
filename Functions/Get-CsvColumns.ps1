function Get-CsvColumns {

    param (
        [Parameter(Mandatory=$True,Position=1)]
        [alias('p')]
        [String] $Path,

        [Parameter(Mandatory=$False,Position=2)]
        [alias('d')]
        [String] $Delimiter=',',

        [alias('n')]
        [Switch] $NoHeaders

    )
    BEGIN {}
    PROCESS {
        $Fields = (Get-Content $Path | Select-Object -First 1).Split($Delimiter)

        # if the file doesn't contain headers, replace fields with generic values 
        if ($NoHeaders) {
          $Temp=@()
          for ($i=0; $i -lt $Fields.Length; $i++) { $Temp += "FIELD_$i" }
          $Fields = $Temp
        }
        # return values to pipeline
        $Fields
    }
    END {}

}

Set-Alias gcc Get-CsvColumns
