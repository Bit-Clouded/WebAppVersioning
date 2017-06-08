param($installPath, $toolsPath, $package, $project) 

#dependancies
. "$PSScriptRoot\Shared-Methods.ps1"
. "$PSScriptRoot\VSCmdlets\Add-WppTarget.ps1"


#script root will be like this:  src\packages\BitClouded.WebAppVersioning.1.0.0.0\Tools\
$solutionFolder = "$PSScriptRoot\..\..\..\"

Print-Message -msg "Running          $PSCommandPath"


Print-Message -msg "Checking wpp targets" 
AddWpptarget-ForWebProjectsInSolution -solutionFolder $solutionFolder
Print-Message -msg "Finished checking wpp targets" 