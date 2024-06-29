Describe "PSRepositoryReleaseManager" -Tag 'Integration' {
    BeforeAll {
        $ErrorView = 'NormalView'
        Import-Module $PSScriptRoot -Force 3>$null
    }
    BeforeEach {
        $env:PROJECT_DIRECTORY = $null
        $env:RELEASE_TAG_REF = $null
        $env:RELEASE_NOTES_VARIANT = $null
        $env:RELEASE_NOTES_PATH = $null
    }
    AfterEach {
    }
    It "Runs Invoke-Generate.ps1" {
        $stdout = Generate-ReleaseNotes
        "Generate notes content:" | Write-Verbose
        Get-Content -Path "$stdout" | Write-Host
    }
    It "Runs Invoke-Generate.ps1 with `$env:PROJECT_DIRECTORY" {
        $env:PROJECT_DIRECTORY = git rev-parse --show-toplevel

        $stdout = Generate-ReleaseNotes
        "Generate notes content:" | Write-Verbose
        Get-Content -Path "$stdout" | Write-Host
    }
    It "Runs Invoke-Generate.ps1 with `$env:RELEASE_TAG_REF='HEAD'" {
        $env:RELEASE_TAG_REF = 'HEAD'

        $stdout = Generate-ReleaseNotes
        "Generate notes content:" | Write-Verbose
        Get-Content -Path "$stdout" | Write-Host
    }
    It "Runs Invoke-Generate.ps1 with `$env:RELEASE_TAG_REF='branch'" {
        $env:RELEASE_TAG_REF = 'master'
        git checkout -b master HEAD

        $stdout = Generate-ReleaseNotes
        "Generate notes content:" | Write-Verbose
        Get-Content -Path "$stdout" | Write-Host
    }
    It "Runs Invoke-Generate.ps1 with `$env:RELEASE_TAG_REF='vx.x.x'" {
        $env:RELEASE_TAG_REF = git describe --tags --abbrev=0

        $stdout = Generate-ReleaseNotes
        "Generate notes content:" | Write-Verbose
        Get-Content -Path "$stdout" | Write-Host
    }
    It "Runs Invoke-Generate.ps1 with `$env:RELEASE_TAG_REF='remote/branch'" {
        $env:RELEASE_TAG_REF = 'origin/master'

        $stdout = Generate-ReleaseNotes
        "Generate notes content:" | Write-Verbose
        Get-Content -Path "$stdout" | Write-Host
    }
    It "Runs Invoke-Generate.ps1 with `$env:RELEASE_TAG_REF='commit-hash'" {
        $env:RELEASE_TAG_REF = git rev-parse HEAD

        $stdout = Generate-ReleaseNotes
        "Generate notes content:" | Write-Verbose
        Get-Content -Path "$stdout" | Write-Host
    }
    It "Runs Invoke-Generate.ps1 with `$env:RELEASE_NOTES_VARIANT='Changes-HashSubject-NoMerges'" {
        $env:RELEASE_NOTES_VARIANT = 'Changes-HashSubject-NoMerges'

        $stdout = Generate-ReleaseNotes
        "Generate notes content:" | Write-Verbose
        Get-Content -Path "$stdout" | Write-Host
    }
    It "Runs Invoke-Generate.ps1 with `$env:RELEASE_NOTES_PATH='.release-notes.md'" {
        $env:RELEASE_NOTES_PATH = ".release-notes.relativepath.md"

        $stdout = Generate-ReleaseNotes
        "Generate notes content:" | Write-Verbose
        Get-Content -Path "$stdout" | Write-Host
    }
    It "Runs Invoke-Generate.ps1 with `$env:RELEASE_NOTES_PATH='/path/to/.release-notes.md'" {
        $env:RELEASE_NOTES_PATH = "$(git rev-parse --show-toplevel)/.release-notes.fullpath.md"

        $stdout = Generate-ReleaseNotes
        "Generate notes content:" | Write-Verbose
        Get-Content -Path "$stdout" | Write-Host
    }
    It "Runs Invoke-Generate.ps1 with `$env:RELEASE_NOTES_VARIANT `$env:RELEASE_NOTES_PATH (all variants)" {
        $ReleaseNotesVariant = Get-ChildItem "$PSScriptRoot/generate/variants" | % { $_.BaseName }
        "Release notes variants:" | Write-Verbose
        $ReleaseNotesVariant | Write-Host

        foreach ($variant in $ReleaseNotesVariant) {
            $env:RELEASE_NOTES_VARIANT = $variant
            $env:RELEASE_NOTES_PATH = "$(git rev-parse --show-toplevel)/.release-notes.$variant.md"

            $stdout = Generate-ReleaseNotes
            "Generate notes content:" | Write-Verbose
            Get-Content -Path "$stdout" | Write-Host
        }
    }
}
