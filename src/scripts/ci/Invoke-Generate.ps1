[CmdletBinding()]
param()

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

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ErrorView = 'NormalView'
$VerbosePreference = 'Continue'

try {
    Push-Location $PSScriptRoot
    Import-Module "$(git rev-parse --show-toplevel)\src\PSRepositoryReleaseManager\PSRepositoryReleaseManager.psm1" -Force

    # Generate release notes
    if ($env:PROJECT_DIRECTORY) {
        $private:ProjectDir = $env:PROJECT_DIRECTORY
    }else {
        $private:superProjectDir = git rev-parse --show-superproject-working-tree
        if ($private:superProjectDir) {
            $private:ProjectDir = $private:superProjectDir
            "Using superproject path '$private:ProjectDir'" | Write-Verbose
        }else {
            throw "`$env:PROJECT_DIRECTORY is undefined or superproject directory cannot be determined." | Write-Verbose
        }
    }
    $private:generateArgs = @{
        Path = $private:ProjectDir
        TagName = if ($env:RELEASE_TAG_REF) {
                      $env:RELEASE_TAG_REF
                  }else {
                      "`$env:RELEASE_TAG_REF is null or undefined. Using the default ref 'HEAD'" | Write-Verbose
                      'HEAD'
                  }
        Variant = if ($env:RELEASE_NOTES_VARIANT) { $env:RELEASE_NOTES_VARIANT } else { 'VersionDate-HashSubjectAuthor-NoMerges-Categorized' }
        ReleaseNotesPath = if ($env:RELEASE_NOTES_PATH) {
                               "Using specified release notes path '$env:RELEASE_NOTES_PATH'" | Write-Verbose
                               if ([System.IO.Path]::IsPathRooted($env:RELEASE_NOTES_PATH)) { $env:RELEASE_NOTES_PATH }
                               else { "$private:ProjectDir/$env:RELEASE_NOTES_PATH" }
                           }else {
                               $private:defaultReleaseNotesPath = "$(git rev-parse --show-toplevel)/.release-notes.md"
                               "Using the default release notes path '$private:defaultReleaseNotesPath'" | Write-Verbose
                               $private:defaultReleaseNotesPath
                           }
    }
    Generate-ReleaseNotes @private:generateArgs

}catch {
    throw
}finally {
    Pop-Location
}
