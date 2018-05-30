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

    Script updated by Joe Alanis

#>

<#
.REQUIREMENTS
Requires PnP-PowerShell version 2.7.1609.3 or later
https://github.com/OfficeDev/PnP-PowerShell/releasess

.SYNOPSIS
Set Alternative CSS and a custom logo

.EXAMPLE
PS C:\> .\Set-Level2Branding.ps1 -TargetWebUrl "https://intranet.mydomain.com/sites/targetSite/marketing" -TargetSiteUrl "https://intranet.mydomain.com/sites/targetSite" 

.EXAMPLE
PS C:\> .\Set-Level2Branding.ps1 -TargetWebUrl "https://intranet.mydomain.com/sites/targetSite" -ServeLocal
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

    [Parameter(Mandatory = $false, HelpMessage="Serve assets from localhost if using")]
    [switch] 
    $ServeLocal
)

# Update the css, site logo and provisioning template file (Custom.Level2Branding.Infrastructure.xml) names as needed
$cssFile = "custom.level2branding.css"
$siteLogo = "ContosoNavLogo.png"
$provisioningTemplate = "Custom.Level2Branding.Infrastructure.xml"

# Set the directory to the solution folder just in case. In this example, it is in the Branding directory under the current user's My Documents
Set-location "$env:USERPROFILE\Documents\Branding\AlternativeCSS\solution"

if ([string]::IsNullOrEmpty($targetSiteUrl))
{
    $targetSiteUrl = $targetWebUrl
}
    
Write-Output "`nSetting Level 2 Branding on target web: $($targetWebUrl) "
Write-Output "`tTarget asset location : $($targetSiteUrl)"

try
{
	# Set default variables values
	$rootPath = $targetSiteUrl.Substring($targetSiteUrl.IndexOf('/',8))
	$alternateCssPath = "/SiteAssets/$cssFile"
	$logoPath = "/SiteAssets/$siteLogo"

	# If we are to be serving branding assets locally for now, no reason to provision.
    # Be sure to run Gulp Serve in another process (Command Shell or PowerShell)
	if ($serveLocal)
	{
		Write-Output "`tNot provisioning branding assets - expecting local development hosting"
        Connect-PnPOnline $targetSiteUrl -CurrentCredentials		

		# Change root path to local host
		$rootPath = "http://localhost:3000"
	}
	else
	{
		Connect-PnPOnline $targetSiteUrl -CurrentCredentials
		Write-Output "`tProvisioning asset files to $($targetSiteUrl)"
        Apply-PnPProvisioningTemplate -Path ".\templates\$provisioningTemplate" -Handlers Files

		# If the asset and target locations are different, then open up the target web now
		if($targetSiteUrl -ne $targetWebUrl)
		{	
			Disconnect-PnPOnline
			Connect-PnPOnline $targetSiteUrl -CurrentCredentials
		}
	}

	# Set the alternative css and logo urls
	$altCssUrl = "$($rootPath)$($alternateCssPath)"
	$logoUrl = "$($rootPath)$($logoPath)"
	Write-Output "`tSetting alternative css to $($altCssUrl)"
    Set-PnPWeb -AlternateCssUrl $altCssUrl -SiteLogoUrl $logoUrl	
	    
    # Embed JavaScript using custom action
	Write-Output "`n`tSetting Custom Action to Embed JavaScript"
    Apply-PnPProvisioningTemplate -Path ".\templates\$provisioningTemplate" -Parameters @{"InfrastructureSiteUrl"=$rootPath}
	Write-Output "Alternative CSS applied."
}
catch
{
    Write-Host -ForegroundColor Red "Exception occurred!" 
    Write-Host -ForegroundColor Red "Exception Type: $($_.Exception.GetType().FullName)"
    Write-Host -ForegroundColor Red "Exception Message: $($_.Exception.Message)"
}

