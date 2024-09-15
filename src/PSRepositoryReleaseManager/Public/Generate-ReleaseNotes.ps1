function Generate-ReleaseNotes {
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
    process {
        $c = Get-GenerateReleaseNotesConfig @PSBoundParameters
        try {
            "Generating release notes of variant '$( $c['Variant'] )'" | Write-Verbose
            $params = @{
                Path = $c['Path']
                Ref = $c['Ref']
            }
            $releaseNotesContent = & $c['Variant'] @params -ErrorAction Stop
            if (!(Test-Path -Path ($c['ReleaseNotesPath'] | Split-Path -Parent))) {
                New-Item -Path ($c['ReleaseNotesPath'] | Split-Path -Parent) -ItemType Directory
            }
            $releaseNotesContent | Out-File -FilePath $c['ReleaseNotesPath'] -Encoding utf8
            "Release notes generated at the path '$( $c['ReleaseNotesPath'] )'" | Write-Verbose
            $c['ReleaseNotesPath']
        }catch {
            Write-Error -Exception $_.Exception -Message $_.Exception.Message -Category $_.CategoryInfo.Category -TargetObject $_.TargetObject
        }
    }
}
