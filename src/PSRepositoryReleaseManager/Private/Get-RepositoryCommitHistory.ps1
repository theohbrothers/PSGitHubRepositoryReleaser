function Get-RepositoryCommitHistory {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path -Path $_ -PathType Container})]
        [string]$Path
        ,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$FirstRef
        ,
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$SecondRef
        ,
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$PrettyFormat
        ,
        [Parameter(Mandatory=$false)]
        [switch]$Merges
        ,
        [Parameter(Mandatory=$false)]
        [string]$NoMerges
    )

    try {
        Push-Location $Path
        "Validating FirstRef '$FirstRef'" | Write-Verbose
        git rev-parse $FirstRef > $null
        if ($LASTEXITCODE) {
            throw "An error occurred."
        }
        if ($SecondRef) {
            "Validating SecondRef '$SecondRef'" | Write-Verbose
            git rev-parse $SecondRef > $null
            if ($LASTEXITCODE) {
                throw "An error occurred."
            }
        }
        if ($SecondRef) {
            $commitSHARange = "$($FirstRef)...$($SecondRef)"
        }else {
            "SecondRef unspecifed. The full commit history from FirstRef '$FirstRef' will be retrieved."  | Write-Verbose
            $commitSHARange = $FirstRef
        }
        $gitArgs = @(
            '--no-pager'
            'log'
            "--pretty=format:$($PrettyFormat)"
            $commitSHARange
            if ($Merges) { '--merges' }
            elseif ($NoMerges) { '--no-merges' }
        )
        $_commitHistory = git $gitArgs | Out-String
        "Changelog:" | Write-Verbose
        $_commitHistory | Out-String -Stream | Write-Verbose
        $_commitHistory
    }catch {
        Write-Error -Exception $_.Exception -Message $_.Exception.Message -Category $_.CategoryInfo.Category -TargetObject $_.TargetObject
    }finally {
        Pop-Location
    }
}
