#Requires -PSEdition Core
#Requires -Version 6.0
###################################################################################################
###################################################################################################
##                                   FUNCTION Test-Directory                                     ##
###################################################################################################
###################################################################################################
function global:Test-Directory{
<#
.SYNOPSIS
    This function checks for the existance of the specified directory(s), creates the directory(s) 
    if they do not exist or are empty and returns a boolean response.

.DESCRIPTION
    We test for the existance of the given directory or an array of directories/PATH's as the 
    parameter input.  Creates the directory if it does not exist into the root the current shell 
    by default.  You may optionally specify a directory path container to check for and 
    create directory(s) if it does not exist

.PARAMETER WorkingDirectory
    The WorkingDirectory parameter is used to define a single object or an array of path objects.
    It may contain: absolute path, current directory, working directory, environment variable path,
    may be a single directory or a collection of directories.

.INPUTS
    Yes... I do accept pipeline input
    e.g. 

.OUTPUTS
    TRUE: successful execution
    FALSE: unsuccessful execution


.EXAMPLE
    Test-Directory -WorkingDirectory "testdir"

.EXAMPLE
    Test-Directory -WorkingDirectory ("testdir","mypics","helpFiles")
    
.EXAMPLE
    $Directories = @("testdir","mypics","docs","index.log")
    Test-Directory $Directories

.NOTES
    Author: Dellius Alexander
    Last Edit: 2020-03-19
    Version 1.0 - check for directory, create directory
    Version 1.1 - accept pipeline input, added handling for array of directories
#>
###################################################################################################
[CmdletBinding()]
param (   
    [Parameter( Mandatory, 
                Position=0, 
                ParameterSetName="WorkingDirectory", 
                ValueFromPipeline=$true,
                ValueFromPipelineByPropertyName=$true,
                HelpMessage="Enter a directory path(s); a single object or an array of objects")]
    [ValidateNotNullOrEmpty()]
    [System.Object[]]
    $WorkingDirectory)
###################################################################################################
    try {
            foreach ($item in  $WorkingDirectory) 
            {   ## For each directory run the below test      
                $item = ($item.Contains("_") ? $item.Split("_")[0]: $item)
                if ((Test-Path "*$item*" -PathType Container -Include "**")) 
                {   ## If directory exist we check its contents
                    "`n$item exists...`n"
                    $cnt = (Get-ChildItem "$item*/**").count 
                    if($cnt -eq 0)
                    {   ## If the directory is empty we will delete it and start fresh
                        Remove-Item "$item*" -Recurse -Force -Include "**"
                        Start-Sleep -Seconds 1
                        New-Item -Path $item -ItemType Directory 
                        Start-Sleep -Seconds 1
                    } ## Else we do nothing      
                }else{  ## If the files or directory does not exist then we create them
                        "`nDirectory [ $item ] does not exist...`n`nCreating [ $item ] directory...`n"
                        New-Item -Path $item -ItemType Directory 
                        Start-Sleep -Seconds 1              
                }        
            }       
        }
        catch {
            "`nSomething went wrong`n`nUnable to create directory`n"
            return $false
        }  
        return $true 
}
###################################################################################################
###################################################################################################