function Upload-GitHubReleaseAsset {
    [CmdletBinding(DefaultParameterSetName='Path')]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$UploadUrl
        ,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({Test-Path -Path $_ -PathType Leaf})]
        [string[]]$Assets
        ,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$ApiKey
    )

    $ErrorActionPreference = 'Stop'
    $VerbosePreference = 'Continue'
    Set-StrictMode -Version Latest

    try {
        Push-Location $PSScriptRoot
        Import-Module "$(git rev-parse --show-toplevel)\lib\PSGitHubRestApi\src\PSGitHubRestApi\PSGitHubRestApi.psm1" -Force -Verbose

        # Create release assets
        $private:releaseAssetArgs = [Ordered]@{}
        if ($PSBoundParameters['UploadUrl']) { $private:releaseAssetArgs['UploadUrl'] = $PSBoundParameters['UploadUrl'] }
        if ($PSBoundParameters['ApiKey']) { $private:releaseAssetArgs['ApiKey'] = $PSBoundParameters['ApiKey'] }
        foreach ($a in $PSBoundParameters['Assets']) {
            $private:releaseAssetArgs['Asset'] = Get-Item -Path $a | Select-Object -ExpandProperty FullName
            "Uploading release asset '$a':" | Write-Verbose
            $response = New-GitHubRepositoryReleaseAsset @private:releaseAssetArgs
            $responseContent = $response.Content | ConvertFrom-Json
            "Response:" | Write-Verbose
            $responseContent | Out-String -Stream | % { $_.Trim() } | ? { $_ } | Write-Verbose
            $response
        }

    }catch {
        throw
    }finally {
        Pop-Location
    }
}
