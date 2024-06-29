<# Examples

# Maximum defaults
./Invoke-Generate.ps1

# Default project directory, release notes variant, and release notes path
$env:RELEASE_TAG_REF = 'v1.0.12'
./Invoke-Generate.ps1

# Default release notes variant and release notes path
$env:PROJECT_DIRECTORY = '/path/to/my-project'
$env:RELEASE_TAG_REF = 'v1.0.12'
./Invoke-Generate.ps1

# Default release notes path
$env:PROJECT_DIRECTORY = '/path/to/my-project'
$env:RELEASE_TAG_REF = 'v1.0.12'
$env:RELEASE_NOTES_VARIANT = 'Changes-HashSubject-NoMerges'
./Invoke-Generate.ps1

# Custom -ReleaseNotesPath relative to -ProjectDirectory
$env:PROJECT_DIRECTORY = '/path/to/my-project'
$env:RELEASE_TAG_REF = 'v1.0.12'
$env:RELEASE_NOTES_VARIANT = 'Changes-HashSubject-NoMerges'
$env:RELEASE_NOTES_PATH = '.release-notes.md'
./Invoke-Generate.ps1

# No defaults
$env:PROJECT_DIRECTORY = '/path/to/my-project'
$env:RELEASE_TAG_REF = 'v1.0.12'
$env:RELEASE_NOTES_VARIANT = 'Changes-HashSubject-NoMerges'
$env:RELEASE_NOTES_PATH = '/path/to/.release-notes.md'
./Invoke-Generate.ps1

#>
function Get-GenerateReleaseNotesConfig {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$Path
        ,
        [Parameter()]
        [string]$Ref
        ,
        [Parameter()]
        [ValidateSet(
            "Changes-HashSubject-Merges",
            "Changes-HashSubject-NoMerges-Categorized",
            "Changes-HashSubject-NoMerges-CategorizedSorted",
            "Changes-HashSubject-NoMerges",
            "Changes-HashSubject",
            "Changes-HashSubjectAuthor-NoMerges-Categorized",
            "Changes-HashSubjectAuthor-NoMerges-CategorizedSorted",
            "VersionDate-HashSubject-Merges",
            "VersionDate-HashSubject-NoMerges-Categorized",
            "VersionDate-HashSubject-NoMerges-CategorizedSorted",
            "VersionDate-HashSubject-NoMerges",
            "VersionDate-HashSubject",
            "VersionDate-HashSubjectAuthor-NoMerges-Categorized",
            "VersionDate-HashSubjectAuthor-NoMerges-CategorizedSorted",
            "VersionDate-Subject-Merges",
            "VersionDate-Subject-NoMerges-Categorized",
            "VersionDate-Subject-NoMerges-CategorizedSorted",
            "VersionDate-Subject-NoMerges",
            "VersionDate-Subject",
            "VersionDate-SubjectAuthor-NoMerges-Categorized",
            "VersionDate-SubjectAuthor-NoMerges-CategorizedSorted"
        )]
        [string]$Variant
        ,
        [Parameter()]
        [string]$ReleaseNotesPath
    )

    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'
    try {
        # Configuration: 1. Params 2. Env vars
        $projectDir = git rev-parse --show-toplevel
        $projectDir = & {
            if ($Path) {
                $Path
            }else {
                if ($env:PROJECT_DIRECTORY) {
                    "Using specified project directory '$env:PROJECT_DIRECTORY'" | Write-Verbose
                    $env:PROJECT_DIRECTORY
                }else {
                    $superProjectDir = git rev-parse --show-superproject-working-tree
                    if ($superProjectDir) {
                        $superProjectDir
                        "Using superproject directory '$superProjectDir'" | Write-Verbose
                    }else {
                        "Using default project directory '$projectDir'" | Write-Verbose
                        $projectDir
                    }
                }
            }
        }
        $private:generateArgs = [ordered]@{
            Path = $projectDir
            Ref = & {
                    if ($Ref) {
                        $Ref
                    }else {
                        if ($env:RELEASE_TAG_REF) {
                                "Using specified ref '$env:RELEASE_TAG_REF'" | Write-Verbose
                                $env:RELEASE_TAG_REF
                        }else {
                            "Using default ref 'HEAD'" | Write-Verbose
                            'HEAD'
                        }
                    }
            }
            Variant = & {
                if ($Variant) {
                    $Variant
                }else {
                    if ($env:RELEASE_NOTES_VARIANT) {
                            "Using specified release notes variant '$env:RELEASE_NOTES_VARIANT'" | Write-Verbose
                            $env:RELEASE_NOTES_VARIANT
                    }else {
                        "Using default release notes variant 'VersionDate-HashSubject-NoMerges-CategorizedSorted'" | Write-Verbose
                        'VersionDate-HashSubject-NoMerges-CategorizedSorted'
                    }
                }
            }
            ReleaseNotesPath = & {
                if ($ReleaseNotesPath) {
                    $ReleaseNotesPath
                }else {
                    if ($env:RELEASE_NOTES_PATH) {
                        "Using specified release notes path '$env:RELEASE_NOTES_PATH'" | Write-Verbose
                        if ([System.IO.Path]::IsPathRooted($env:RELEASE_NOTES_PATH)) { $env:RELEASE_NOTES_PATH }
                        else { "$projectDir/$env:RELEASE_NOTES_PATH" }
                    }else {
                        $private:defaultReleaseNotesPath = "$(git rev-parse --show-toplevel)/.release-notes.md"
                        "Using default release notes path '$private:defaultReleaseNotesPath'" | Write-Verbose
                        $private:defaultReleaseNotesPath
                    }
                }
            }
        }

        # Validation
        if (!$generateArgs['Path'] -or !(Test-Path -Path $generateArgs['Path'] -PathType Container)) {
            throw "Invalid -Path because it does not exist"
        }
        if (!$generateArgs['Ref']) {
            throw "Invalid -Ref"
        }
        if (!$generateArgs['Variant']) {
            throw "Invalid -Variant"
        }
        if (!$generateArgs['ReleaseNotesPath']) {
            throw "Invalid -ReleaseNotesPath"
        }

        $private:generateArgs
    }catch {
        throw
    }
}
