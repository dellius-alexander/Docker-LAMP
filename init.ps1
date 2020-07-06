#Requires -PSEdition Core
#Requires -Version 6.0

# We initialize our functions so we can use then in the current running script
 .\PS-Functions\Get-Download.ps1
 .\PS-Functions\Test-Directory.ps1
 .\PS-Functions\Start-Compose.ps1
###################################################################################################
###################################################################################################
##                                   Variable Declarations                                       ##
###################################################################################################
###################################################################################################
#------------------- Enter Your Configuration File Names Below -----------------------------------#
#-------------------------------------------------------------------------------------------------#
# Enter the name of your docker-compose file below
$global:DockerComposeFile = "lamp.docker-compose.yml"

# Directory structure of your application ROOT
$global:DIR = @{
    ROOT = @(
        "assets",
        "assets\mysql-ssl",
        "assets\php-mycnf",
        "assets\php-ssl", 
        "assets\ssl",
        "assets\php-mycnf\conf.d",
        "Dockerfile",
        "logs",
        "logs\docker-compose-log",
        "logs\mysql-log",
        "logs\www-log",
        "mysql",
        "PS-Functions",
        "www",
        "www\assets",
        "www\assets\manual",
        "www\assets\php.ext",
        "www\config",
        "www\config\yaml",
        "www\public",
        "www\public\css",
        "www\public\images",
        "www\public\media",
        "www\public\scripts",
        "www\src",
        "www\src\backup",
        "www\src\class",
        "www\src\includes",
        "www\stats",
        "www\tmp",
        "www\vendor",
        "www\vendor\bin",
        "www\vendor\composer",
        "www\vendor\container",
        "www\vendor\doctrine",
        "www\vendor\ocramius",
        "www\vendor\symfony"
)}

# Current PATH of executing script:
$global:PATH = Get-Location

#-------------------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------------------#
###################################################################################################
###################################################################################################

###################################################################################################
                                <# Introduction Website #>
###################################################################################################
###################################################################################################
$global:intro_site = @{lamp_intro = '<html>
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>You Are Worthy</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" type="text/css" media="screen" href="#">
    <script src="#"></script>
    <style>
        .container{
            margin: 0 auto;
            width: 60%;
            font-size: 1.5em;
        }
        .info-box{
            margin: 0 auto;
            width: 100%;
            background-color: #d5dbdbd8;
            padding-left: 10px;
            padding-right: 10px;
            padding-top: 10px;
            padding-bottom: 10px;
            border-radius: 15px;
        }
    </style>
</head>
<nav class="nav" id="nav">
</nav>
<body class="body" id="body">
    <div class="container" id="container">
        <div class="intro">
            <h2> Welcome to your LAMP Environment via Docker-Compose!<br/>
            Access your resources below.</h2>
        </div>
        <div class="info-box">
        <p> PHP:</p>
        <ul>
            <li>PHP Webserver Select Here => <a href="http://localhost:55001" target="_blank">http://localhost:55001</a></li>
            <li>The document to route where your php files will be located is where you launched this service from...</li>
            <li>The root directory for your project root is located at: <br/><hr/><strong>'+($PATH)+'\www</strong><hr/>  You will place your project documents here.</li>
        </ul>
        </div>
        <hr/>
        <div class="info-box">
            Adminer: Select Here => <a href="http://localhost:55002" target="_blank">http://localhost:55002</a><br/><br/>
            Adminer (formerly phpMinAdmin) is a full-featured database management tool written in PHP. 
            Conversely to phpMyAdmin, it consist of a single file ready to deploy to the target server. 
            Adminer is available for MySQL, MariaDB, PostgreSQL, SQLite, MS SQL, Oracle, Firebird, SimpleDB, Elasticsearch and MongoDB.
        </div>
        <hr/>
        <div class="info-box">
            MySQL: <ul><li>Host: 172.16.238.9</li><li> Port: 55003 & 55060 (Management port); optional inner domain port 3306</li></ul>
        </div>              
    </div>
</body>
</html>'}
###################################################################################################
###################################################################################################
###################################################################################################
                                <#  Start of Script Execution #>
###################################################################################################
###################################################################################################
###################################################################################################


try { # check to make sure our directories are in tact
    Test-Directory  $DIR['ROOT']
}
catch {
    throw "`nSomething went wrong testing you directory...`n" 
} 
stop 
try { # executing docker compose file
    (Start-Compose $DockerComposeFile)
}
catch {
    throw "`nTheir was an error executing your compose file"
}
Start-Sleep -Seconds 3
# Create web page and open window with help content
Test-Directory -WorkingDirectory "www\config"
Start-Sleep -Seconds 3
$intro_site['lamp_intro'] > "$PATH\www\config\intro.html" 
Start-Process chrome.exe http://localhost:55001/config/intro.html
Clear-Host # Now lets clear the screen
$displayMessage = $("`n`n`n############################################## HELP CONTEXT ##############################################`n"
                    "`n+--------------------------------------------------------------------------------------------------------+`n"
                    " Access you resources using the web browser:`n`n"
                    "`n`tAdminer:               http://localhost:55002`n"
                    "`n`tMySQL Host:  127.0.0.1    Port: 3306 & MGMT: 55060`n"
                    "`n`tPHP Webserver Address: http://localhost:55001`n"
                    "`tPHP Document Root:     [ $PATH\www ]`n"
                    "`n+--------------------------------------------------------------------------------------------------------+`n"
                    "`n To EXIT your LAMP server ENTER one of the selections below: `n"
                    "`n`t* [ docker-compose -f $DockerComposeFile down ]`n"
                    "`n`t* [ exit | quit | stop ]`n"
                    "`n+--------------------------------------------------------------------------------------------------------+`n"
                    "`n See Docker Logs at:  `n`n [ $DockerLogDirectory ]`n"
                    "`n+--------------------------------------------------------------------------------------------------------+`n"
                    "`n Please enter a command")

$answers = @("docker-compose -f $DockerComposeFile down","exit","stop service","stop","quit")
# Start service and wait for customer response to exit service
do {
    $input = Read-Host -Prompt $displayMessage
    "`n"
    foreach ($item in $answers) {
        $response = ($input.Contains($item))
        if ($response -eq $true) { # if the input is valid we break
            break
        } # else keep checking    
    } # No luck then we display error message and ask again politely...
    if ($response -eq $true) {
        # check user input a valid response
        break
    }
    elseif ($input -eq ""){
        # we do nothing, if they hit enter on the keyboard
        continue
    }
    else { # we display error on incorrect input
        Write-Host "That was not a valid input!!!`n`t[ $input ]`nPlease try again!!!`n" -ForegroundColor Red
        $displayMessage
    }
  
} while ($response -eq $false)


if ($response -eq $true) {
    Start-Process docker-compose.exe "-f $DockerComposeFile down"
}
###################################################################################################
###################################################################################################
