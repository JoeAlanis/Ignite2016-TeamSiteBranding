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
Disabled custom master page and logo

.EXAMPLE
PS C:\> .\Disable-Level3Branding.ps1 -TargetSiteUrl "https://intranet.mydomain.com/sites/targetSite/marketing" 


#>

[CmdletBinding()]
param
(
    [Parameter(Mandatory = $true, HelpMessage="Enter the URL of the target site, e.g. 'https://intranet.mydomain.com/sites/targetWeb'")]
    [String]
    $targetSiteUrl
)

Write-Output "`nDisabling Level 2 branding on target web: $($targetWebUrl)"

try
{
	Connect-PnPOnline $targetSiteUrl -CurrentCredentials
    Write-Output "`tResetting master page..."

	$webRootPath = $targetSiteUrl.Substring($targetSiteUrl.IndexOf('/',8))
	$masterUrl = "$webRootPath/_catalogs/masterpage/seattle.master"
	Set-PnPWeb -MasterUrl $masterUrl -SiteLogoUrl ""
    Write-Output "`tReset Complete."
}
catch
{
    Write-Error "Exception occurred!" 
    Write-Error "Exception Type: $($_.Exception.GetType().FullName)"
    Write-Error "Exception Message: $($_.Exception.Message)"
}