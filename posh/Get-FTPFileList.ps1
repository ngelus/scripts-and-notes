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
    $ResponseStream.Close()
    $FTPResponse.Close()

    return $files
}