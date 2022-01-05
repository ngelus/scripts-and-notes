Function Set-WallPaper {
 
    <#
     
        .SYNOPSIS
        Applies a specified wallpaper to the current user's desktop
        
        .PARAMETER Image
        Provide the exact path to the image
     
        .PARAMETER Style
        Provide wallpaper style (Example: Fill, Fit, Stretch, Tile, Center, or Span)
      
        .EXAMPLE
        Set-WallPaper -Image "C:\Wallpaper\Default.jpg"
        Set-WallPaper -Image "C:\Wallpaper\Background.jpg" -Style Fit
      
    #>
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$True,Position=0)]
	[Alias("Picture","File")]
        # Provide path to image
        [string]$Image,
        # Provide wallpaper style that you would like applied
        [parameter(Mandatory=$False,Position=1)]
        [ValidateSet('Fill', 'Fit', 'Stretch', 'Tile', 'Center', 'Span')]
        [string]$Style
    )
     
    $WallpaperStyle = Switch ($Style) {
      
        "Fill" {"10"}
        "Fit" {"6"}
        "Stretch" {"2"}
        "Tile" {"0"}
        "Center" {"0"}
        "Span" {"22"}
      
    }
     
    If($Style -eq "Tile") {
     
        New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WallpaperStyle -PropertyType String -Value $WallpaperStyle -Force
        New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name TileWallpaper -PropertyType String -Value 1 -Force
     
    }
    Else {
     
        New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WallpaperStyle -PropertyType String -Value $WallpaperStyle -Force
        New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name TileWallpaper -PropertyType String -Value 0 -Force
     
    }
     
    Add-Type -TypeDefinition @"
    using System; 
    using System.Runtime.InteropServices;
      
    public class Params
    { 
        [DllImport("User32.dll",CharSet=CharSet.Unicode)] 
        public static extern int SystemParametersInfo (Int32 uAction, 
                                                       Int32 uParam, 
                                                       String lpvParam, 
                                                       Int32 fuWinIni);
    }
"@ 
      
        $SPI_SETDESKWALLPAPER = 0x0014
        $UpdateIniFile = 0x01
        $SendChangeEvent = 0x02
      
        $fWinIni = $UpdateIniFile -bor $SendChangeEvent
      
        $ret = [Params]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $Image, $fWinIni)
    }

function Set-WallpaperFromURL {
	
	<#
     
        .SYNOPSIS
        Applies a specified wallpaper to the current user's desktop using the image provided in the URL
        
        .PARAMETER ImageURL
        Provide the URL to the image
     
        .PARAMETER Style
        Provide wallpaper style (Example: Fill, Fit, Stretch, Tile, Center, or Span)
      
        .EXAMPLE
        Set-WallpaperFromURL -ImageURL "https://via.placeholder.com/1920x1080.jpg"
        Set-WallpaperFromURL -ImageURL "https://via.placeholder.com/1920x1080.jpg" -Style Fit
      
    #>
	
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$true,Position=0)]
	[Alias("PictureURL","FileURL")]
        [string]$imageURL,
        [parameter(Mandatory=$False,Position=1)]
        [ValidateSet('Fill', 'Fit', 'Stretch', 'Tile', 'Center', 'Span')]
        [string]$Style
    )
    Invoke-WebRequest -Uri $imageURL -OutFile $env:TEMP\PSWallpaper.jpg
    Set-WallPaper -Image $env:TEMP\PSWallpaper.jpg -Style $Style
}
#Set-WallPaper -Image $env:TEMP\PSWallpaper.jpg -Style Center
#Set-WallpaperFromURL -ImageURL "https://via.placeholder.com/1920x1080.jpg" -Style Center
