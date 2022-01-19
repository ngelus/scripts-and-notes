function Get-FTPFileList {
    <#
        .SYNOPSIS
        Lists all files in a directory on an FTP server.

        .DESCRIPTION
        Lists all files in a directory on an FTP server.

        .PARAMETER Server
        The FTP server to connect to.

        .PARAMETER Username
        The username to use when connecting to the FTP server.

        .PARAMETER Password
        The password to use when connecting to the FTP server.

        .PARAMETER Directory
        The directory to list files in.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]$Server,
        [Parameter(Mandatory=$true, Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]$Username,
        [Parameter(Mandatory=$true, Position=2)]
        [ValidateNotNullOrEmpty()]
        [string]$Password,
        [Parameter(Mandatory=$true, Position=3)]
        [ValidateNotNullOrEmpty()]
        [string]$Directory
    )

    try {
        $URI = "ftp://$Server/$Directory"
        $FTPRequest = [System.Net.FtpWebRequest]::Create($URI)
        $FTPRequest.Credentials = [System.Net.NetworkCredential]::new($Username, $Password)
        $FTPRequest.Method = [System.Net.WebRequestMethods+Ftp]::ListDirectoryDetails
        $FTPResponse = $FTPRequest.GetResponse()
        $ResponseStream = $FTPResponse.GetResponseStream()
        $StreamReader = New-Object System.IO.StreamReader $ResponseStream

        $files = New-Object System.Collections.ArrayList
        while ($file = $StreamReader.ReadLine()) {
            [void] $files.Add("$file")
        }
    } catch {
        Write-Error -Message $_.Exception.InnerException.Message
    }

    $StreamReader.Close()
    $StreamReader.Dispose()
    $ResponseStream.Close()
    $ResponseStream.Dispose()
    $FTPResponse.Close()
    $FTPResponse.Dispose()

    return $files
}

function Set-FTPFile {
    <#
        .SYNOPSIS
        Uploads a file to an FTP server.

        .DESCRIPTION
        Uploads a file to an FTP server.

        .PARAMETER Server
        The FTP server to connect to.

        .PARAMETER Username
        The username to use when connecting to the FTP server.

        .PARAMETER Password
        The password to use when connecting to the FTP server.

        .PARAMETER From
        The file to upload.

        .PARAMETER To
        The destination file to upload to.

    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]$Server,
        [Parameter(Mandatory=$true, Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]$Username,
        [Parameter(Mandatory=$true, Position=2)]
        [ValidateNotNullOrEmpty()]
        [string]$Password,
        [Parameter(Mandatory=$true, Position=3)]
        [ValidateNotNullOrEmpty()]
        [string]$From,
        [Parameter(Mandatory=$true, Position=4)]
        [ValidateNotNullOrEmpty()]
        [string]$To
    )

    try {
        $URI = "ftp://$Server/$To"
        $FTPRequest = [System.Net.FtpWebRequest]::Create($URI)
        $FTPRequest.Credentials = [System.Net.NetworkCredential]::new($Username, $Password)
        $FTPRequest.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
        $FTPRequest.UseBinary = $true
        $FTPRequest.UsePassive = $true

        $content = [System.IO.File]::ReadAllBytes($From)
        $FTPRequest.ContentLength = $content.Length
        $RequestStream = $FTPRequest.GetRequestStream()
        $RequestStream.Write($content, 0, $content.Length)

    } catch {
        Write-Error -Message $_.Exception.InnerException.Message
    }
    $RequestStream.Close()
    $RequestStream.Dispose()
    $FTPRequest.Close()
    $FTPRequest.Dispose()
}

function Get-FTPFile {
    <#
        .SYNOPSIS
        Downloads a file from an FTP server.

        .DESCRIPTION
        Downloads a file from an FTP server.

        .PARAMETER Server
        The FTP server to connect to.

        .PARAMETER Username
        The username to use when connecting to the FTP server.

        .PARAMETER Password
        The password to use when connecting to the FTP server.

        .PARAMETER From
        The file to download.

        .PARAMETER To
        The destination file to download to.

    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]$Server,
        [Parameter(Mandatory=$true, Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]$Username,
        [Parameter(Mandatory=$true, Position=2)]
        [ValidateNotNullOrEmpty()]
        [string]$Password,
        [Parameter(Mandatory=$true, Position=3)]
        [ValidateNotNullOrEmpty()]
        [string]$From,
        [Parameter(Mandatory=$true, Position=4)]
        [ValidateNotNullOrEmpty()]
        [string]$To
    )

    try {
        $URI = "ftp://$Server/$From"
        $FTPRequest = [System.Net.FtpWebRequest]::Create($URI)
        $FTPRequest.Credentials = [System.Net.NetworkCredential]::new($Username, $Password)
        $FTPRequest.Method = [System.Net.WebRequestMethods+Ftp]::DownloadFile
        $FTPRequest.UseBinary = $true
        $FTPRequest.UsePassive = $true

        $FTPResponse = $FTPRequest.GetResponse()
        $ResponseStream = $FTPResponse.GetResponseStream()
        $TargetStream = [System.IO.File]::Create($To)

        $buffer = New-Object byte[] 10240
        while(($read = $ResponseStream.Read($buffer, 0, $buffer.Length)) -gt 0) {
            $TargetStream.Write($buffer, 0, $read)
        }

    } catch {
        Write-Error -Message $_.Exception.InnerException.Message
    }
    $ResponseStream.Close()
    $ResponseStream.Dispose()
    $TargetStream.Close()
    $TargetStream.Dispose()
    $FTPResponse.Close()
    $FTPResponse.Dispose()
}

function Remove-FTPFile {
    <#
        .SYNOPSIS
        Deletes a file from an FTP server.

        .DESCRIPTION
        Deletes a file from an FTP server.

        .PARAMETER Server
        The FTP server to connect to.

        .PARAMETER Username
        The username to use when connecting to the FTP server.

        .PARAMETER Password
        The password to use when connecting to the FTP server.

        .PARAMETER File
        The file to delete.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]$Server,
        [Parameter(Mandatory=$true, Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]$Username,
        [Parameter(Mandatory=$true, Position=2)]
        [ValidateNotNullOrEmpty()]
        [string]$Password,
        [Parameter(Mandatory=$true, Position=3)]
        [ValidateNotNullOrEmpty()]
        [string]$File
    )

    try {
        $URI = "ftp://$Server/$File"
        $FTPRequest = [System.Net.FtpWebRequest]::Create($URI)
        $FTPRequest.Credentials = [System.Net.NetworkCredential]::new($Username, $Password)
        $FTPRequest.Method = [System.Net.WebRequestMethods+Ftp]::DeleteFile
        $FTPRequest.UseBinary = $true
        $FTPRequest.UsePassive = $true

        $FTPResponse = $FTPRequest.GetResponse()

    } catch {
        Write-Error -Message $_.Exception.InnerException.Message
    }

    $FTPResponse.Close()
    $FTPResponse.Dispose()
}

function Get-FTPDirectory {
    <#
        .SYNOPSIS
        Downloads a directory from an FTP server.

        .DESCRIPTION
        Downloads a directory from an FTP server.

        .PARAMETER Server
        The FTP server to connect to.

        .PARAMETER Username
        The username to use when connecting to the FTP server.

        .PARAMETER Password
        The password to use when connecting to the FTP server.

        .PARAMETER From
        The directory to download.

        .PARAMETER To
        The destination directory to download to.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]$Server,
        [Parameter(Mandatory=$true, Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]$Username,
        [Parameter(Mandatory=$true, Position=2)]
        [ValidateNotNullOrEmpty()]
        [string]$Password,
        [Parameter(Mandatory=$true, Position=3)]
        [ValidateNotNullOrEmpty()]
        [string]$From,
        [Parameter(Mandatory=$true, Position=4)]
        [ValidateNotNullOrEmpty()]
        [string]$To
    )

    try {
       $lines = Get-FTPFileList -Server $Server -Username $Username -Password $Password -Directory $From
       foreach ($line in $lines) {
           $tokens = $line.Split(" ", 9, [StringSplitOptions]::RemoveEmptyEntries)
           $name = $tokens[8]
           $permissions = $tokens[0]

           $localFilesPath = Join-Path $To $name
           $fileUrl = "$From/$name"

           if($permissions[0] -eq "d") {
               if(!(Test-Path $localFilesPath -PathType Container)) {
                   Write-Verbose "Creating directory $localFilesPath"
                   New-Item $localFilesPath -Type Directory | Out-Null
               }
               Get-FTPDirectory -Server $Server -Username $Username -Password $Password -From $fileUrl -To $localFilesPath
           } else {
               Write-Verbose "Downloading file $fileUrl to $localFilesPath"

               Get-FTPFile -Server $Server -Username $Username -Password $Password -From $fileUrl -To $localFilesPath
           }
       }

    } catch {
        Write-Error -Message $_.Exception.InnerException.Message
    }
}