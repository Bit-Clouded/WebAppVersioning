#dependancies
. "$PSScriptRoot\..\Versioning.ps1"
. "$PSScriptRoot\..\Shared-Methods.ps1"

 function AddCustomFileNodeToXml($pattern, $includeFolder, $xmlContents, $xmlFilePath)
 {
      $nodeName = "CustomFilesToInclude"
      $newNode = $xmlContents.CreateElement($nodeName, $xmlContents.Project.NamespaceURI);
      $newNode.SetAttribute("Include", $pattern);
      
      $innerNodeName="Dir"
      $innerNode = $xmlContents.CreateElement($innerNodeName, $xmlContents.Project.NamespaceURI);  
      $innerNode.InnerText = $includeFolder
      
      $newNode.AppendChild($innerNode)
      $newNode.RemoveAttribute("xmlns");
      $xmlContents.Project.ItemGroup.AppendChild($newNode);
      
      $xmlContents.Save($xmlFilePath);
 }

 function CheckWppTargets($wppTargetFile, $includeFolder)
 {

    [xml]$xml = Get-Content -Path $wppTargetFile
    [bool] $found = $false
    $pattern = ".\$includeFolder\**\*"


    foreach ($customFilePattern in $xml.Project.ItemGroup.CustomFilesToInclude) {
        if ($customFilePattern.Include.ToString() -eq $pattern)
        {
            $found = $true
            break
         }  
    }

    if (!$found)
    {
        print-message -msg "Adding $includeFolder to $wppTargetFile"
        AddCustomFileNodeToXml -pattern $pattern -includeFolder $includeFolder -xmlContents $xml -xmlFilePath $wppTargetFile
    }
    else
    {
        print-message -msg "$includeFolder file inclusion already exists in $wppTargetFile"
    }
 }

 function AddWpptarget-ForWebProjectsInSolution($soloutionFolder, $includeFolder ="diagnostics")
 {
    
    $wppTargets = New-Object System.Collections.ArrayList
	
	(Find-WebProjects -parentDirectory $solutionFolder) | %{ 
		(Find-WppTargetsFiles -parentDirectory $_) | %{
			$wppTargets.Add($_) > $null 
		} 
	}
		
    if ($wppTargets.Count -eq 0)
    {
        write-warning "No suitable projects found in this soloution"
        Write-Warning "Suitable projects will have a web.config and a *wpp.targets file" 
        write-warning "In the top level of the project folder"
    }

    foreach ($file in $wppTargets) 
    {  
        CheckWppTargets -wppTargetFile $file -includeFolder $includeFolder
    }
 }