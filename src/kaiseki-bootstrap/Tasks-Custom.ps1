Task New-CustomNugetPackagesFromSpecFiles -depends Execute-MsBuild {
	$command = "pack"

    Write-Host "> Packing nuget packages with version number $AssemblyVersion"

    $nuspecFiles = Get-ChildItem *.nuspec -Recurse | ? {
        !($_.FullName.Contains("\packages\"))
    }

    foreach($nuspecFile in $nuspecFiles) {
        Write-Host "> Packing $($nuspecFile.FullName) with version $AssemblyVersion"
        &"$NugetBinPath" $command $nuspecFile.FullName -Version $AssemblyVersion
    }

    Write-Host "> Moving nuget packages to artefact path"
    Get-ChildItem -Path .\ -Filter *.nupkg | % {
        Copy-Item -Path $_.FullName -Destination $ArtefactPath
    }
}