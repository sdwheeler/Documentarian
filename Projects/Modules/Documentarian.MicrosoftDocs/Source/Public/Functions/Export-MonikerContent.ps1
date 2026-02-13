# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

function Export-MonikerContent {
    [CmdletBinding()]
    [OutputType([System.IO.FileInfo])]
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [SupportsWildcards()]
        [Alias("PSPath")]
        [string[]]$Path,

        [Parameter(Mandatory, Position = 1)]
        [string]$Moniker,

        [Parameter(Position = 2)]
        [string]$OutputPath = '.'
    )

    begin {
        if (Test-Path -Path $OutputPath) {
            $OutputPath = (Resolve-Path -Path $OutputPath).Path
        } else {
            $OutputPath = New-Item -ItemType Directory -Path $OutputPath -Force
        }
        $monikerStartPattern = '::: moniker range="(?<comparison>[=\>\<]{1,2})\s*(?<name>.+)"'
        $monikerEndPattern = '::: moniker-end'

        function parseMoniker {
            param (
                [string]$mdString
            )
            if ($mdString -match $monikerStartPattern) {
                @{
                    Name = $matches['name'].Trim()
                    Comparison = $matches['comparison']
                }
            }
        }
    }

    process {
        foreach ($path in $Path) {
            $getChildItemSplat = @{
                Path        = $path
                File        = $true
                ErrorAction = 'SilentlyContinue'
            }
            $resolvedFiles = Get-ChildItem @getChildItemSplat

            foreach ($file in $resolvedFiles) {
                if ($file.Extension -ne '.md') {
                    Write-Verbose "Skipping non-markdown file: '$($file.FullName)'"
                    continue
                }
                $outFilePath = Join-Path -Path $OutputPath "$($file.BaseName)_$Moniker.md"
                $mdContent = Get-Content -Path $file.FullName
                $currentMoniker = @{
                    Name = ''
                    Comparison = '='
                }
                $filteredContent = @()
                foreach ($line in $mdContent) {
                    if ($line -match $monikerStartPattern) {
                        $currentMoniker = parseMoniker $line
                    }
                    if ($currentMoniker.Name -eq '') {
                        $filteredContent += $line
                    } else {
                        # check if the current moniker range includes the specified moniker
                        switch ($currentMoniker.Comparison) {
                            '=' {
                                if ($Moniker -eq $currentMoniker.Name) {
                                    $filteredContent += $line
                                }
                            }
                            '>=' {
                                if ($Moniker -ge $currentMoniker.Name) {
                                    $filteredContent += $line
                                }
                            }
                            '>' {
                                if ($Moniker -gt $currentMoniker.Name) {
                                    $filteredContent += $line
                                }
                            }
                            '<=' {
                                if ($Moniker -le $currentMoniker.Name) {
                                    $filteredContent += $line
                                }
                            }
                            '<' {
                                if ($Moniker -lt $currentMoniker.Name) {
                                    $filteredContent += $line
                                }
                            }
                        }
                    } # end else for moniker range check
                    if ($line -match $monikerEndPattern) {
                        $currentMoniker = @{
                            Name = ''
                            Comparison = '='
                        }
                    }
                } #end foreach line
                Write-Verbose "Exported filtered content to '$outFilePath'"
                $filteredContent | Out-File -FilePath $outFilePath -Encoding utf8
                Get-Item -Path $outFilePath
            } #end foreach file
        } #end foreach path
    } # end process block
}