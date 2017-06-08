#dependancies
. "$PSScriptRoot\Shared-Methods.ps1"

 function Find-WebProjects($parentDirectory)
 {
    Print-Message -msg "Searching for Web Project folders in $parentDirectory"
    $files = New-Object System.Collections.ArrayList
	
	if (![string]::IsNullOrEmpty($parentDirectory))
	{
		dir $parentDirectory | where {
		# returns true if $_ is a container (i.e. a folder)
		$_.psiscontainer 
		} | where { 
				!($_.Name -match "Tests$")
		}  | where {
			# test for existence of web.config
			(test-path (join-path $_.fullname "web.config"))
		} | foreach {
			$files.Add($_.FullName) > $null      
		}
	}	
    return $files
}

function Find-WppTargetsFiles($parentDirectory)
{
	Print-Message -msg "Searching for Wpp Targets files in $parentDirectory"
	$files = New-Object System.Collections.ArrayList
	
	if (![string]::IsNullOrEmpty($parentDirectory))
	{

		dir $parentDirectory | where {
			#check files not folders
			($_.psiscontainer -eq $false) } | where  {
              $_.Name -match "wpp.targets$"  
              } | foreach {
					$files.Add($_.FullName) > $null            
              }
    }      	
	return $files;
}

function Add-VersionDotTxt
{
    Print-Message -msg "Creating version.txt"
    
    #script root will be like this:  src\packages\BitClouded.WebAppVersioning.#.#.#.#\Tools (runs from packages not CiArtefacts)
    $solutionFolder = "$PSScriptRoot\..\..\..\"

	$webProjects = Find-WebProjects -parentDirectory $solutionFolder
		
    if ($webProjects.Count -eq 0)
    {
        write-warning "No suitable projects found in this soloution"
        Write-Warning "Suitable projects will have a web.config and a *wpp.targets file" 
        write-warning "In the top level of the project folder"
    }
  
    foreach ($folder in $webProjects) 
    {
       $versionFile = "$folder\Diagnostics\version.txt"
       # Jenkins: 
	   #$theBuildNumber = $env:BUILD_NUMBER
	   $theBuildCounter = ${env.GO_PIPELINE_COUNTER}
	   $theBuildLabel = ${env.GO_PIPELINE_LABEL}
	   
       $theBranch = $env:GIT_BRANCH
       $commitHash =git rev-list --max-count=1 HEAD
       $dateTime = get-date


       new-item -force -path $versionFile -type file
              
       Add-Content $versionFile "Build Counter: $theBuildCounter `n"
	   Add-Content $versionFile "Build Label: $theBuildLabel `n"
       Add-Content $versionFile "Branch: $theBranch `n"
       Add-Content $versionFile "Hash: $commitHash `n"
       Add-Content $versionFile "Built: $dateTime `n"

    }
}
