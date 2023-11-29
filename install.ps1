# Set the repository owner and name
$OWNER = "your-github-username"
$REPO = "your-repository-name"

# Determine OS and architecture
$OS = if ($PSVersionTable.PSVersion.Major -lt 6 -or $IsWindows) { "windows" } else { "linux" }
$ARCH = if ([IntPtr]::Size -eq 8) { "x86_64" } else { "x86" }

# Get the latest release asset download URL for the current OS and architecture
$ASSET_URL = Invoke-RestMethod -Uri "https://api.github.com/repos/$OWNER/$REPO/releases/latest" |
    Select-Object -ExpandProperty assets |
    Where-Object { $_.name -match $OS -and $_.name -match $ARCH } |
    Select-Object -ExpandProperty browser_download_url

# Download and unzip the asset
Invoke-WebRequest -Uri $ASSET_URL -OutFile "latest_release.zip"
Expand-Archive -Path "latest_release.zip" -DestinationPath "$HOME/bin"

# Clean up
Remove-Item "latest_release.zip"
