#Requires -PSEdition Core
#Requires -Version 6.0
###################################################################################################
###################################################################################################
##                                   FUNCTION Get-Download                                       ##
###################################################################################################
###################################################################################################
function global:Get-Download {

<#
.SYNOPSIS
    Downloads an URL/Object to the current directory or a specified path location

.DESCRIPTION
    The function accepts URL/Object to be downloaded into the current directory or
    a user specified directory.

.PARAMETER URL
    The URL parameter is used to define the objects address location; the URL specifies a 
    website, page, or file on the Internet

.PARAMETER PATH
    The [OPTIONAL] PATH parameter provides a PATH destination for your downloaded 
    object; default download location is the current directory of the executing script

.INPUTS
    Yes... I do accept pipeline input URL/URI
    e.g. 

.OUTPUTS 
    The LOCAL downloaded { PATH + Object name }  object location
    e.g. C:\User\Delli\test.log

.EXAMPLE
       
    PS C:\> Get-Download "https://www.gnu.org/manual/manual.html"

.EXAMPLE
    PS C:\> Get-Download -url "https://www.gnu.org/manual/manual.html" -path "C:\User\Username"

.EXAMPLE
    PS C:\>  Get-Download "https://ss64.com/ps/syntax-scopes.html" "$HOME\Desktop"     

.NOTES
    Author: Dellius Alexander
    Last Edit: 2020-03-19
    Version 1.0 - download single object
    Version 1.1 - download to a spacified PATH & added pipeline input
#>
###################################################################################################
# Specifies a path to one locations.
[CmdletBinding()]
param (
    [Parameter(Mandatory=$true,
    Position=0,
    ParameterSetName="url",
    ValueFromPipeline=$true,
    ValueFromPipelineByPropertyName=$true,
    HelpMessage="Path to URL.")]
    [ValidateNotNullOrEmpty()]
    [string]
    $url,

    [Parameter( Mandatory=$false,
                Position=1,
                ValueFromPipeline=$false)]
    [System.Object]
    $path=$null)
###################################################################################################
$obj = @("\","/") ## path separator to search for in $url
if ($null -eq $path)
{ ## if $path is $null
    $path = Get-Location
    foreach ($sym in $obj) 
    { ## check if the separator appears in $url
        $cnt = 0
        $content = ""        
        $cnt = $url.split($sym).Count       
        if ($cnt -lt 2) { ## if no slash does not appear in the $url then count is 0, 
            continue      ## and we continue to test for the next separator in the $url
        }else{ ## now if the separator does appear and we split the object and return its quantity
            
            $content = $($url.Split($sym)[($cnt-1)])
            if($content -ne "") { 
                ## we use the objects count to get the last object in the array returned and 
                ## assign it to $content; now we use the leaf object to build our $path                    
                $path = "$path\$content"
                try { ## now we use our $path as our download destination directory and filename
                    (New-Object System.Net.WebClient).DownloadFile($url,$path)
                }
                catch { ## display error if something goes wrong
                    return $false
                }                   
            }
            else{ ## the $url specified is wrong or $null
                throw ("`nThe URL provided has incorrect format: $url`n`n",
                "`nPlease provide a correct URL and try again...`n")
                Exit-PSHostProcess

            }    
        }         
    } ## End of foreach      
}
else { ## and if $path is not $null or it is the absolute path then download object into the specified path 
    foreach ($sym in $obj) 
    {    ## check if the separator appears in $url
        $cnt = 0
        $content = ""
        $cnt = ($url.split($sym)).Count
        if ($cnt -lt 2) { ## if the does not appear in the $url then count is 0, 
            continue      ## and we continue to test for the next separator in the $url
        }else{ ## now if the separator does appear and we split the object and return its quantity   
                $content = $($url.Split($sym)[($cnt-1)])
                if($content -ne "" ) { 
                    ## we use the objects count to get the last object in the array returned and 
                    ## assign it to $content; now we use the leaf object to build our $path                    
                    $path = "$path\$content"
                    (New-Object System.Net.WebClient).DownloadFile($url,$path)
                }                
                else {
                "`nDefault path is the current directory`n"
                "`nPath parameter must be an absolute path`n"
                Exit-PSHostProcess
                }   
        }              
    }     
}
return $path
}
###################################################################################################
###################################################################################################