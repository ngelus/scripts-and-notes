function Watch-Changes {

    <#
        .SYNOPSIS
        Watches a directory for changes.

        .DESCRIPTION
        Watches a specified directory for changes and executes a provided function or scriptblock.

        .PARAMETER Path
        Provide the path to the directory that should be monitored for changes.

        .PARAMETER FileFilter
        Provide a regular expression to only watch for files matched.

        .PARAMETER IncludeSubfolders
        Switch to determine if subfolders should also be watched.

        .PARAMETER ScriptBlock
        Script to be executed on change. $args.Change is the change information.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,Position=0)]
        [ValidateScript({Test-Path $_})]
        [string]$Path = [Environment]::CurrentDirectory,
        [Parameter(Mandatory=$false,Position=1)]
        [string]$FileFilter = '*',
        [Parameter(Mandatory=$false,Position=2)]
        [switch]$IncludeSubfolders = $false,
        [Parameter(Mandatory=$false,Position=3)]
        [scriptblock]$ScriptBlock = { $args.Change | Out-String | Write-Host -ForegroundColor DarkYellow }
    )

    [IO.NotifyFilters]$AttributeFilter = [IO.NotifyFilters]::FileName, [IO.NotifyFilters]::LastWrite
    [System.IO.WatcherChangeTypes]$ChangeTypes = [System.IO.WatcherChangeTypes]::Created, [System.IO.WatcherChangeTypes]::Deleted
    [int]$Timeout = 1000

    try {
        Write-Verbose "FileSystemWatcher is monitoring $Path"

        $watcher = New-Object -TypeName IO.FileSystemWatcher -ArgumentList $Path, $FileFilter -Property @{
            IncludeSubdirectories = $IncludeSubfolders
            NotifyFilter = $AttributeFilter
        }

        do {
            [System.IO.WaitForChangedResult]$result = $watcher.WaitForChanged($ChangeTypes, $Timeout)
            if($result.TimedOut) { continue }
            $ScriptBlock.Invoke(@{"Change"=$result})
        } while ($true)
    } finally {
        $watcher.Dispose()
        Write-Verbose 'FileSystemWatcher removed.'
    }
}