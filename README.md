# Ignite 2016 - Customizing and Branding SharePoint Online Team Sites Demos #

Contains the following demos:

Office 365 Themes and SharePoint Online custom themes

## Original Repository ##
(https://github.com/eoverfield/Ignite2016-TeamSiteBranding)

## Learn best practices for customizing and branding SharePoint Team Sites ##
(https://channel9.msdn.com/Events/Ignite/2016/BRK3025)

## Update: ##
This project is in the process of being updated to work on-premises. Some enhancements to the cmdlets are required to make this happen

## Pre-requisites ##
Please install the SharePoint PNP PowerShell Module for 2013 or 2016
More info here: (https://docs.microsoft.com/en-us/powershell/sharepoint/sharepoint-pnp/sharepoint-pnp-cmdlets?view=sharepoint-ps)


1. Open a PowerShell command prompt as Administrator and run the following command for SharePoint 2013:

	`Install-Module SharePointPnPPowerShell2013 -SkipPublisherCheck -AllowClobber`

	  or for SharePoint 2016 run:

	`Install-Module SharePointPnPPowerShell2016 -SkipPublisherCheck -AllowClobber`

2. When prompted, select "Yes to All" to allow the install from the PowerShell Gallery

3. In PowerShell, execute the following command (update the url to reflect a site from your on-premises environment):
	
	`Connect-PnPOnline -Url http://portal.contoso.local/sites/yourSite -CurrentCredentials`

4. You can select to "Do not allow" PnP PowerShell Telemetry. If the command returns without an error, you should be good to go.