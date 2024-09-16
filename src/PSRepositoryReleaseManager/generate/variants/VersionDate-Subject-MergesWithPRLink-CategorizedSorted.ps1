function VersionDate-Subject-MergesWithPRLink-CategorizedSorted {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path -Path $_ -PathType Container})]
        [string]$Path
        ,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Ref
    )

    $ErrorActionPreference = 'Stop'

    try {
        $previousRelease = Get-RepositoryReleasePrevious -Path $Path -Ref $Ref -ErrorAction SilentlyContinue
        $funcArgs = @{
            Path = $Path
            FirstRef = $Ref
            PrettyFormat = '%h %B'
            Merges = $true
        }
        if ($previousRelease) { $funcArgs['SecondRef'] = @($previousRelease)[0] }
        $lines = @( Get-RepositoryCommitHistory @funcArgs )
        $commitHistoryCollection = & {
            $next = $false
            foreach ($l in $lines) {
                if ($l -match '^[a-z0-9]{7}') {
                    $c = [System.Collections.ArrayList]@($l)
                }else {
                    if ($l -match '^\s*$') {
                        $next = $true
                        continue
                    }
                    if ($next) {
                        $next = $false
                        $prNum = if ($c[0] -match 'Merge pull request #(\d+) from') { $matches[1] } else { 0 }
                        "$l (#$prNum)"
                    }
                }
            }
        }
        $commitHistoryCategory = @(
            @{
                Title = 'Breaking'
                Name = @(
                    'Breaking'
                    'breaking-change'
                )
            }
            @{
                Title = 'Features'
                Name = @(
                    'Feature'
                    'feat'
                )
            }
            @{
                Title = 'Enhancements'
                Name = @(
                    'Enhancement'
                )
            }
            @{
                Title = 'Performance'
                Name = @(
                    'Performance'
                    'perf'
                )
            }
            @{
                Title = 'Change'
                Name = @(
                    'Change'
                )
            }
            @{
                Title = 'Refactors'
                Name = @(
                    'Refactor'
                )
            }
            @{
                Title = 'Build'
                Name = @(
                    'Build'
                )
            }
            @{
                Title = 'CI'
                Name = @(
                    'CI'
                )
            }
            @{
                Title = 'Tests'
                Name = @(
                    'Test'
                )
            }
            @{
                Title = 'Fixes'
                Name = @(
                    'Fix'
                )
            }
            @{
                Title = 'Style'
                Name = @(
                    'Style'
                )
            }
            @{
                Title = 'Documentation'
                Name = @(
                    'Docs'
                )
            }
            @{
                Title = 'Chore'
                Name = @(
                    'Chore'
                )
            }
        )
        $commitHistoryCategoryNone = @{
            Title = 'Others'
        }
        $commitHistoryCategorizedCollection = New-Object System.Collections.ArrayList
        $commitHistoryUncategorizedCollection = New-Object System.Collections.ArrayList
        $commitHistoryCollection | % {
            if ($_ -match "^(\s*[a-zA-Z0-9_\-]+\s*)(\(\s*[a-zA-Z0-9_\-\/]+\s*\)\s*)*:(.+)") {
                $commitHistoryCategorizedCollection.Add($_) > $null
            }else {
                $commitHistoryUncategorizedCollection.Add($_) > $null
            }
        }
        $commitHistoryCategorizedCustomCollection = $commitHistoryCategorizedCollection | % {
            $matchInfo = $_ | Select-String -Pattern "^(.+)"
            if ($matchInfo) {
                [PSCustomObject]@{
                    Subject = $matchInfo.Matches.Groups[1].Value
                }
            }
        }
        $commitHistoryUncategorizedCustomCollection = $commitHistoryUncategorizedCollection | % {
            $matchInfo = $_ | Select-String -Pattern "^(.+)"
            if ($matchInfo) {
                [PSCustomObject]@{
                    Subject = $matchInfo.Matches.Groups[1].Value
                }
            }
        }
        $releaseBody = & {
@"
## $Ref ($(Get-Date -UFormat '%Y-%m-%d'))
"@
            foreach ($c in $commitHistoryCategory) {
                $iscommitHistoryCategoryTitleOutputted = $false
                $commitHistoryCategorizedCustomCollection | Sort-Object -Property Subject -CaseSensitive | % {
                    foreach ($n in $c['Name']) {
                        if ("$($_.Subject)" -match "^(\s*$n\s*)(\(\s*[a-zA-Z0-9_\-\/]+\s*\)\s*)*:(.+)") {
                            if (!$iscommitHistoryCategoryTitleOutputted) {
@"

### $($c['Title'])

"@
                                $iscommitHistoryCategoryTitleOutputted = $true
                            }
@"
* $($_.Subject)
"@
                            break
                        }
                    }
                }
            }
            if ($commitHistoryUncategorizedCustomCollection) {
@"

### $($commitHistoryCategoryNone['Title'])

"@
                $commitHistoryUncategorizedCustomCollection | Sort-Object -Property Subject -CaseSensitive | % {
@"
* $($_.Subject)
"@
                }
            }
        }
        $releaseBody
    }catch {
        Write-Error -Exception $_.Exception -Message $_.Exception.Message -Category $_.CategoryInfo.Category -TargetObject $_.TargetObject
    }
}
