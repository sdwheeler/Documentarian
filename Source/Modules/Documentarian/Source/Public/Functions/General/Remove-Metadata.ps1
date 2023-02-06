function Remove-Metadata {

    param(
        [Parameter()]
        [SupportsWildcards()]
        [string]$Path,
        [string[]]$KeyName,
        [switch]$Recurse
    )

    foreach ($file in (Get-ChildItem -Path $Path -Recurse:$Recurse)) {
        $file.name
        $metadata = Get-Metadata -Path $file
        $mdtext = Get-ContentWithoutHeader -Path $file

        foreach ($key in $KeyName) {
            if ($metadata.ContainsKey($key)) {
                $metadata.Remove($key)
            }
        }

        Set-Content -Value (hash2yaml $metadata) -Path $file -Force -Encoding utf8
        Add-Content -Value $mdtext -Path $file -Encoding utf8
    }

}
