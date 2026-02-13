---
external help file:
Module Name:
online version:
schema: 2.0.0
---

# Export-MonikerContent

## SYNOPSIS

Exports content from markdown files based on specified moniker conditions.

## SYNTAX

```
Export-MonikerContent [-Path] <String[]> [-Moniker] <String> [[-OutputPath] <String>]
 [<CommonParameters>]
```

## DESCRIPTION

This cmdlet processes markdown files and extracts content based on the specified moniker range. It
uses comparison operators in the moniker range to determine which content to include in the output.

The command skips any files that don't have a `.md` extension. The output file are written to the
**OutputPath** location with the target moniker appended to original file name. For example, if the
original file is `example.md` and the moniker is `mvc-150`, the output file is named
`example_mvc_150.md`.

## EXAMPLES

### EXAMPLE 1

```powershell
Export-MonikerContent -Path C:\Docs\*.md -Moniker mvc-150 -OutputPath C:\FilteredDocs
```

This command processes all markdown files in the `C:\Docs` directory, filters the content based on
the moniker `mvc-150`, and saves the output to the `C:\FilteredDocs` directory.

## PARAMETERS

### -Moniker

The moniker value to filter the content by.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutputPath

The folder path where the filtered content will be saved.
If not specified, the current
directory is used.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: .
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path

The path(s) to the markdown files or directories containing markdown files to process.
Wildcards are supported.

```yaml
Type: System.String[]
Parameter Sets: (All)
Aliases: PSPath

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: True
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose,
-WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String[]

You can pipe a collection of strings representing file paths to the **Path** parameter.

## OUTPUTS

### System.IO.FileInfo

## NOTES

## RELATED LINKS
