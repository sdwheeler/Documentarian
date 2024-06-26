# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../Enums/ParameterAttributeKind.psm1
using module ../Classes/AttributeInfo/CredentialAttributeInfo.psm1
using module ../Classes/AttributeInfo/DontShowAttributeInfo.psm1
using module ../Classes/AttributeInfo/ExperimentalAttributeInfo.psm1
using module ../Classes/AttributeInfo/HasValidationAttributeInfo.psm1
using module ../Classes/AttributeInfo/ObsoleteAttributeInfo.psm1
using module ../Classes/AttributeInfo/PSDefaultValueAttributeInfo.psm1
using module ../Classes/AttributeInfo/SupportsWildcardsAttributeInfo.psm1
using module ../Classes/AttributeInfo/ValueFromPipelineAttributeInfo.psm1
using module ../Classes/AttributeInfo/ValueFromRemainingAttributeInfo.psm1

function Find-ParameterWithAttribute {
    [CmdletBinding()]
    [OutputType(
        [DontShowAttributeInfo],
        [ExperimentalAttributeInfo],
        [HasValidationAttributeInfo],
        [SupportsWildcardsAttributeInfo],
        [ValueFromPipelineAttributeInfo],
        [ValueFromRemainingAttributeInfo],
        [PSDefaultValueAttributeInfo],
        [CredentialAttributeInfo],
        [ObsoleteAttributeInfo]
    )]
    param(
        [Parameter(Mandatory, Position = 0)]
        [ParameterAttributeKind]$AttributeKind,

        [Parameter(Position = 1)]
        [SupportsWildcards()]
        [PSDefaultValue(Help='*', Value='*')]
        [string[]]$CommandName = '*',

        [ValidateSet('Cmdlet', 'Module', 'None')]
        [PSDefaultValue(Help='None', Value='None')]
        [string]$GroupBy = 'None'
    )
    begin {
        $cmdlets = Get-Command $CommandName -Type Cmdlet, ExternalScript, Filter, Function, Script
    }
    process {
        foreach ($cmd in $cmdlets) {
            foreach ($param in $cmd.Parameters.Values) {
                $result = $null
                foreach ($attr in $param.Attributes) {
                    if ($attr.TypeId.ToString() -eq 'System.Management.Automation.ParameterAttribute' -and
                        $AttributeKind -in 'DontShow', 'Experimental', 'ValueFromPipeline', 'ValueFromRemaining') {
                        switch ($AttributeKind) {
                            DontShow {
                                if ($attr.DontShow) {
                                    $result = [DontShowAttributeInfo]@{
                                        Cmdlet           = $cmd.Name
                                        Parameter        = $param.Name
                                        ParameterType    = $param.ParameterType.Name
                                        DontShow         = $attr.DontShow
                                        ParameterSetName = $param.ParameterSets.Keys -join ', '
                                        Module           = $cmd.Source
                                    }
                                }
                                break
                            }
                            Experimental {
                                if ($attr.ExperimentName) {
                                    $result = [ExperimentalAttributeInfo]@{
                                        Cmdlet           = $cmd.Name
                                        Parameter        = $param.Name
                                        ParameterType    = $param.ParameterType.Name
                                        DontShow         = $attr.ExperimentName
                                        ParameterSetName = $param.ParameterSets.Keys -join ', '
                                        Module           = $cmd.Source
                                    }
                                }
                                break
                            }
                            ValueFromPipeline {
                                if ($attr.ValueFromPipeline -or $attr.ValueFromPipelineByPropertyName) {
                                    $result = [ValueFromPipelineAttributeInfo]@{
                                        Cmdlet            = $cmd.Name
                                        Parameter         = $param.Name
                                        ParameterType     = $param.ParameterType.Name
                                        ValueFromPipeline = ('ByValue({0}), ByName({1})' -f $attr.ValueFromPipeline, $attr.ValueFromPipelineByPropertyName)
                                        ParameterSetName  = $param.ParameterSets.Keys -join ', '
                                        Module            = $cmd.Source
                                    }
                                }
                                break
                            }
                            ValueFromRemaining {
                                if ($attr.ValueFromRemainingArguments) {
                                    $result = [ValueFromRemainingAttributeInfo]@{
                                        Cmdlet             = $cmd.Name
                                        Parameter          = $param.Name
                                        ParameterType      = $param.ParameterType.Name
                                        ValueFromRemaining = $attr.ValueFromRemainingArguments
                                        ParameterSetName   = $param.ParameterSets.Keys -join ', '
                                        Module             = $cmd.Source
                                    }
                                }
                                break
                            }
                        }
                    } elseif ($attr.TypeId.ToString() -like 'System.Management.Automation.Validate*Attribute' -and
                        $AttributeKind -eq 'HasValidation') {
                        $result = [HasValidationAttributeInfo]@{
                            Cmdlet              = $cmd.Name
                            Parameter           = $param.Name
                            ParameterType       = $param.ParameterType.Name
                            ValidationAttribute = $attr.TypeId.ToString().Split('.')[ - 1].Replace('Attribute', '')
                            ParameterSetName    = $param.ParameterSets.Keys -join ', '
                            Module              = $cmd.Source
                        }
                    } elseif ($attr.TypeId.ToString() -eq 'System.Management.Automation.SupportsWildcardsAttribute' -and
                        $AttributeKind -eq 'SupportsWildcards') {
                        $result = [SupportsWildcardsAttributeInfo]@{
                            Cmdlet            = $cmd.Name
                            Parameter         = $param.Name
                            ParameterType     = $param.ParameterType.Name
                            SupportsWildcards = $true
                            ParameterSetName  = $param.ParameterSets.Keys -join ', '
                            Module            = $cmd.Source
                        }
                    } elseif ($attr.TypeId.ToString() -eq 'System.Management.Automation.CredentialAttribute' -and
                        $AttributeKind -eq 'IsCredential') {
                        $result = [CredentialAttributeInfo]@{
                            Cmdlet           = $cmd.Name
                            Parameter        = $param.Name
                            ParameterType    = $param.ParameterType.Name
                            IsCredential     = $true
                            ParameterSetName = $param.ParameterSets.Keys -join ', '
                            Module           = $cmd.Source
                        }
                    } elseif ($attr.TypeId.ToString() -eq 'System.Management.Automation.PSDefaultValueAttribute' -and
                        $AttributeKind -eq 'DefaultValue') {
                        $result = [PSDefaultValueAttributeInfo]@{
                            Cmdlet           = $cmd.Name
                            Parameter        = $param.Name
                            ParameterType    = $param.ParameterType.Name
                            DefaultValue     = $attr.Help
                            ParameterSetName = $param.ParameterSets.Keys -join ', '
                            Module           = $cmd.Source
                        }
                    } elseif ($attr.TypeId.ToString() -eq 'System.ObsoleteAttribute' -and
                        $AttributeKind -eq 'IsObsolete') {
                        $result = [ObsoleteAttributeInfo]@{
                            Cmdlet           = $cmd.Name
                            Parameter        = $param.Name
                            ParameterType    = $param.ParameterType.Name
                            IsObsolete       = if ($param.IsObsolete -eq $false) {
                                $false
                            } else {
                                $true
                            }
                            ParameterSetName = $param.ParameterSets.Keys -join ', '
                            Module           = $cmd.Source
                        }
                    }
                }
                if ($result) {
                    # Add a type name to the object so that the correct format gets chosen
                    switch ($GroupBy) {
                        'Cmdlet' {
                            $typename = $result.GetType().Name + '#ByCmdlet'
                            $result.psobject.TypeNames.Insert(0, $typename)
                            break
                        }
                        'Module' {
                            $typename = $result.GetType().Name + '#ByModule'
                            $result.psobject.TypeNames.Insert(0, $typename)
                            break
                        }
                    }
                    $result
                }
            }
        }
    }
}
