<#
    Microsoft provides programming examples for illustration only, without warranty either expressed or
    implied, including, but not limited to, the implied warranties of merchantability and/or fitness 
    for a particular purpose. 
 
    This sample assumes that you are familiar with the programming language being demonstrated and the 
    tools used to create and debug procedures. Microsoft support professionals can help explain the 
    functionality of a particular procedure, but they will not modify these examples to provide added 
    functionality or construct procedures to meet your specific needs. if you have limited programming 
    experience, you may want to contact a Microsoft Certified Partner or the Microsoft fee-based consulting 
    line at (800) 936-5200.

    Script Updated by: Joe Alanis

#>


<#
.REQUIREMENTS
Requires PnP-PowerShell version 2.7.1609.3 or later
https://github.com/OfficeDev/PnP-PowerShell/releasess

.SYNOPSIS
Set a custom theme for a specific web. If a site collection is also provided, then use the site colleciton theme folder for theme storage

.EXAMPLE
PS C:\> .\Set-SPTheme.ps1 -TargetWebUrl "https://intranet.mydomain.com/sites/targetSite/marketing" -TargetSiteUrl "https://intranet.mydomain.com/sites/targetSite" 

.EXAMPLE
PS C:\> .\Set-SPTheme.ps1 -TargetWebUrl "https://intranet.mydomain.com/sites/targetSite" -MasterUrl "oslo.master" 
#>


[CmdletBinding()]
param
(
    [Parameter(Mandatory = $true, HelpMessage="Enter the URL of the target web, e.g. 'https://intranet.mydomain.com/sites/targetWeb'")]
    [String]
    $targetWebUrl,

	[Parameter(Mandatory = $false, HelpMessage="Enter the URL of the target asset location, i.e. site collection root web, e.g. 'https://intranet.mydomain.com/sites/targetWeb'")]
    [String]
    $targetSiteUrl,

    [Parameter(Mandatory = $false, HelpMessage="The theme master page url, relateive to Master Page Gallery of the target Web Url. Defaults to seattle.master")]
    [String]
    $masterUrl
)

if (!$targetSiteUrl)
{
    $targetSiteUrl = $targetWebUrl
}
if (!$masterUrl)
{
    $masterUrl = "seattle.master"
}

Write-Output "`nSetting Custom Theme on target web: $($targetWebUrl)"
Write-Output "`tTarget asset location : $($targetSiteUrl)"

# Background file name. Update if needed
$bgFile = "custom-bg.jpg"

# Yellow
$spColorFile = "Burnt-Yellow.spcolor"
$provisioningTemplate = "Custom.SPTheme.Infrastructure-Yellow.xml"

# Blue Example
# $spColorFile = "Blue-Test.spcolor"
# $provisioningTemplate = "Custom.SPTheme.Infrastructure.xml"

try
{
    Connect-PnPOnline -Url $targetSiteUrl -CurrentCredentials
	Write-Output "`tProvisioning asset files to $($targetSiteUrl)"
        
    # Copy the files to the target site url  (site where you want to store the assets)
    Apply-PnPProvisioningTemplate -Path ".\$provisioningTemplate" -Handlers Files -Verbose

	# If the site storing the assets and the web where you want to apply the branding are different, 
    # open up the target web now
	if($targetSiteUrl -ne $targetWebUrl)
	{	
        Disconnect-PnPOnline
        Connect-PnPOnline -Url $targetWebUrl -CurrentCredentials
	}
  
	$rootPath = $targetSiteUrl.Substring($targetSiteUrl.IndexOf('/',8))    
    $colorPaletteUrl = "$rootPath/_catalogs/theme/15/$spColorFile"
	$bgImageUrl = "$rootPath/style library/$bgFile"
    
    Write-Output "`tRoot Path: $($rootPath)"
    Write-Output "`tColor Palette Url: $($colorPaletteUrl)"
    Write-Output "`tBackground Image Url: $($bgImageUrl)"
	Write-Output "`tSetting composed look for $($targetWebUrl)"

	# https://github.com/OfficeDev/PnP-PowerShell/blob/master/Documentation/SetPNPTheme.md
    Set-PnPTheme -ColorPaletteUrl $colorPaletteUrl -BackgroundImageUrl $bgImageUrl -Verbose

	# now set the master page
	$webRootPath = $targetWebUrl.Substring($targetWebUrl.IndexOf('/',8))
	$masterUrl = "$webRootPath/_catalogs/masterpage/$masterUrl"
	Write-Output "`tSetting master page to $($masterUrl)"

    Set-PnPWeb -MasterUrl $masterUrl
	Write-Output "Composed Look applied."
}
catch
{
    Write-Output "`n`n"
    Write-Error $_.Exception
}