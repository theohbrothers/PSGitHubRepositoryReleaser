$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Generate-ReleaseNotes" -Tag 'Unit' {
    BeforeEach {
        function Get-GenerateReleaseNotesConfig {
            @{
                Path = '.'
                Ref = 'HEAD'
                Variant = 'Some-Variant'
                ReleaseNotesPath = "TestDrive:\some-release-notes.md"
            }
        }
        function Some-Variant {}
        Mock Some-Variant {
            'Some release notes content'
        }
    }
    It 'Generates release notes' {
        Generate-ReleaseNotes

        Get-Item "TestDrive:\some-release-notes.md" | Should -BeOfType [System.IO.FileInfo]
    }
}
