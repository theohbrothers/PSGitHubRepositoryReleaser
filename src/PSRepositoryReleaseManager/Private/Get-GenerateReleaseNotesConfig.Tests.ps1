$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Get-GenerateReleaseNotesConfig" -Tag 'Unit' {
    BeforeEach {
        $repo = "TestDrive:\repo"
        New-Item $repo -ItemType Directory

        $env:PROJECT_DIRECTORY = ''
        $env:RELEASE_TAG_REF = ''
        $env:RELEASE_NOTES_VARIANT = ''
        $env:RELEASE_NOTES_PATH = ''
        function git {
            param()
            if ($Args -and "$Args" -match 'rev-parse --show-toplevel') {
                $repo
            }
            if ($Args -and "$Args" -match 'rev-parse --show-superproject-working-tree') {
                $repo
            }
        }
    }
    AfterEach {
        Remove-Item $repo
        Remove-Item env:PROJECT_DIRECTORY -ErrorAction SilentlyContinue
        Remove-Item env:RELEASE_TAG_REF -ErrorAction SilentlyContinue
        Remove-Item env:RELEASE_NOTES_VARIANT -ErrorAction SilentlyContinue
        Remove-Item env:RELEASE_NOTES_PATH -ErrorAction SilentlyContinue
    }
    It 'Gets default config' {
        $c = Get-GenerateReleaseNotesConfig

        $c | Should -BeOfType [System.Collections.Specialized.OrderedDictionary]
        $c['Path'] | Should -Be $repo
        $c['Ref'] | Should -Be 'HEAD'
        $c['Variant'] | Should -Be 'VersionDate-HashSubject-NoMerges-CategorizedSorted'
        $c['ReleaseNotesPath'] | Should -Be "$repo/.release-notes.md"
    }
    It 'Gets config using params' {
        $params = @{
            Path = '.'
            Ref = 'v1.0.0'
            Variant = 'Changes-HashSubject-Merges'
            ReleaseNotesPath = '/my/release-notes.md'
        }
        $c = Get-GenerateReleaseNotesConfig @params

        $c | Should -BeOfType [System.Collections.Specialized.OrderedDictionary]
        $c.Keys | % {
            $c[$_] | Should -Be $params[$_]
        }
    }
    It 'Gets config using env vars' {
        $env:PROJECT_DIRECTORY = '.'
        $env:RELEASE_TAG_REF = 'v1.0.0'
        $env:RELEASE_NOTES_VARIANT = 'Changes-HashSubject-Merges'
        $env:RELEASE_NOTES_PATH = '/my/release-notes.md'

        $c = Get-GenerateReleaseNotesConfig

        $c | Should -BeOfType [System.Collections.Specialized.OrderedDictionary]
        $c['Path'] | Should -Be $env:PROJECT_DIRECTORY
        $c['Ref'] | Should -Be $env:RELEASE_TAG_REF
        $c['Variant'] | Should -Be $env:RELEASE_NOTES_VARIANT
        $c['ReleaseNotesPath'] | Should -Be $env:RELEASE_NOTES_PATH
    }
    It 'Gets config (params override env vars)' {
        $env:PROJECT_DIRECTORY = '.'
        $env:RELEASE_TAG_REF = 'v1.0.0'
        $env:RELEASE_NOTES_VARIANT = 'Changes-HashSubject-Merges'
        $env:RELEASE_NOTES_PATH = '/my/release-notes.md'
        $params = @{
            Path = '.'
            Ref = 'v1.0.1'
            Variant = 'Changes-HashSubject-NoMerges'
            ReleaseNotesPath = '/my/release-notes2.md'
        }

        $c = Get-GenerateReleaseNotesConfig @params

        $c | Should -BeOfType [System.Collections.Specialized.OrderedDictionary]
        $c.Keys | % {
            $c[$_] | Should -Be $params[$_]
        }
    }
}
