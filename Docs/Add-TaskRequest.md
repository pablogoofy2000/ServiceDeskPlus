---
external help file: ServiceDeskPlus-help.xml
Module Name: ServiceDeskPlus
online version:
schema: 2.0.0
---

# Add-TaskRequest

## SYNOPSIS
Adds a task to a request in ServiceDesk Plus

## SYNTAX

```
Add-TaskRequest [-RequestID] <Int32> [-TaskTitle] <String> [[-TaskDescription] <String>] -TaskStatus <String>
 [-Group <String>] [-Technician <String>] [-Priority <String>] [-TaskType <String>]
 [-ScheduleStartTaskTime <String>] [-ScheduleEndTaskTime <String>] [-Template <Int32>] [-UseSDPDemo]
 [<CommonParameters>]
```

## DESCRIPTION
Adds a task to a request in ServiceDesk Plus

## EXAMPLES

### EXAMPLE 1
```
extension -name "File"
File.txt
```

## PARAMETERS

### -Group
{{ Fill Group Description }}

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

### -Priority
{{ Fill Priority Description }}

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

### -RequestID
The ServiceDesk Plus Request ID number.
(integer)

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: id

Required: True
Position: 1
Default value: 0
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ScheduleEndTaskTime
{{ Fill ScheduleEndTaskTime Description }}

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

### -ScheduleStartTaskTime
Must be in this format "08/12/2021 08:00"

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

### -TaskDescription
{{ Fill TaskDescription Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -TaskStatus
{{ Fill TaskStatus Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -TaskTitle
Task Title, AKA Subject of Task

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -TaskType
{{ Fill TaskType Description }}

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

### -Technician
{{ Fill Technician Description }}

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

### -Template
{{ Fill Template Description }}

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
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

### None. You cannot pipe objects to Add-Extension.
## OUTPUTS

### System.String. Add-Extension returns a string with the extension or file name.
## NOTES

## RELATED LINKS
