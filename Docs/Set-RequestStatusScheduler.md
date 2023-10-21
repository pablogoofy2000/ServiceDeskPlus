---
external help file: ServiceDeskPlus-help.xml
Module Name: ServiceDeskPlus
online version:
schema: 2.0.0
---

# Set-RequestStatusScheduler

## SYNOPSIS
Set a request  a status to change a later date

## SYNTAX

```
Set-RequestStatusScheduler [-RequestID] <String> [[-Comments] <String>] [-ChangeToStatus <String>]
 [-Status <String>] [-ScheduledTime <String>] [-UseSDPDemo] [<CommonParameters>]
```

## DESCRIPTION
Set a request  a status to change a later date

## EXAMPLES

### EXAMPLE 1
```
Set-RequestStatusScheduler -RequestID 168321 -ScheduledTime "25/03/2022 03:45 PM" -ChangeToStatus Open -UseSDPDemo -comments "blabla" -Status Onhold
```

## PARAMETERS

### -ChangeToStatus
{{ Fill ChangeToStatus Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Comments
Any comments / reason of why the request wsa put on hold.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -RequestID
The ServiceDesk Plus Request ID number.
(integer)

```yaml
Type: String
Parameter Sets: (All)
Aliases: id

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ScheduledTime
Time and date whe the status will be changed back "25/03/2022 03:45 PM" or "25/03/2022"

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Status
{{ Fill Status Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -UseSDPDemo
{{ Fill UseSDPDemo Description }}

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

### xxx
## NOTES

## RELATED LINKS
