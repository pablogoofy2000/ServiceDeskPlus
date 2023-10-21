---
external help file: ServiceDeskPlus-help.xml
Module Name: ServiceDeskPlus
online version:
schema: 2.0.0
---

# Get-SDPChangeRoles

## SYNOPSIS
Return the Custom roles from a change.
It DOES NOT include Change Requestror, Change Manager, Change Owner

## SYNTAX

```
Get-SDPChangeRoles [-changeID] <Int32> [-UseSDPDemo] [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -changeID
Change ID of the Change you want to get the roles

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: 0
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -UseSDPDemo
Use this switch to switch to Demo SDP

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
