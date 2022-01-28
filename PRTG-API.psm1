#####Notes#####

#Use Set-PRTGServer to set username and credentials while using this module. 

#####Functions#####


function Set-PRTGServer{
<#
.SYNOPSIS
    Set PRTG server and credentials
.DESCRIPTION
    Set PRTG server name, Username, and PassHash to be used by other functions
.PARAMETER Server
    Set the FQDN or IP of the PRTG server (not the full URL)
.PARAMETER UserName
    Set the user name to be used
.PARAMETER PassHash
    Set the password hash retrieved from the Setup > System Administration > User Accounts > <user> > Show Passhash
.NOTES
    Version:        1.0
    Author:         disposablecat
    Purpose/Change: Initial script development
.EXAMPLE
    Set-PRTGServer -Server prtg.fake.com -UserName fakename -Passhash 123456789
    Will test connection to the server, save for use by other functions, and return if the user is an admin or has read-only access.
    This information will be useful when using specific functions such as ones using the "Set" verb. 
#>
    [CmdletBinding()]
    [OutputType([System.Object])]
    
    #Define parameters
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [string]$Server,

        # Param2 help description
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [string]$UserName,

        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [string]$PassHash
    )

    Begin
    {
        $ConnectObject = New-Object PSObject; 
        $ConnectObject | Add-Member -type Noteproperty -Name Server -Value $Null
        $ConnectObject | Add-Member -type Noteproperty -Name UserName -Value $Null
        $ConnectObject | Add-Member -type Noteproperty -Name IsAdminUser -Value $Null
        $ConnectObject | Add-Member -type Noteproperty -Name ReadOnlyUser -Value $Null
        
    }
    Process
    {
        #Will execute second. Will execute for each each objects piped into the function
        Try
        {
            $TempAuth = "username=$UserName&passhash=$PassHash"
            $TempUrl = "https://$Server/api/getstatus.xml?$auth"
            [xml]$Request = Invoke-WebRequest -Uri $TempUrl -MaximumRedirection 0 -ErrorAction Stop
            $ConnectObject.Server = $Server
            $ConnectObject.UserName = $UserName
            $ConnectObject.IsAdminUser = $Requst.status.IsAdminUser
            $ConnectObject.ReadOnlyUser = $Request.status.ReadOnlyUser
            Set-Variable -Name $PRTGHost -Value $Server -Scope Global
            Set-Variable -Name $auth -Value $TempAuth -Scope Global
        }
        Catch
        {
            #Catch any error.
            Write-Verbose “Exception Caught: $($_.Exception.Message)”
        }
        return $ConnectObject
    }
}

function Get-PRTGSensors{
<#
.SYNOPSIS
     Get PRTG sensors.  
.DESCRIPTION
   Get all sensors within a give PRTG group or device. Remember devices are also considered groups.  
.EXAMPLE
   Get-PRTGSensors -ID 2722
   Returns all sensors in the group/device with ID 2722
.EXAMPLE
   Get-PRTGSensors 
   Returns all sensors in the root group. (ID=0). Essentially returns all sensors in this instance of PRTG.
#>
    [CmdletBinding()]
    [OutputType([System.Array])]
    
    #Define parameters
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true)]
        [int]$ID=0
    )

    Begin
    {
        #Null variables out as to not reuse stale variables
        $url = $null
        $request = $null
        
    }
    Process
    {
        #Will execute second. Will execute for each each objects piped into the function
        Try
        {
            $url = "https://$PRTGHost/api/table.xml?content=sensors&output=csvtable&columns=objid,probe,group,device,sensor,status,message,lastvalue,priority,favorite,tags,notifiesx&id=$ID&count=2500&$auth"
            $request = Invoke-WebRequest -Uri $url -MaximumRedirection 0
            ConvertFrom-csv $request
            
        }
        Catch
        {
            #Catch any error.
            Write-Host  “Caught an exception:” -ForegroundColor Red
            Write-Host “Exception Type: $($_.Exception.GetType().FullName)” -ForegroundColor Red
            Write-Host “Exception Message: $($_.Exception.Message)” -ForegroundColor Red
        }
       
    }
    End
    {
        #Null variables out as to not reuse stale variables
        $url = $null
        $request = $null
    }
}

function Get-PRTGDevices{
<#
.SYNOPSIS
     Get PRTG devices.  
.DESCRIPTION
   Get all devices within a give PRTG group. 
.EXAMPLE
   Get-PRTGDevices -ID 2666
   Returns all devices in the group with ID 2722
.EXAMPLE
   Get-PRTGDevices 
   Returns all devices in the root group. (ID=0). Essentially returns all devices in this instance of PRTG.
#>
    [CmdletBinding()]
    [OutputType([System.Array])]
    
    #Define parameters
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true)]
        [int]$ID=0
    )

    Begin
    {
        #Null variables out as to not reuse stale variables
        $url = $null
        $request = $null
        
    }
    Process
    {
        #Will execute second. Will execute for each each objects piped into the function
        Try
        {
            $url = "https://$PRTGHost/api/table.xml?content=devices&output=csvtable&columns=objid,probe,parentid,device,host,tags,location,dependency,comments,notifiesx&id=$ID&count=2500&$auth"
            $request = Invoke-WebRequest -Uri $url -MaximumRedirection 0
            ConvertFrom-csv $request
            
        }
        Catch
        {
            #Catch any error.
            Write-Host  “Caught an exception:” -ForegroundColor Red
            Write-Host “Exception Type: $($_.Exception.GetType().FullName)” -ForegroundColor Red
            Write-Host “Exception Message: $($_.Exception.Message)” -ForegroundColor Red
        }
       
    }
    End
    {
        #Null variables out as to not reuse stale variables
        $url = $null
        $request = $null
    }
}

function Get-PRTGGroups{
<#
.SYNOPSIS
     Get PRTG groups.  
.DESCRIPTION
   Get all groups within a give PRTG group. Remember the root group is simply ID=0, which will get all groups.  
.EXAMPLE
   Get-PRTGGroup -ID 1001
   Returns all groups in the group with ID 1001
.EXAMPLE
   Get-PRTGDevices 
   Returns all groups in the root group. (ID=0). Essentially returns all devices in this instance of PRTG.
#>
    [CmdletBinding()]
    [OutputType([System.Array])]
    
    #Define parameters
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true)]
        [int]$ID=0
    )

    Begin
    {
        #Null variables out as to not reuse stale variables
        $url = $null
        $request = $null
        
    }
    Process
    {
        #Will execute second. Will execute for each each objects piped into the function
        Try
        {
            $url = "https://$PRTGHost/api/table.xml?content=groups&output=csvtable&columns=objid,probe,group,name,tags,location,dependency,comments&count=2500&id=$StartingID&$auth"
            $request = Invoke-WebRequest -Uri $url
            ConvertFrom-csv $request
            
        }
        Catch
        {
            #Catch any error.
            Write-Host  “Caught an exception:” -ForegroundColor Red
            Write-Host “Exception Type: $($_.Exception.GetType().FullName)” -ForegroundColor Red
            Write-Host “Exception Message: $($_.Exception.Message)” -ForegroundColor Red
        }
       
    }
    End
    {
        #Null variables out as to not reuse stale variables
        $url = $null
        $request = $null
    }
}

function Get-PRTGObjectProperty{
<#
.SYNOPSIS
     Get PRTG object property.  
.DESCRIPTION
   Get a specific property from an object in PRTG. An object can be a group, a device, etc.
   Device Property List:  
   -accessrights
   -active
   -autoacknowledge (sensor only)
   -count (sensor only)
   -dbauth
   -dbpassword
   -dbport
   -dbtimeout
   -dbuser
   -delay (sensor only)
   -depdeplay
   -dependency
   -dependencytype
   -deviceicon
   -discoveryschedule
   -discoverytype
   -elevationnamesu
   -elevationnamesudo
   -elevationpass
   -errorintervalsdown
   -esxpassword
   -esxprotocol
   -esxuser
   -force32
   -host
   -ignoreoverflow
   -ignorezero
   -inherittriggers
   -interval
   -ipversion
   -linuxloginmode
   -linuxloginpassword
   -linuxloginusername
   -location
   -lonlat
   -maintenable
   -maintend
   -maintstart
   -name
   -portend
   -portstart
   -portupdateoid
   -primarychannel (sensor only)
   -priority
   -proxy
   -proxypassword
   -proxyport
   -proxyuser
   -retrysnmp
   -schedule
   -sensorykind (sensor only)
   -serviceurl
   -size (sensor only)
   -snmpauthmode
   -snmpauthpass
   -snmpcommv1
   -snmpcommv2
   -snmpcontext
   -snmpdelay
   -snmpencmode
   -snmpencpass
   -snmpport
   -snmptimout
   -snmpuser
   -snmpversion
   -sshelevatedrights
   -sshport
   -sshversion_devicegroup
   -stack (sensor only)
   -sysinfo
   -tags
   -timeout (sensor only)
   -trafficportname
   -unitconfig
   -updateportname
   -usedbcustomport
   -usesingleget
   -vmwaresessionpool
   -wantsimilarity
   -wantsunusual
   -wbemport
   -wbemportmode
   -wbemprotocol
   -windowslogindomain
   -windowsloginpassword
   -windowsloginusername
   -wmiorpc
   -wmitimeout
   -wmitimeoutmethod

.EXAMPLE
   Get-PRTGObjectProperty -ID 1001 -Property tags
   Returns all tags from the objects with ID 1001
.EXAMPLE
   Get-PRTGObjectProperty -ID 1001 -Property name
   Gets the name of object 1001. 
.EXAMPLE
   Get-PRTGObjectProperty -Property name
   Gets the status of object 0 (default).
#>
    [CmdletBinding()]
    [OutputType([System.Array])]
    
    #Define parameters
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true)]
        [int]$ID=0,

        [string]$Property="tags"
    )

    Begin
    {
        #Null variables out as to not reuse stale variables
        $url = $null
        $request = $null
        
    }
    Process
    {
        #Will execute second. Will execute for each each objects piped into the function
        Try
        {
            $url = "https://$PRTGHost/api/getobjectproperty.htm?id=$ID&name=$Property&$auth"
            [xml]$request = Invoke-WebRequest -Uri $url -MaximumRedirection 0
            $request.ChildNodes.result
            
        }
        Catch
        {
            #Catch any error.
            Write-Host  “Caught an exception:” -ForegroundColor Red
            Write-Host “Exception Type: $($_.Exception.GetType().FullName)” -ForegroundColor Red
            Write-Host “Exception Message: $($_.Exception.Message)” -ForegroundColor Red
        }
       
    }
    End
    {
        #Null variables out as to not reuse stale variables
        $url = $null
        $request = $null
    }
}

function Set-PRTGObjectProperty{
<#
.SYNOPSIS
     Set PRTG object property.  
.DESCRIPTION
   Set a specific property on an object in PRTG. An object can be a group, a device, etc. 
   Device Property List:  
   -accessrights
   -active
   -autoacknowledge (sensor only)
   -count (sensor only)
   -dbauth
   -dbpassword
   -dbport
   -dbtimeout
   -dbuser
   -delay (sensor only)
   -depdeplay
   -dependency
   -dependencytype
   -deviceicon
   -discoveryschedule
   -discoverytype
   -elevationnamesu
   -elevationnamesudo
   -elevationpass
   -errorintervalsdown
   -esxpassword
   -esxprotocol
   -esxuser
   -force32
   -host
   -ignoreoverflow
   -ignorezero
   -inherittriggers
   -interval
   -ipversion
   -linuxloginmode
   -linuxloginpassword
   -linuxloginusername
   -location
   -lonlat
   -maintenable
   -maintend
   -maintstart
   -name
   -portend
   -portstart
   -portupdateoid
   -primarychannel (sensor only)
   -priority
   -proxy
   -proxypassword
   -proxyport
   -proxyuser
   -retrysnmp
   -schedule
   -sensorykind (sensor only)
   -serviceurl
   -size (sensor only)
   -snmpauthmode
   -snmpauthpass
   -snmpcommv1
   -snmpcommv2
   -snmpcontext
   -snmpdelay
   -snmpencmode
   -snmpencpass
   -snmpport
   -snmptimout
   -snmpuser
   -snmpversion
   -sshelevatedrights
   -sshport
   -sshversion_devicegroup
   -stack (sensor only)
   -sysinfo
   -tags
   -timeout (sensor only)
   -trafficportname
   -unitconfig
   -updateportname
   -usedbcustomport
   -usesingleget
   -vmwaresessionpool
   -wantsimilarity
   -wantsunusual
   -wbemport
   -wbemportmode
   -wbemprotocol
   -windowslogindomain
   -windowsloginpassword
   -windowsloginusername
   -wmiorpc
   -wmitimeout
   -wmitimeoutmethod  
.EXAMPLE
   Set-PRTGObjectProperty -ID 1001 -Property tags -Value buildingname
   Sets a tag on object 1001 with the value "buildingname"
.EXAMPLE
   Set-PRTGObjectProperty -ID 1001 -Property status -Value Paused
   Sets the the object 1001 status to paused, which essentially pauses the object
#>
    [CmdletBinding()]
    [OutputType([System.Array])]
    
    #Define parameters
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true)]
        [int]$ID=0,

        [string]$Property,

        [string]$Value
    )

    Begin
    {
        #Null variables out as to not reuse stale variables
        $url = $null
        $request = $null
        
    }
    Process
    {
        #Will execute second. Will execute for each each objects piped into the function
        Try
        {
            $url = "https://$PRTGHost/api/setobjectproperty.htm?id=$ID&name=$Property&value=$Value&$auth"
            $request = Invoke-WebRequest -Uri $url -MaximumRedirection 0
            
        }
        Catch
        {
            #Catch any error.
            Write-Host  “Caught an exception:” -ForegroundColor Red
            Write-Host “Exception Type: $($_.Exception.GetType().FullName)” -ForegroundColor Red
            Write-Host “Exception Message: $($_.Exception.Message)” -ForegroundColor Red
        }
       
    }
    End
    {
        #Null variables out as to not reuse stale variables
        $url = $null
        $request = $null
    }
}

function Get-PRTGSensorChannels{
<#
.SYNOPSIS
     Get PRTG sensor channel results.  
.DESCRIPTION
   Get a list of all channels for a given sensor along with the last result. Channel IDs are not returned.   
.EXAMPLE
   Get-PRTGSensorChannels -ID 1001
   Returns all sensor channel names and last results for the sensor with ID 1001
#>
    [CmdletBinding()]
    [OutputType([System.Array])]
    
    #Define parameters
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true)]
        [int]$ID=0
    )

    Begin
    {
        #Null variables out as to not reuse stale variables
        $url = $null
        $request = $null
        
    }
    Process
    {
        #Will execute second. Will execute for each each objects piped into the function
        Try
        {
            $url = "https://$PRTGHost/api/table.xml?content=channels&output=csvtable&columns=name,lastvalue_&id=$ID&$auth"
            $request = Invoke-WebRequest -Uri $url -MaximumRedirection 0
            ConvertFrom-csv ($request)
            
        }
        Catch
        {
            #Catch any error.
            Write-Host  “Caught an exception:” -ForegroundColor Red
            Write-Host “Exception Type: $($_.Exception.GetType().FullName)” -ForegroundColor Red
            Write-Host “Exception Message: $($_.Exception.Message)” -ForegroundColor Red
        }
       
    }
    End
    {
        #Null variables out as to not reuse stale variables
        $url = $null
        $request = $null
    }
}



function Get-PRTGSensorChannelIDs{
<#
.SYNOPSIS
     Get PRTG sensor channel IDs.  
.DESCRIPTION
   Get a list of all channel IDs for a given sensor.   
.EXAMPLE
   Get-PRTGSensorChannelIDs -ID 1001
   Returns all sensor channel IDs for the sensor with ID 1001
#>
    [CmdletBinding()]
    [OutputType([System.Array])]
    
    #Define parameters
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true)]
        [int]$ID=0
    )

    Begin
    {
        #Null variables out as to not reuse stale variables
        $url = $null
        $request = $null
        
    }
    Process
    {
        #Will execute second. Will execute for each each objects piped into the function
        Try
        {
            #No current API option
            Write-Host "There isn't a current API call for this"
            
        }
        Catch
        {
            #Catch any error.
            Write-Host  “Caught an exception:” -ForegroundColor Red
            Write-Host “Exception Type: $($_.Exception.GetType().FullName)” -ForegroundColor Red
            Write-Host “Exception Message: $($_.Exception.Message)” -ForegroundColor Red
        }
       
    }
    End
    {
        #Null variables out as to not reuse stale variables
        $url = $null
        $request = $null
    }
}

function Get-PRTGSensorData{
<#
.SYNOPSIS
    Get PRTG sensor data  
.DESCRIPTION
    Get a a dump of all historic data from a specific sensor by ID. Must specify StartDate, EndDate, and interval Avg    
.EXAMPLE
    Get-PRTGSensorData -ID 1001 -StartDate 2016-09-20-00-00-00 -EndData 2016-09-21-00-00-00
    Returns all sensor data from 2016-09-20-00-00-00 to 2016-09-21-00-00-00 with a default average of one hour (3600 seconds)
.EXAMPLE
    Get-PRTGSensorData -ID 1001 -StartDate 2016-09-20-00-00-00 -EndData 2016-09-21-00-00-00 -Avg 300
    Return all sensor data from 2016-09-20-00-00-00 to 2016-09-21-00-00-00 with a specific average of 5 minutes (300 seconds)
#>
    [CmdletBinding()]
    [OutputType([System.Array])]
    
    #Define parameters
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [int]$ID,

        [string]$StartDate=(Get-Date).AddDays(-1).ToString("yyyy-MM-dd-HH-mm-ss"),

        [string]$Enddate=(Get-Date -format "yyyy-MM-dd-HH-mm-ss"),

        [int]$Avg=3600
    )

    Begin
    {
        #Null variables out as to not reuse stale variables
        $url = $null
        $request = $null
        
    }
    Process
    {
        #Will execute second. Will execute for each each objects piped into the function
        Try
        {
            $url = "https://$PRTGHost/api/historicdata.csv?id=$ID&avg=3600&sdate=$StartDate&edate=$EndDate&$auth"
            #$url
            $request = Invoke-WebRequest -Uri $url -MaximumRedirection 0
            ConvertFrom-csv ($request)
            
        }
        Catch
        {
            #Catch any error.
            Write-Host  “Caught an exception:” -ForegroundColor Red
            Write-Host “Exception Type: $($_.Exception.GetType().FullName)” -ForegroundColor Red
            Write-Host “Exception Message: $($_.Exception.Message)” -ForegroundColor Red
        }
       
    }
    End
    {
        #Null variables out as to not reuse stale variables
        $url = $null
        $request = $null
    }
}

function Set-PRTGChannelProperty{
<#
.SYNOPSIS
     Set PRTG channel Property.  
.DESCRIPTION
   Set a specific property on an object in PRTG. An object can be a group, a device, etc.
    
   Channel Property List:  
   -limitmaxerror - Upper Error Limit
   -limitmaxwarning - Upper Warning Limit
   -limitminwarning - Lower Warning Limit
   -limitminerror - Lower Error Limit

   Channel ID Rough Guide:
   -Channel ID: -4 = "Downtime" channel
   -Channel ID: 0 =  primary channel, usual something like CPU total, Traffic In, Ping Time, Response Time, etc. 
   -Channel ID: 1-X = Usually additional channels such as specific CPU cores and other additional metrics
.EXAMPLE
   Set-PRTGChannelProperty -SensorID 2023 -ChannelID 0 -Property limitmaxerror -Value 90
   Assuming this is a CPU sensor and that the channel ID is 0 then it will set the upper error limit to 90. 
#>
    [CmdletBinding()]
    [OutputType([System.Array])]
    
    #Define parameters
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [int]$SensorID,

        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [int]$ChannelID,

        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [string]$Property,

        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [string]$Value
    )

    Begin
    {
        #Null variables out as to not reuse stale variables
        $url = $null
        $request = $null
        
    }
    Process
    {
        #Will execute second. Will execute for each each objects piped into the function
        Try
        {
            $url = "https://$PRTGHost/api/setobjectproperty.htm?id=$SensorID&subtype=channel&subid=$ChannelID&name=$Property&value=$Value&$auth"
            $request = Invoke-WebRequest -Uri $url -MaximumRedirection 0
            
        }
        Catch
        {
            #Catch any error.
            Write-Host  “Caught an exception:” -ForegroundColor Red
            Write-Host “Exception Type: $($_.Exception.GetType().FullName)” -ForegroundColor Red
            Write-Host “Exception Message: $($_.Exception.Message)” -ForegroundColor Red
        }
       
    }
    End
    {
        #Null variables out as to not reuse stale variables
        $url = $null
        $request = $null
    }
}