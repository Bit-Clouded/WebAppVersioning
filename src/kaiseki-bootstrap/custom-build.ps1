Write-Host "######################"
Write-Host "## Starting Kaiseki ##"
Write-Host "######################"
Write-Host

Write-Host "== Restoring packages =="
.".\.nuget\NuGet.exe" restore


function Is-Numeric ($Value) {
    return $Value -match "^[\d\.]+$"
}

#Ensures a valid AssemblyVersion is created when ran outside of Jenkins
$minorVersion = If (Is-Numeric($($env:BUILD_NUMBER))) { ($($env:BUILD_NUMBER)) } Else {0}


Write-Host "== Starting psake build =="
.\packages\psake.4.4.2\tools\psake.ps1 .\packages\Kaiseki.1.1.0\tools\Load-Modules.ps1 -properties @{
    "AssemblyVersion" = "1.0.2.$minorVersion"
} -taskList Clean,New-CiOutFolder,Transform-InjectBuildInfo,
    New-CustomNugetPackagesFromSpecFiles,Copy-KaisekiModules

Write-Host
Write-Host "######################"
Write-Host "## Kaiseki Finished ##"
Write-Host "######################"
