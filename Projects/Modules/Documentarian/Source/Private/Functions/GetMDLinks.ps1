﻿# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#region    RequiredFunctions

$SourceFolder = $PSScriptRoot
while ('Source' -ne (Split-Path -Leaf $SourceFolder)) {
    $SourceFolder = Split-Path -Parent -Path $SourceFolder
}
$RequiredFunctions = @(
    Resolve-Path -Path "$SourceFolder/Private/Functions/IsInCodeBlock.ps1"
)
foreach ($RequiredFunction in $RequiredFunctions) {
    . $RequiredFunction
}

#endregion RequiredFunctions

function GetMDLinks {
    param(
        $mdlinks, # regex matches for [label](target)
        $reflinks # regex matches for [label][ref]
    )


    foreach ($mdlink in $mdlinks.Matches) {
        # Skip INCLUDE and tab links
        if (-not $mdlink.Value.Trim().StartsWith('[!INCLUDE') -and
            -not $mdlink.Value.Trim().Contains('#tab/')
        ) {
            $linkitem = [pscustomobject]([ordered]@{
                    mdlink = ''
                    target = ''
                    ref    = ''
                    label  = ''
                })
            switch ($mdlink.Groups) {
                { $_.Name -eq 'link' } { $linkitem.mdlink = $_.Value }
                { $_.Name -eq 'target' } { $linkitem.target = $_.Value }
                { $_.Name -eq 'label' } { $linkitem.label = $_.Value }
            }
            $linkitem
        }
    }

    foreach ($reflink in $reflinks.Matches) {
        $linkitem = [pscustomobject]([ordered]@{
                mdlink = ''
                target = ''
                ref    = ''
                label  = ''
            })
        switch ($reflink.Groups) {
            { $_.Name -eq 'link' } { $linkitem.mdlink = $_.Value }
            { $_.Name -eq 'label' } { $linkitem.label = $_.Value }
            { $_.Name -eq 'ref' } { $linkitem.ref = $_.Value }
        }
        $linkitem
    }
}
