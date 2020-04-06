#Requires -PSEdition Core
#Requires -Version 6.0
###################################################################################################
###################################################################################################
##                                   FUNCTION Start-Compose                                      ##
###################################################################################################
###################################################################################################
function global:Start-Compose {
<#
.SYNOPSIS
    Starts a Docker-Compose instance and logs all execution activities into a log file

.DESCRIPTION
    Thie functions checks for the existance of the Docker-Compose file and then starts an
    instance of docker-compose.  In addition it logs all execution activity in to a log file
    "docker-compose[date.time].log"

.PARAMETER DockerComposeFile
    The docker-compose file

.INPUTS
    Yes...We do accept pipeline input

.OUTPUTS
    The docker-compose log file.  The file is appended for the duration of the 
    docker-compose instance

.EXAMPLE
    ------------------------------------------ Example 1 ------------------------------------------
    The example below starts docker-compose and logging execution events
    PS C:\> Start-Compose example.docker-compose.yml
    -----------------------------------------------------------------------------------------------

.NOTES
    Author: Dellius Alexander
    Last Edit: 2020-03-19
    Version 1.0 - process docker-compose file and log output
    Version 1.1 - updated instruction comments
#>
###################################################################################################
param ( ## Defined parameter DockerComposeFile
[CmdletBinding()]    
[Parameter( Mandatory=$true,
            Position=0,
            ParameterSetName='DockerComposeFile', 
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)]
[String]$DockerComposeFile)
###################################################################################################
$path = Get-Location
    try { ## Check is the compose file exists
        $exists = Test-Path $DockerComposeFile
        Start-Sleep -Seconds 2
    }
    catch { ## Exit and provide error message if error occurs while checking for compose file
        throw "Error: Parameter is null...`n`tCheck your input and try again`n`tExiting...`n"
        Exit-PSSession
        
    }
    
    if (!$exists) { ## check if docker-compose file exists
        "`nYou are missing $DockerComposeFile configuration file`n"
        "`nExiting...Now...Goodbye...`n"
        Start-Sleep -Seconds 2
        Exit-PSSession
    }
    else
    {  ## starts our services if docker-compose file exists
        
        try {
            $date = (Get-Date -Format "MM.dd.yy.HH.mm")
            $commandArgs = ("docker-compose -f $DockerComposeFile up -d; docker-compose -f $DockerComposeFile logs -f | Tee-Object 'logs\docker-compose-log\docker-compose_$date.log' -Append")

            $dc = Start-Process powershell.exe  -ArgumentList $commandArgs
            "`n`nExecuting $DockerComposeFile config file...`n"           
            Start-Sleep -Seconds 2
        }
        catch {            
                if ($dc.HasExited) {   ## if started successfully, we check for our log file
                    
                    ## checks if services/application containers not started successfully
                    "`nSomething went wrong...`n`nDocker is exiting... `n`nTying again...`n`n"
                    return $false
                }
            }
            $Global:DockerLogDirectory = "$path\docker-compose_$date.log"
        "`nSending Docker logs to $DockerLogDirectory`n"
        return $true
    }
}
###################################################################################################
###################################################################################################