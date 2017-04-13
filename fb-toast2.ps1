## This script is without any warranty, run at your own risk ##
## v0.2
# Updated on 4/13/2017
##FlameBoss Toast Notification Command
## This script is very much a work in progress
## To execute run fb-toast -DoneMeatTemp '195 -RawURL "https://myflameboss.com/cooks/#####/raw"

## Notification code was created by:https://gist.github.com/altrive/72594b8427b2fff16431


Param(
  [string]$DoneMeatTemp,
  [string]$RawURL
)

function tempcheck {
param ($DoneMeatTemp, $RawURL)
## Get Data
$TempC = Invoke-WebRequest $RawURL | ConvertFrom-Csv | select meat_temp1,pit_temp -Last 1

$TestVar = $TempC.meat_temp1
$TempF =  ((32+($TestVar/10)*1.8))
$PitTempF = ((32+($TempC.pit_temp/10)*1.8))

$PCTCooked = $TempF / $DoneMeatTemp

## Code Block for Notification
$ErrorActionPreference = "Stop"

#$notificationTitle = "Notification: " + [DateTime]::Now.ToShortTimeString()
$notificationTitle = "Current Temp: " + $TempF + " Pit Temp: " + $PitTempF + " Completion: " + $PCTCooked

[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
$template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText01)

#Convert to .NET type for XML manipuration
$toastXml = [xml] $template.GetXml()
$toastXml.GetElementsByTagName("text").AppendChild($toastXml.CreateTextNode($notificationTitle)) > $null

#Convert back to WinRT type
$xml = New-Object Windows.Data.Xml.Dom.XmlDocument
$xml.LoadXml($toastXml.OuterXml)

$toast = [Windows.UI.Notifications.ToastNotification]::new($xml)
$toast.Tag = "PowerShell"
$toast.Group = "PowerShell"
$toast.ExpirationTime = [DateTimeOffset]::Now.AddMinutes(5)
#$toast.SuppressPopup = $true

If ($tempF -ne $DoneMeatTemp) {$notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("PowerShell");
$notifier.Show($toast);} 

#$notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("PowerShell")
#$notifier.Show($toast);
## End Notify

}

Do {tempcheck -DoneMeatTemp $DoneMeatTemp -RawURL $RawURL; Start-Sleep -Seconds 300 } while ($tempf -ne $DoneMeatTemp) 


