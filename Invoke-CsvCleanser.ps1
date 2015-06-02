function IsDate($object) {
    [Boolean]($object -as [DateTime])
}

function Invoke-CsvCleanser {

    
  [CmdletBinding()]
  Param(
    [parameter(Mandatory=$true)]
    [String]
    $Path,
    [switch]
    $Nulls,
    [switch]
    $Milliseconds
  )

  BEGIN {
    Write-Verbose "$($MyInvocation.MyCommand.Name)::Begin" 

#    Write-Verbose $Path
#    Write-Verbose $Nulls
#    Write-Verbose $Milliseconds

  }

  PROCESS {
    Write-Verbose "$($MyInvocation.MyCommand.Name)::Process"

    # open the file
    $data = Import-Csv $path

    # process each row
    $data | Foreach-Object { 

        # process each column
        Foreach ($property in $_.PSObject.Properties) {

            Write-Verbose ("Raw: {0}: {1}" -f $property.Name, $property.Value)

            # if column contains 'NULL', replace it with ''
            if ($Nulls -and ($property.Value -eq 'NULL')) {

                $property.Value = $property.Value -replace 'NULL', ''
                Write-Debug ("-Nulls: {0}: {1}" -f $property.Name, $property.Value)

            }
            
            # if column contains a date/time value, remove milliseconds
            elseif ( $Milliseconds -and (isDate($property.Value)) ) {

                $property.Value = $property.Value -replace '.000', ''

                Write-Debug ("-Milliseconds: {0}: {1}" -f $property.Name, $property.Value)
            }
        } 

    } 
    
    # save file
    $data | Export-Csv -Path $Path -NoTypeInformation
    
  }
  END { Write-Verbose "$($MyInvocation.MyCommand.Name)::End"}

}
