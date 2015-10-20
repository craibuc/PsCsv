$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Sanitize" {


    It "Should convert spaces" {
        $value='testing one two three'
        $expected = 'testing-one-two-three'

        $actual = Sanitize($value) -Spaces
        $actual | Should Be $expected
    }

    It "Should convert illegal characters" {
        $value='\/:*?"<>|'
        $expected = '_________'

        $actual = Sanitize($value) -Illegals
        $actual | Should Be $expected
    }

    It "Accepts input from the pipeline" {
        $value='testing one two three'
        $expected = 'testing-one-two-three'

        $actual = $value | Sanitize -Spaces
        $actual | Should Be $expected
    }

}
