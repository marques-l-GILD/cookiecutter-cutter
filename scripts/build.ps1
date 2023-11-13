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
  & $py -m venv build/ccc-py
  Get-ChildItem -Path build/ccc-py

  info "Activating virtualenv"
  & "./build/ccc-py/bin/Activate.ps1" -Prompt "venv:ccc-py"

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

  $sys = "windows"

  switch ($env:PROCESSOR_ARCHITECTURE) {
    "AMD64" { $arch = 'amd64' }
    "ARM64" { $arch = 'arm64' }
    default { die "Unsupported architecture: $env:PROCESSOR_ARCHITECTURE" }
  }

  New-Item -ItemType Directory -Force -Path packages
  Compress-Archive -Path build/ccc-py -DestinationPath "packages/ccc_${sys}_${arch}.zip"

  if ($env:GITHUB_OUTPUT) {
    Add-Content -Path $env:GITHUB_OUTPUT -Value "package=ccc_${sys}_${arch}.zip"
  }
}

function info {
  param (
    [Parameter(Mandatory=$true)]
    [string]$str
  )
  Write-Host -ForegroundColor Green "[INFO ] $str"
}

function die  {
  param (
    [Parameter(Mandatory=$true)]
    [string]$str
  )
  Write-Error "[FATAL] $str"
  exit 1
}

Main
