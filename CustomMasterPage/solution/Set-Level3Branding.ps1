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

#===================================================================================
#
# This is the main entry point for the deployment process
#
#===================================================================================

param(
	[Parameter(Mandatory = $true, HelpMessage="Enter the URL of the target site, e.g. 'https://intranet.mydomain.com/sites/targetSite'")]
    [String]
    $targetSiteUrl,

    [Parameter(Mandatory = $false, HelpMessage="Serve assets from localhost, default is false")]
    [switch]
    $serveLocal
)


#===================================================================================
# Func: Get-ScriptDirectory
# Desc: Get the script directory from variable
#===================================================================================
function Get-ScriptDirectory
{
  $Invocation = (Get-Variable MyInvocation -Scope 1).Value
  Split-Path $Invocation.MyCommand.Path
}

#===================================================================================
# Func: ApproveMasterPageGallery
# Desc: Checkout and check in all files in MPG
# Comments: Adapted from https://skodvinhvammen.wordpress.com/2015/10/23/download-files-and-folders-using-office-365-dev-pnp-powershell-cmdlets/
#===================================================================================
function ApproveMasterPageGallery($url, [int]$levels)
{
	$web = Get-PnPWeb

    $root = $web.GetFolderByServerRelativeUrl($url);
    $files = $root.Files;
    $web.Context.Load($root);
    $web.Context.Load($files);
    $web.Context.ExecuteQuery();
 
    foreach($file in $files)
    {   
	    Write-Output "Publishing: $($file.Name)"
        Set-PnPFileCheckedOut -Url $file.serverRelativeUrl
		Set-PnPFileCheckedIn -Url $file.serverRelativeUrl -CheckinType MajorCheckIn -Comment "Initial Publish"
    }
 
    if($levels -gt 0)
    {
        $folders = $root.Folders;
        $web.Context.Load($folders);
        $web.Context.ExecuteQuery();
 
        foreach($folder in $folders)
        {
            ApproveMasterPageGallery $folder.ServerRelativeUrl ($levels - 1)
        }    
    }
}

#===================================================================================
# Set current script location
#===================================================================================
$currentDir = Get-ScriptDirectory
Set-Location -Path $currentDir


#===================================================================================
# Confirm the environment
#===================================================================================
Write-Output "`nSetting Level 3 Branding on target site: $($targetSiteUrl) "

try
{
    Connect-PnPOnline $targetSiteUrl -CurrentCredentials
    $publishingWebID = "94c94ca6-b32f-4da9-a9e3-1f3d343d7ecb"
    #$publishingSiteID = "f6924d36-2fa8-4f0b-b16d-06b7250180fa"
    #Get-PnPFeature -Identity $publishingSite -Scope Site
    $publishingWebEnabled = Get-PnPFeature -Identity $publishingWebID -Scope Web

    if ($publishingWebEnabled -ne $null)
    {
        Write-Output "Publishing Web Enabled: Using Publishing provisioning template"
    	Apply-PnPProvisioningTemplate -Path .\templates\root-publishing.xml
    }
    else
    {
    	Apply-PnPProvisioningTemplate -Path .\templates\root.xml
    }

	$webRootPath = $targetSiteUrl.Substring($targetSiteUrl.IndexOf('/',8))
	$masterUrl = "$webRootPath/_catalogs/masterpage/custom-branding/contoso.master"
	$logoUrl = "$webRootPath/SiteAssets/ContosoNavLogo.png"

	Write-Output "`tSetting master page to $($masterUrl)"

	#must approve MPG files for now as pnp:FileLevel Level="Published" does not appear to be working as expected
	ApproveMasterPageGallery "$($webRootPath)/_catalogs/masterpage/custom-branding" 4

	Set-PnPWeb -MasterUrl $masterUrl -SiteLogoUrl $logoUrl

    Write-Output "`tCustom Master Page deployment complete"
}
catch
{
    Write-Error "Exception occurred!" 
    Write-Error "Exception Type: $($_.Exception.GetType().FullName)"
    Write-Error "Exception Message: $($_.Exception.Message)"
} 
