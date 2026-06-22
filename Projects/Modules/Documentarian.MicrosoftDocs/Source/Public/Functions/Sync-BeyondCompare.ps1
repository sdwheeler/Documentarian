# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

function Sync-BeyondCompare {

    [cmdletbinding()]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string]$Path
    )

    if (Test-Path "${env:ProgramFiles}\Beyond Compare 5\BComp.exe") {
        $bcomp = "${env:ProgramFiles}\Beyond Compare 5\BComp.exe"
    } elseif (Test-Path "${env:ProgramFiles}\Beyond Compare 4\BComp.exe") {
        $bcomp = "${env:ProgramFiles}\Beyond Compare 4\BComp.exe"
    } else {
        Write-Error 'Beyond Compare not found. Please install Beyond Compare and try again.'
        return
    }

    ### Get-GitStatus comes from the posh-git module.
    $gitStatus = Get-GitStatus
    if ($gitStatus) {
        $reponame = $gitStatus.RepoName
    } else {
        Write-Warning 'Not a git repo.'
        return
    }
    $repoPath = $global:git_repos[$reponame].path
    $ops = Get-Content $repoPath\.openpublishing.publish.config.json |
        ConvertFrom-Json -Depth 10 -AsHashtable
    $srcPath = $ops.docsets_to_publish.build_source_folder
    if ($srcPath -eq '.') { $srcPath = '' }

    $basePath = Join-Path $repoPath $srcPath '\'
    $mapPath = Join-Path $basePath $ops.docsets_to_publish.monikerPath
    $monikers = Get-Content $mapPath | ConvertFrom-Json -Depth 10 -AsHashtable
    $startPath = (Get-Item $Path).fullname

    $vlist = $monikers.keys | ForEach-Object { $monikers[$_].packageRoot }
    if ($startpath) {
        $relPath = $startPath -replace [regex]::Escape($basepath)
        $version = ($relPath -split '\\')[0]
        foreach ($v in $vlist) {
            if ($v -ne $version) {
                $target = $startPath -replace [regex]::Escape($version), $v
                if (Test-Path $target) {
                    Start-Process -Wait $bcomp -ArgumentList $startpath, $target
                }
            }
        }
    } else {
        Write-Error "Invalid path: $Path"
    }

}
