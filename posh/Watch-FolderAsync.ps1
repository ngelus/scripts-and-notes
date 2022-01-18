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
        [scriptblock]$Created = {
            $text = "{0} was {1} at {2}." -f $args.FullPath, $args.ChangeType, $event.TimeGenerated
            $args | Out-String | Write-Host
            $event | Out-String | Write-Host
            Write-Host $text -ForegroundColor DarkYellow
        },
        [Parameter(Mandatory=$false,Position=2)]
        [scriptblock]$Changed = {},
        [Parameter(Mandatory=$false,Position=3)]
        [scriptblock]$Renamed = {},
        [Parameter(Mandatory=$false,Position=4)]
        [scriptblock]$Deleted = {},
        [Parameter(Mandatory=$false,Position=5)]
        [string]$FileFilter = '*',
        [Parameter(Mandatory=$false,Position=6)]
        [switch]$IncludeSubfolders = $false
    )

    [IO.NotifyFilters]$AttributeFilter = [IO.NotifyFilters]::FileName, [IO.NotifyFilters]::LastWrite

    try {
        $watcher = New-Object -TypeName System.IO.FileSystemWatcher -Property @{
            Path = $Path
            Filter = $FileFilter
            IncludeSubdirectories = $IncludeSubfolders
            NotifyFilter = $AttributeFilter
        }

        $handlers = . {
            Register-ObjectEvent -InputObject $watcher -EventName Changed -Action $Changed
            Register-ObjectEvent -InputObject $watcher -EventName Created -Action $Created
            Register-ObjectEvent -InputObject $watcher -EventName Deleted -Action $Deleted
            Register-ObjectEvent -InputObject $watcher -EventName Renamed -Action $Renamed
        }

        $watcher.EnableRaisingEvents = $true

        Write-Verbose "Watching $Path for changes."

        do {
            Wait-Event -Timeout 1
            Write-Verbose "."
        } while ($true)
    } finally {
        $watcher.EnableRaisingEvents = $false
        $handlers | ForEach-Object {
            Unregister-Event -SourceIdentifier $_.Name
        }
        $handlers | Remove-Job
        $watcher.Dispose()
        Write-Verbose "Event Handler disabled, monitoring stopped."
    }
}