---
external help file: Documentarian.MicrosoftDocs-help.xml
Locale: en-US
Module Name: Documentarian.MicrosoftDocs
online version: https://microsoft.github.io/Documentarian/modules/microsoftdocs/reference/cmdlets/test-yamltoc
schema: 2.0.0
title: Test-YamlTOC
---

# Test-YamlTOC

## SYNOPSIS

Validates that all entries in the TOC exist and that all files in the repository are in the TOC.

## SYNTAX

```
Test-YamlTOC [-Path] <String> [<CommonParameters>]
```

## DESCRIPTION

The command recursively searches the path provided to find `TOC.yml` files. It reads the content of
each `TOC.yml` file and resolves the full path for each entry in the TOC. The command then checks if
the file exists in the repository.

The path provided must be a folder.

## EXAMPLES

### Example 1 - Verify a TOC file

In this example, The first and third `toc.yml` items can also be ignored. The TOC contains
site-relative URL links to docs in another repository. The second item is a file that exists but
isn't in the TOC. The last item is a a false-positive result. The file doesn't exist but is in the
TOC because it's a site-relative link to an external article.

```powershell
Test-YamlTOC -Path .\docs-conceptual
```

```Output
FileExists IsInTOC FileName
---------- ------- --------
      True   False D:\Git\PS-Docs\PowerShell-Docs\reference\docs-conceptual\developer\bread\toc.yml
      True   False D:\Git\PS-Docs\PowerShell-Docs\reference\docs-conceptual\developer\scheduling-jobs-with-th…
      True   False D:\Git\PS-Docs\PowerShell-Docs\reference\docs-conceptual\toc.yml
     False    True D:\Git\PS-Docs\PowerShell-Docs\reference\docs-conceptual\powershell\utility-modules\platyp…
```

## PARAMETERS

### -Path

The path to the TOC file.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose,
-WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
