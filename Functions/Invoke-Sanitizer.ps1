<#
.SYNOPSIS
Remove unwanted or illegal characters from a string.

.DESCRIPTION
.PARAMETER $Spaces
Substitue space character with another character.

.PARAMETER $SpaceReplacement
The character to be substituted; default is a dash ('-').

.PARAMETER $Illegals
Substitue illegals characters (:, ?, /, \, |, *, <, >, ") with another character.

.PARAMETER $IllegalReplacement
The character to be substituted; default is underscore ('-').

.EXAMPLE
PS> Invoke-Sanitizer 'This is a test.' -Spaces
This-is-a-test.

Replaces spaces with a dash.

.EXAMPLE
PS> Invoke-Sanitizer 'This\is\a\test: a value' -Illegals
This_is_a_test_ a value.

Replaces illegal characters with an underscore.

PS> Invoke-Sanitizer 'This\is\a\test: a value' -Spaces -SpaceReplacement '@' -Illegals -IllegalReplacement '%'
'This%is%a%test%@a@value'

Replaces spaces and illegal characters with custom values.

#>
Function Invoke-Sanitizer {

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        $Value,
    
        [Alias('s')]
        [Switch] $Spaces,

        $SpaceReplacement='-',

        [Alias('i')]
        [Switch] $Illegals,

        $IllegalReplacment='_'
    )

    BEGIN {
        # build an alternaton regex pattern with the unwanted chars:
        $chars = ':', '?', '/', '\', '|', '*', '<', '>', '"'
        $pattern = [string]::join('|', ($chars | % {[regex]::escape($_)})) 
    }
    PROCESS {
        # replace spaces
        if($Spaces) {$Value=$Value.Replace(' ',$SpaceReplacement)}

        # replace illegal characters
        if($Illegals) {$Value=$Value -Replace $pattern, $IllegalReplacment}

        Write-Verbose "Value: $Value"
        $Value
    }
    END {}

}

Set-Alias sanitize Invoke-Sanitizer