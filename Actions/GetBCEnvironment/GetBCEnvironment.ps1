param (
    [Parameter(Mandatory = $true)]
    [string] $Provider,
    [Parameter(Mandatory = $true)]
    [string] $Project,
    [Parameter(Mandatory = $true)]
    [string] $BaseFolder
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2.0
$telemetryScope = $null
$bcContainerHelperPath = $null

# IMPORTANT: No code that can fail should be outside the try/catch

try {
    . (Join-Path -Path $PSScriptRoot -ChildPath "..\AL-Go-Helper.ps1" -Resolve)
    function Get-BCDockerCredentials {
        $NewBcContainerScript = { 
            Param(
            [Hashtable] $parameters
            ) 
            
            
            New-BcContainer @parameters
            Invoke-ScriptInBcContainer $parameters.ContainerName -scriptblock { $progressPreference = 'SilentlyContinue' } 
        }
        
        $randomName = @((65..90) + (97..122) | Get-Random -Count 5 | ForEach-Object { [char] $_ }) -join ''
        $randomUsername = @((65..90) + (97..122) | Get-Random -Count 5 | ForEach-Object { [char] $_ }) -join ''
        $randomPassword = @((65..90) + (97..122) | Get-Random -Count 10 | ForEach-Object { [char] $_ }) -join ''
        $containerName = "bc-$randomName"
        
        $credentials = (New-Object pscredential $randomUsername, (ConvertTo-SecureString -String $randomPassword -AsPlainText -Force))
        
        Write-Host "Creaing docker container"

        $repoSettings = ReadSettings -baseFolder $BaseFolder -project $Project

        $Parameters = @{
            "accept_eula" = $true
            "containerName" = $containerName
            "artifactUrl" = $($repoSettings.artifactUrl)
            "useGenericImage" = $useGenericImage
            "Credential" = $credential
            "auth" = 'UserPassword'
            "vsixFile" = $vsixFile
            "updateHosts" = $true
            "FilesOnly" = $false
        }
        
        $bcContainerHelperPath = DownloadAndImportBcContainerHelper -baseFolder $ENV:GITHUB_WORKSPACE
        Invoke-Command -ScriptBlock $NewBcContainerScript -ArgumentList $Parameters 

        return $credentials
    }
        
    $credentials = @{}
    switch ($Provider) {
        'BCDocker' { $credentials = Get-BCDockerCredentials }
        Default { throw "Provider $Provider not supported" }
    }


    $credentialsJSON = ConverTo-Json $credentials -Depth 99 -compress
    Add-Content -Path $env:GITHUB_OUTPUT -Value "CredentialsJSON=$credentialsJSON"
}
catch {
    OutputError -message "GetBCEnvironment action failed.$([environment]::Newline)Error: $($_.Exception.Message)$([environment]::Newline)Stacktrace: $($_.scriptStackTrace)"
    exit
}
finally {
    CleanupAfterBcContainerHelper -bcContainerHelperPath $bcContainerHelperPath
}