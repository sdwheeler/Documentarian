# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

function Test-YamlTOC {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [ValidateScript({ Test-Path $_ -PathType Container })]
        [string]$Path
    )

    $Path = (Resolve-Path $Path).Path

    # Find the TOC files
    $tocList = Get-ChildItem $Path -Filter 'toc.yml' -Recurse -File |
        Where-Object { $_.FullName -notmatch 'bread' }

    if ($tocList.Count -eq 0) {
        Write-Warning "No TOC.yml files found in path: $Path"
        return
    }

    # Find all content files
    $fileList = Get-ChildItem $Path -Include *.md, *.yml -Recurse -File |
        Where-Object { $_.FullName -notmatch 'bread.+\\toc.yml' }

    $statusList = foreach ($file in $fileList) {
        [pscustomobject]@{
            FileExists  = $true
            IsInTOC     = $false
            FileName    = $file.FullName
            TOCFileName = ''
        }
    }

    #Process TOC files
    $hrefPattern = '\s*href:\s+([\w\-\._/]+)\s*$'
    foreach ($toc in $tocList) {
        $tocBasePath = Split-Path $toc.FullName -Parent
        $hrefList = (Select-String -Pattern $hrefPattern -Path $toc.FullName).Matches |
            ForEach-Object { $_.Groups[1].Value }

        foreach ($href in $hrefList) {
            $filePath = Join-Path $tocBasePath $href
            if ($filePath -in $fileList.FullName) {
                $statusList.Where({ $_.FileName -eq $filePath }).ForEach({
                    $_.IsInTOC = $true
                    $_.TOCFileName = $toc.FullName
                })
            } else {
                $statusList += [pscustomobject]@{
                    FileExists  = $false
                    IsInTOC     = $true
                    FileName    = $filePath
                    TOCFileName = $toc.FullName
                }
            }
        }
    }

    # Output results
    $statusList | Where-Object { -not $_.FileExists -or -not $_.IsInTOC }
}
