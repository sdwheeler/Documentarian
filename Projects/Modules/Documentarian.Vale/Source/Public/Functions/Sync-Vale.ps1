# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#region    RequiredFunctions

$SourceFolder = $PSScriptRoot
while ('Source' -ne (Split-Path -Leaf $SourceFolder)) {
  $SourceFolder = Split-Path -Parent -Path $SourceFolder
}
$RequiredFunctions = @(
  Resolve-Path -Path "$SourceFolder/Public/Functions/Invoke-Vale.ps1"
)
foreach ($RequiredFunction in $RequiredFunctions) {
  . $RequiredFunction
}

#endregion RequiredFunctions

function Sync-Vale {
  [CmdletBinding()]
  param(
    [Parameter(Position = 0)]
    [string]$Path
  )

  begin {
    $SyncParameters = @(
      'sync'
    )
  }
  process {
    if (![string]::IsNullOrEmpty($Path)) {
      $SyncParameters += @('--config', $Path)
    }

    $null = Invoke-Vale -ArgumentList $SyncParameters
  }
}
