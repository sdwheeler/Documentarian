function Get-ContentWithoutHeader {

    [CmdletBinding()]
    param(
        [string]$Path
    )

    $doc = Get-Content $path -Encoding UTF8
    $hasFrontmatter = Select-String -Pattern '^---$' -Path $path
    $start = 0
    $end = $doc.count

    if ($hasFrontmatter) {
        $start = $hasFrontmatter[1].LineNumber
    }
    $doc[$start..$end]

}
