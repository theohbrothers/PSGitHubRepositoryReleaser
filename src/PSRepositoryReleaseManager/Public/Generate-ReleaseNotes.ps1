function Generate-ReleaseNotes {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path -Path $_ -PathType Container})]
        [string]$Path
        ,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Ref
        ,
        [Parameter(Mandatory=$true)]
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
            "VersionDate-Subject-MergesWithPRLink-CategorizedSorted",
            "VersionDate-Subject-NoMerges-Categorized",
            "VersionDate-Subject-NoMerges-CategorizedSorted",
            "VersionDate-Subject-NoMerges",
            "VersionDate-Subject",
            "VersionDate-SubjectAuthor-NoMerges-Categorized",
            "VersionDate-SubjectAuthor-NoMerges-CategorizedSorted"
        )]
        [string]$Variant
        ,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$ReleaseNotesPath
    )

    try {
        $private:generateArgs = @{
            Path = $Path
            Ref = $Ref
        }
        "Generating release notes of variant '$($Variant)'" | Write-Verbose
        $releaseNotesContent = & $Variant @private:generateArgs -ErrorAction Stop
        if (!(Test-Path -Path ($ReleaseNotesPath | Split-Path))) {
            New-Item -Path ($ReleaseNotesPath | Split-Path) -ItemType Directory
        }
        $releaseNotesContent | Out-File -FilePath $ReleaseNotesPath -Encoding utf8
        "Release notes generated at the path '$ReleaseNotesPath'" | Write-Verbose
        $ReleaseNotesPath
    }catch {
        Write-Error -Exception $_.Exception -Message $_.Exception.Message -Category $_.CategoryInfo.Category -TargetObject $_.TargetObject
    }
}
