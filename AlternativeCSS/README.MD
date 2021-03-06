# SharePoint  Apply Alternative CSS / JavaScript Embed #

This is demonstration code on how to set Alternative CSS and Embed JavaScript within SharePoint On-Premises using PnP PowerShell without customizing the Master Page. This was tested using SharePoint 2013
The PowerShell script was modified to leverage the credentials of the user running the script. (-currentCredentials flag when connecting using Connect-PNPOnline). The account running the script will require the neccessary permissions to make the updates. 
This PowerShell script opens a SharePoint on-premises  site, uploads necessary assets such as css and js files to an assets site, i.e. a site collection root site and then sets the alternative CSS and custom logo. A custom action is then provisioned that will embed JavaScript into the <head> tag that will then load our custom .js file.

Concepts and code adapted from the following resources. A big thank you to the Microsoft PnP team for doing all of the heavy lifting in providing not only the PnP project, but also the CSS, JS and other assets used in this demo.
<a href="https://github.com/OfficeDev/PnP-Tools/tree/master/Solutions/SharePoint.UI.Responsive">https://github.com/OfficeDev/PnP-Tools/tree/master/Solutions/SharePoint.UI.Responsive</a>.

>**Note**: This is an **Open Source** project, and any contribution from the community
is more than welcome. 
	
# Setup Instructions #
In order to setup the solution and to apply a custom theme on a target Web, you simply need to:
* [Download the files included in this solution](#download)
* [Setup software requirements](#requirements)
* [Execute the *Set-Level2Branding.ps1* cmdlet within the solution folder](#execute)

<a name="download"></a>
## Download the files
You can download the files manually, one by one, or you can download the entire branch

<a name="requirements"></a>
## Setup software requirements
This solution requires the OfficeDevPnP.PowerShell commands, which you can install
from the following link:

* <a href="https://github.com/OfficeDev/PnP-PowerShell/releases">OfficeDevPnP.PowerShell Release - Minumum relase for this script - version 2.7.1609.3 or later</a>

If you want, you can also read the following 
<a href="https://github.com/OfficeDev/PnP-PowerShell#installation">instructions</a>
for further details about installing OfficeDevPnP.PowerShell.

# Installing pre-reqs #

Install NodeJs
Install Ruby
Install Sass
Install gulp-cli (or grunt, but webapp by Yeoman team uses gulp)
	npm install -g gulp-cli
	
The pre-reqs are necessary if you want to re-compile css and js included in this package, or if you want to serve files locally for testing. Once the pre-reqs are installed, execute the comment:
*gulp serve*
from this folder.

<a name="execute"></a>
## Execute the *Set-Level2Branding.ps1* cmdlet
Once you have installed the OfficeDevPnP.PowerShell commands, you can simply open a 
PowerShell console, go to the path where you stored the files, look within the "solution" folder and execute the *Set-Level2Branding.ps1*
cmdlet, which is included in the
<a href="./solution/Set-Level2Branding.ps1">solution/Set-Level2Branding.ps1</a> script file of this solution.

The *Set-Level2Branding* cmdlet accepts the following parameters:
* **targetWebUrl**: it is a mandatory parameter, which declares what web to apply the custom components, like for example: https://intranet.mydomain.com/sites/targetSite
* **TargetSiteUrl**: it is an optional parameter, which declares the web where components assets including the CSS/JS/Images. If this parameter is not provided, then TargetWebUrl is assumed as the provisions asset site as well, such as: https://intranet.mydomain.com/sites/targetSite\\
* **ServeLocal**: it is an optional flag, if used, SharePoint will be told to look at the localhost for serving JS and CSS files during development. Also, be sure to execute "gulp serve" within this folder to spin up the local web server.

Here you can see a couple of examples about how to invoke the *Set-Level2Branding* cmdlet:

###EXAMPLE 1
```PowerShell
PS C:\> .\Set-Level2Branding.ps1 -TargetWebUrl "https://intranet.mydomain.com/sites/targetSite" --ServeLocal $true
```

The example above provisions assets to the site collection root web, https://intranet.mydomain.com/sites/targetSite, uses the credentials of the current logged in userl, and also has SharePoint set to direct browsers to the localhost for custom CSS/JS/Images.

###EXAMPLE 2
```PowerShell
PS C:\> $creds = Get-Credential
PS C:\> .\Set-Level2Branding.ps1 -TargetSiteUrl "https://intranet.mydomain.com/sites/targetSite" 
```

The example above provisions assets to the same location as where the custom components should be applied. The user's credentials are  provided through the *$creds* variable and SharePoint will host the custom files as well.

<a name="disable"></a>
# Disable Alternative CSS and JavaScript Embed#
The *Set-Level2Branding* cmdlet accepts the following parameter:
* **targetWebUrl**: it is a mandatory parameter, which declares what web to deactivate the custom components, for example: https://intranet.mydomain.com/sites/targetSite


###EXAMPLE 1
```PowerShell
PS C:\> .\Disable-Level2Branding.ps1 -TargetWebUrl "https://intranet.mydomain.com/sites/targetSite"

<a name="overview"></a>
# Solution Overview #
The solution leverages the PnP to upload and set the Alternative CSS, custom logo and embed custom JavaScript without having to update the master page using Custom Actions.

# Helpful Links #

PnP Deploying Custom Theming Inspiration Project
https://github.com/OfficeDev/PnP/tree/master/Samples/Branding.DeployCustomThemeWeb

PnP Responsive UI Inspiration Project
https://github.com/OfficeDev/PnP-Tools/tree/master/Solutions/SharePoint.UI.Responsive