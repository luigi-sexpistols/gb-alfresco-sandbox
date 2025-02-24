Write-Debug "Installing NuGet package provider..."
Install-PackageProvider -Force -Name NuGet -MinimumVersion 2.8.5.201

Write-Debug "Installing AWS tools installer..."
Install-Module -Force -Name AWS.Tools.Installer

Write-Host "Done."