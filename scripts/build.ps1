#!/usr/bin/env pwsh
# vim: sts=2 sw=2 et ai

$ErrorActionPreference = "Stop"

# builds a distribution of cookiecutter-cutter
function Main {
  $py = ""
  if (Get-Command python3 -ErrorAction SilentlyContinue) {
    $py = (Get-Command python3).Source
  } elseif (Get-Command python -ErrorAction SilentlyContinue) {
    $py = (Get-Command python).Source
  }

  if ([string]::IsNullOrEmpty($py)) {
    die "No python interpreter found"
  }

  info "Using python interpreter: $py"

  info "Testing that $py works"
  & $py --help 2>&1 | Out-Null || die "Python interpreter $py is not working"

  info "Using python version: $(& $py --version)"

  New-Item -ItemType Directory -Force -Path build

  info "Creating virtualenv"
  & $py -m venv --copies build/ccc-py

  info "Activating virtualenv"
  if (Test-Path -Path build/ccc-py/Scripts/Activate.ps1) {
    # on windows, the venv activation script is in a different location
    & build/ccc-py/Scripts/Activate.ps1 -Prompt "venv:ccc-py"
  } else {
    & build/ccc-py/bin/Activate.ps1 -Prompt "venv:ccc-py"
  }

  try {
    info "Validating virtualenv python installation"
    Get-Command python
    & python --version

    info "Updating pip"
    & python -m pip install --upgrade pip

    info "Installing cookiecutter"
    & pip install cookiecutter

    info "Testing cookiecutter"
    & cookiecutter --version
  } finally {
    if (Get-Command deactivate -ErrorAction SilentlyContinue -CommandType Function) {
      info "Deactivating virtualenv"
      deactivate
    }
  }

  info "Detecting architecture"

  # we are assuming that powershell is running on windows
  # even though we can technically run powershell on linux
  # or macOS.
  #
  # note that if you are testing this script on linux or
  # macOS, you will need to set the PROCESSOR_ARCHITECTURE
  # environment variable, and that the output archive will
  # still be named as if it were running on windows. on macOS,
  # this reported architecure may not reflect the actual
  # architecture of the python interpreter, in the case that it
  # is a universal2 build.
  $sys = "windows"

  switch ($env:PROCESSOR_ARCHITECTURE) {
    "AMD64" { $arch = 'amd64' }
    "ARM64" { $arch = 'arm64' }
    default { die "Unsupported architecture: $env:PROCESSOR_ARCHITECTURE" }
  }

  $package = "ccc_${sys}_${arch}.zip"
  New-Item -ItemType Directory -Force -Path packages
  Compress-Archive -Path build/ccc-py -DestinationPath "packages/$package"

  # Save the current location
  Push-Location

  # Change the current directory to 'packages'
  Set-Location -Path packages

  # Generate SHA256 checksum
  $hash = Get-FileHash -Path $package -Algorithm SHA256
  $hash.Hash | Out-File -FilePath "$package.sha256"

  # Return to the original location
  Pop-Location

  if ($env:GITHUB_OUTPUT) {
    Add-Content -Path $env:GITHUB_OUTPUT -Value "package=$package"
  }
}

function info {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
  param (
    [Parameter(Mandatory = $true)]
    [string]$str
  )
  Write-Host -ForegroundColor Green "[INFO ] $str"
}

function die {
  param (
    [Parameter(Mandatory = $true)]
    [string]$str
  )
  Write-Error "[FATAL] $str"
  exit 1
}

Main
