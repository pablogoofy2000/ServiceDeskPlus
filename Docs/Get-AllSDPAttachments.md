---
external help file: ServiceDeskPlus-help.xml
Module Name: ServiceDeskPlus
online version:
schema: 2.0.0
---

# Get-AllSDPAttachments

## SYNOPSIS
Downloades all tickets from a requests

## SYNTAX

```
Get-AllSDPAttachments [-requestID] <Int32> [[-OutFolder] <String>] [-urlPath] [-UseSDPDemo]
 [<CommonParameters>]
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

### -OutFolder
Path for the files to be downloaded.
If not set default is: C:Temp\$($requestID)\$($name)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: C:\temp
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -requestID
Request ID from which the attachments

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

### -urlPath
Use this switch to just output the path to the downloads instead of actually download them

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
