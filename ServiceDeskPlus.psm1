$config = Get-Content -Path ".\SDP_Config.json" | ConvertFrom-Json
$Sdp = $config.sdp
$ApiKey = $config.ApiKey
$fromAddress = $config.fromAddress
$SMTPServer = $config.SMTPServer
function update-TimeValue {
    param
    ($date)
    $value = ((New-TimeSpan -Start (Get-Date "01/01/1970") -end (Get-Date $date)).TotalSeconds *1000).ToString()
    return $value
}
function Switch-ToDemo {
    $myArray = @()
    $sdp = $config.SdpDemo
    $myArray += $sdp
    #$Uri = "http://demo.servicedeskplus.com" + "/api/v3/requests/"+ $requestID +"/tasks"
    $ApiKey = (Get-Variable -name demoapiKey).value
    if ($ApiKey){
        Write-Host "Demo Api Key Exists already"
    }
    else {
        #$demoapikey = Read-Host -Prompt "Provide SDP Demoapikey or store the key in `$demoapikey and run again."
        #$ApiKey = (Get-Variable -name demoapiKey).value
        $ApiKey = Read-Host -Prompt "Provide SDP Demoapikey or store the key in `$demoapikey and run again."
        $global:demoapikey = $ApiKey
    }
    $myArray += $ApiKey
    return $myArray
}
function Send-MailError {
    [CmdletBinding()]
    param
    (
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
    [String]
    $body
    )
    $SMTPServer = "10.0.1.208"
    $mailSubject = "##RE-$RequestID## Error"
    #$To= "Paul Perju<paul.perju@bu-uk.co.uk>"
    $To = "ICT Service Desk <ictservicedesk@bu-uk.co.uk>"
    $from = "ICT Service Desk <ictservicedesk@bu-uk.co.uk>"
    Send-MailMessage -To $to -From $from -Subject $mailSubject -SmtpServer $SMTPServer -Body $body -BodyAsHtml
} # to be used for sending errors 
function Add-TaskRequest{
    [CmdletBinding()]
    param
    (
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)] 
    [alias ("id")]
    [Int32]
    $RequestID,
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=2)] 
    [String]
    $TaskTitle,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, Position=3)] 
    [String]
    $TaskDescription,
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [String] 
    $TaskStatus,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)] 
    [String]
    $Group,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)] 
    [String]
    $Technician,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName= $true)]
    [String]
    $Priority,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName= $true)]
    [String]
    $TaskType,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName= $true)]
    [String]
    $ScheduleStartTaskTime,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName= $true)]
    [String]
    $ScheduleEndTaskTime,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName= $true)]
    [Int32]
    $Template,
    [Parameter(Mandatory=$false)]
    [Switch]
    $UseSDPDemo
    )

    #$ScheduleStartTaskTime = "08/12/2021 08:00"
    #$TimeValue = ((New-TimeSpan -Start (Get-Date "01/01/1970") -end (Get-Date $ScheduleStartTaskTime)).TotalSeconds *1000).ToString()
    #$ScheduleStartTaskTimeValue

    $Task = @{
        title = $TaskTitle
    }
    $Technician
    if( $TaskStatus){$task.Add("status",@{name= $TaskStatus})}
    if($group){$Task.Add("group",@{name =$group})}
    if($Technician){$Task.Add("owner",@{name =$Technician})}
    if($Priority){$Task.Add("priority",@{name = $Priority})}
    if($TaskType){$Task.Add("type",@{name = $TaskType})}
    if($ScheduleEndTaskTime){$Task.Add("scheduled_end_time",@{value = update-TimeValue $ScheduleEndTaskTime})}
    if($ScheduleStartTaskTime){$Task.Add("scheduled_start_time",@{value = update-TimeValue $ScheduleStartTaskTime})}
    if($Template){$Task.Add("template", @{id = $Template})}
    if($TaskDescription){$Task.Add("description",$TaskDescription)}


    $inputTask = @{task=$Task} | ConvertTo-Json -Depth 5
    $inputTask
    $Parameters = @{input_data=$inputTask}
    $Parameters.input_data

    if($UseSDPDemo) {
        $return =Switch-ToDemo
        $sdp = $return[0]
        $ApiKey = $return[1]
    }
    $header = @{
        TECHNICIAN_KEY=$ApiKey
        Accept="application/vnd.manageengine.sdp.v3+json"
    }
    $Uri = $sdp + "/api/v3/requests/"+ $requestID +"/tasks"
    $Result = Invoke-RestMethod -Method POST -Uri $Uri -Headers $header -Body $Parameters -ContentType "application/x-www-form-urlencoded"
    $Result
    <#
        .SYNOPSIS
        Adds a task to a request in ServiceDesk Plus

        .DESCRIPTION
        
        Adds a task to a request in ServiceDesk Plus

        .PARAMETER RequestID
        The ServiceDesk Plus Request ID number. (integer)

        .PARAMETER TaskTitle
        Task Title, AKA Subject of Task

        .PARAMETER ScheduleStartTaskTime
        Must be in this format "08/12/2021 08:00"

        .INPUTS
        None. You cannot pipe objects to Add-Extension.

        .OUTPUTS
        System.String. Add-Extension returns a string with the extension or file name.

        .EXAMPLE
        PS> extension -name "File"
        File.txt

    #>
} #Adds Task Request
function Resolve-Task{
        <#This function resolve an tasks. #>
    [CmdletBinding()]
        param
        (
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)] 
        [alias ("id")]
        [Int32]
        $TaskID,
        [Parameter(Mandatory=$false)]
        [Switch]
        $UseSDPDemo
        )

    $Task = @{
    status = @{name = "Resolved"}
    }
    $inputTask = @{task=$Task} | ConvertTo-Json
    $inputTask
    $Parameters = @{input_data=$inputTask}
    $Parameters.input_data
    if($UseSDPDemo) {
        $return =Switch-ToDemo
        $sdp = $return[0]
        $ApiKey = $return[1]
    }
    $header = @{TECHNICIAN_KEY=$ApiKey}
    $Uri = $sdp + "/api/v3/tasks/" + $TaskID
    $Result = Invoke-RestMethod -Method PUT -Uri $Uri -Headers $header -Body $Parameters -ContentType "application/x-www-form-urlencoded"
    $Result
} # Resolve Task
function Close-TaskRequest{
    <#This function resolve an tasks. #>
[CmdletBinding()]
    param
    (
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)] 
    [alias ("id")]
    [Int32]
    $TaskID,
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=1)] 
    [Int32]
    $RequestID,
    [Parameter(Mandatory=$false)]
    [Switch]
    $UseSDPDemo
    )

$Parameters = @{input_data=$inputTask}
$Parameters.input_data
if($UseSDPDemo) {
    $return =Switch-ToDemo
    $sdp = $return[0]
    $ApiKey = $return[1]
}
$header = @{
    TECHNICIAN_KEY=$ApiKey
    accept = "application/vnd.manageengine.sdp.v3+json"
}
$Uri = $sdp + "/api/v3/requests/"+ $RequestID + "/tasks/" + $TaskID + "/close"
$uri
$Result = Invoke-RestMethod -Method PUT -Uri $Uri -Headers $header -ContentType "application/x-www-form-urlencoded"
$Result
} # Close Task
function Remove-Request {
    [CmdletBinding()]
    param(
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
    [alias ("id")]
    [Int32]
    $RequestID,
    [Parameter(Mandatory=$false)]
    [Switch]
    $UseSDPDemo
    )
    if($UseSDPDemo) {
    $return =Switch-ToDemo
    $return
    $sdp = $return[0]
    $ApiKey = $return[1]
    }
    $header = @{TECHNICIAN_KEY=$ApiKey}
    $deleteUri = $sdp + "/api/v3/requests/" + $RequestID + "/move_to_trash"
    $deleteUri
    $response = Invoke-RestMethod -Uri $deleteUri -Method delete -Headers $header
    $response
} # Delete-Request
function Add-Request{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)] 
        [String]
        $Subject,
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, Position=1)] 
        [String]
        $Description,
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [String] 
        $Status,
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)] 
        [String]
        $Group,
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)] 
        [String]
        $Technician,
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName= $true)]
        [String]
        $Priority,
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName= $true)]
        [String]
        $ServiceCategory,
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName= $true)]
        [String]
        $Category,
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName= $true)]
        [String]
        $Subcategory,
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName= $true)]
        [String]
        $item,
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName= $true)]
        [String]
        $Editor,
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName= $true)]
        [Int32]
        $Template,
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName= $true)]
        [String]
        $DueByTime,
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName= $true)]
        [String]
        $Requester_email,
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName= $true)]
        [String]
        $Resolution,
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName= $true)]
        [String[]]
        $AdditionalEmailToNotify,
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName= $true)]
        [Object]
        $CustomFields = @{},
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName= $true)]
        [Object]
        $Resources,
        [Parameter(Mandatory=$false)]
        [Switch]
        $UseSDPDemo
    )
    #$ScheduleStartTaskTime = "08/12/2021 08:00"
    #$TimeValue = ((New-TimeSpan -Start (Get-Date "01/01/1970") -end (Get-Date $ScheduleStartTaskTime)).TotalSeconds *1000).ToString()
    #$ScheduleStartTaskTimeValue
    $Resources
    $Request = @{
        subject = $Subject
        requester= @{email_id = $Requester_email}
        status = @{name = $status}
    }
    $request
    if($ServiceCategory){$Request.Add("service_category",@{name= $ServiceCategory})}
    if($CustomFields){$Request.Add("udf_fields",$CustomFields)}
    if($Resources){$Request.Add("resources",$Resources )}
    if($AdditionalEmailToNotify){$Request.Add("email_ids_to_notify",$AdditionalEmailToNotify)}
    if($Resolution){$Request.Add("resolution",@{content= $Resolution})}
    if($Subategory){$Request.Add("subcategory",@{name = $Subcategory})}
    if($Category){$Request.Add("category",@{name = $Category})}
    if($group){$Request.Add("group",@{name =$group})}
    if($Technician){$Request.Add("technician",@{name =$Technician})}
    if($Priority){$Request.Add("priority",@{name = $Priority})}
    if($Description){$Request.Add("description",$Description)}
    if($DueByTime){$Request.Add("due_by_time", @{value = update-TimeValue $DueByTime})}
    if($Template){$Request.Add("template", @{id = $Template})}
    if($Editor){$Request.Add("editor",@{email_id = $Editor})}

    $inputRequest = @{request=$Request} | ConvertTo-Json -Depth 4
    $Parameters = @{input_data=$inputRequest}
    $Parameters.input_data
    if($UseSDPDemo) {
        $return =Switch-ToDemo
        $sdp = $return[0]
        $sdp
        $ApiKey = $return[1]
        $ApiKey }
    
    $header = @{
    TECHNICIAN_KEY=$ApiKey
    Accept="application/vnd.manageengine.sdp.v3+json"
    }
    $url = $sdp +"/api/v3/requests"
    $Result = Invoke-RestMethod -Method POST -Uri $url -Headers $header -Body $Parameters -ContentType "application/x-www-form-urlencoded"
    $RequestID = @{RequestID =$Result.request.id}
    $RequestID
}  #Adds Request
function Update-Request{
    [CmdletBinding()]
    param    (
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
    [alias ("id")]
    [String]
    $RequestID,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, Position=1)] 
    [String]
    $Subject,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, Position=2)] 
    [String]
    $Description,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
    [String] 
    $Status,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)] 
    [String]
    $Group,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)] 
    [String]
    $Technician,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName= $true)]
    [String]
    $Priority,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName= $true)]
    [String]
    $Category,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName= $true)]
    [String]
    $Subcategory,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName= $true)]
    [String]
    $Resolution,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName= $true)]
    [String[]]
    $AdditionalEmailToNotify,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName= $true)]
    [String]
    $item,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName= $true)]
    [String]
    $Editor,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName= $true)]
    [String]
    $ServiceCategory,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName= $true)]
    [Int32]
    $Template,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName= $true)]
    [String]
    $DueByTime,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName= $true)]
    [String]
    $FirstResponseDueByTime,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName= $true)]
    [Object]
    $CustomFields = @{},
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName= $true)]
    [String]
    $Requester_email,
    [Parameter(Mandatory=$false)]
    [Switch]
    $UseSDPDemo
    )
    #$ScheduleStartTaskTime = "08/12/2021 08:00"
    #$TimeValue = ((New-TimeSpan -Start (Get-Date "01/01/1970") -end (Get-Date $ScheduleStartTaskTime)).TotalSeconds *1000).ToString()
    #$ScheduleStartTaskTimeValue
    $Request = @{
        udf_fields = $Customfields
    }
    if($AdditionalEmailToNotify){$Request.Add("email_ids_to_notify",$AdditionalEmailToNotify)}
    if($Subategory){$Request.Add("subcategory",@{name = $Subcategory})}
    if($Category){$Request.Add("category",@{name = $Category})}
    if($ServiceCategory){$Request.Add("service_category",@{name = $ServiceCategory})}
    if($Resolution){$Request.Add("resolution",@{content = $Resolution })}
    if($Requester_email){$Request.Add("requester",@{email_id = $Requester_email})}
    if($Status){$Request.Add("status",@{name = $status})}
    if($Subject){$Request.Add("subject",$Subject)}
    if($group){$Request.Add("group",@{name =$group})}
    if($Technician){$Request.Add("technician",@{name =$Technician})}
    if($Priority){$Request.Add("priority",@{name = $Priority})}
    if($Description){$Request.Add("description",$Description)}
    if($FirstResponseDueByTime){$Request.Add("first_response_due_by_time",@{value = update-TimeValue $FirstResponseDueByTime})}
    if($DueByTime){$Request.Add("due_by_time", @{value = update-TimeValue $DueByTime})}
    if($Template){$Request.Add("template", @{id = $Template})}
    if($Editor){$Request.Add("editor",@{email_id = $Editor})}
    
    $inputRequest = @{request=$Request} | ConvertTo-Json -Depth 4
    $Parameters = @{input_data=$inputRequest}
    $Parameters.input_data
    if($UseSDPDemo) {
        $return =Switch-ToDemo
        $sdp = $return[0]
        $ApiKey = $return[1]
    }
    
    $header = @{TECHNICIAN_KEY=$ApiKey}
    $url = $sdp +"/api/v3/requests/" + $RequestID
    $Result = Invoke-RestMethod -Method PUT -Uri $url -Headers $header -Body $Parameters -ContentType "application/x-www-form-urlencoded"
    $Result
} #Update Request
function Get-Request {
    [CmdletBinding()]
    param
        (
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)] 
        [alias ("id")]
        [Int32]
        $RequestID,
        [Parameter(Mandatory=$false)]
        [Switch]
        $UseSDPDemo
        )
    process {
        if($UseSDPDemo) {
        $return =Switch-ToDemo
        $sdp = $return[0]
        $ApiKey = $return[1]
        }
        $header = @{TECHNICIAN_KEY=$ApiKey}
        $Uri = $sdp + "/api/v3/requests/" + $RequestID
        $Uri
        $result = Invoke-RestMethod -Method Get -Uri $Uri -Headers $header
        $result
    }
} # Gets information on an existing request
function Search-Request{
    [CmdletBinding()]
    param    (
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, Position=1)] 
    [String]
    $Subject,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, Position=2)] 
    [String]
    $Description,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
    [String] 
    $Status,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)] 
    [String]
    $Impact,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)] 
    [String]
    $Group,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)] 
    [String]
    $Technician,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName= $true)]
    [String]
    $Priority,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName= $true)]
    [String]
    $Category,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName= $true)]
    [String]
    $Subcategory,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName= $true)]
    [String]
    $item,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName= $true)]
    [String]
    $Editor,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName= $true)]
    [String]
    $Resolution,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName= $true)]
    [String]
    $ServiceCategory,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName= $true)]
    [Int32]
    $Template,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName= $true)]
    [String]
    $DueByTime,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName= $true)]
    [String]
    $UDF,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName= $true)]
    [Object]
    $CustomFields = @{},
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName= $true)]
    [String]
    $Requester_email,
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName= $true)]
    #[ValidateSet("Open_System","Onhold_System","All_Requests")]
    [String]
    $FilterBy,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName= $true)]
    [Int32]
    $RowCount = "20",
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName= $true)]
    [Int32]
    $StartIndex = "1",
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName= $true)]
    [String]
    $SortField = "subject",
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName= $true)]
    [String]
    $SortOrder= "asc",
    [Parameter(Mandatory=$false)]
    [Switch]
    $UseSDPDemo
    )
    #$ScheduleStartTaskTime = "08/12/2021 08:00"
    #$TimeValue = ((New-TimeSpan -Start (Get-Date "01/01/1970") -end (Get-Date $ScheduleStartTaskTime)).TotalSeconds *1000).ToString()
    #$ScheduleStartTaskTimeValue
    $list_info = @{
        row_count=$RowCount
        start_index=$StartIndex
        sort_field= $SortField
        sort_order= $SortOrder
        get_total_count= $true;
        filter_by= @{
            name= $FilterBy
        }
    }
    $search_fields= @{}
    if($Subject){$search_fields.Add("subject",$Subject)}
    if($Technician){$search_fields.Add("technician.name",$Technician)}
    if($Impact){$search_fields.Add("impact.name",$impact)}

    $list_info.Add("search_fields",$search_fields)
    # if($UDF){
    #     $UDFData =@{}
    #     $Request.Add("udf_fields",@{$sline = $UDF})
    # }
    
    $inputRequest = @{list_info=$list_info} | ConvertTo-Json -Depth 4
    #$inputRequest 
    $Parameters = @{input_data=$inputRequest}
    #$Parameters.input_data
    if($UseSDPDemo) {
        $return =Switch-ToDemo
        $sdp = $return[0]
        $ApiKey = $return[1]
    }
    
    $header = @{TECHNICIAN_KEY=$ApiKey}
    $url = $sdp +"/api/v3/requests/"
    $Result = Invoke-RestMethod -Method GET -Uri $url -Headers $header -Body $Parameters -ContentType "application/x-www-form-urlencoded"
    $Result.requests
} #Search Requests
function Get-SDPReport {
    [CmdletBinding()]
    param
        (
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)] 
        [alias ("id")]
        [Int32]
        $ReportID,
        [Parameter(Mandatory=$false)]
        [Switch]
        $UseSDPDemo
        )
    if($UseSDPDemo) {
    $return =Switch-ToDemo
    $sdp = $return[0]
    $ApiKey = $return[1]
    }
    $header = @{TECHNICIAN_KEY=$ApiKey}
    $Uri = $sdp + "/api/v3/reports/" + $ReportID +"/execute"
    $result = Invoke-RestMethod -Uri $uri -Method get -Headers $header
    $result
    $resultdata =$result.execute.data
    $resultdata
}
function Add-RequestNote{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
        [alias ("id")]
        [String]
        $RequestID,
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=1)] 
        [String]
        $Description,
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, Position=2)] 
        [Switch]
        $ShowToRequester,
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, Position=2)] 
        [Switch]
        $MarkFirstResponse,
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, Position=2)] 
        [Switch]
        $AddToLinkedRequests,
        [Parameter(Mandatory=$false)]
        [Switch]
        $UseSDPDemo
    )
    $note = @{}

    if($Description) {$note.Add("description",$Description)}
    if($ShowToRequester) {$note.Add("show_to_requester",$true)}
    if($MarkFirstResponse) {$note.Add("mark_first_response",$true)}
    if($AddToLinkedRequests) {$note.Add("add_to_linked_requests",$true)}

    $inputRequest = @{note=$note} | ConvertTo-Json -Depth 4
    $Parameters = @{input_data=$inputRequest}
    $Parameters.input_data
    if($UseSDPDemo) {
        $return =Switch-ToDemo
        $sdp = $return[0]
        $ApiKey = $return[1]}
    
    $header = @{TECHNICIAN_KEY=$ApiKey}
    $url = $sdp +"/api/v3/requests/" + $RequestID + "/notes"
    $url
    $Result = Invoke-RestMethod -Method POST -Uri $url -Headers $header -Body $Parameters -ContentType "application/x-www-form-urlencoded"
    $result
}  #Adds Request Note
function Set-RequestStatusScheduler{
    param    (
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
    [alias ("id")]
    [String]
    $RequestID,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, Position=1)] 
    [String]
    $Comments,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
    [String] 
    $ChangeToStatus,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName= $true)]
    [String]
    $Status,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName= $true)]
    [String]
    $ScheduledTime,
    [Parameter(Mandatory=$false)]
    [Switch]
    $UseSDPDemo
    )
    #$ScheduleStartTaskTime = "08/12/2021 08:00"
    #$TimeValue = ((New-TimeSpan -Start (Get-Date "01/01/1970") -end (Get-Date $ScheduleStartTaskTime)).TotalSeconds *1000).ToString()
    #$ScheduleStartTaskTimeValue
    $onholdscheduler =@{}
    $Request | ConvertTo-Json
    if($Comments){$onholdscheduler.Add("comments",$Comments)}
    if($ScheduledTime){$onholdscheduler.Add("scheduled_time", @{display_value = $ScheduledTime; value = update-TimeValue $ScheduledTime})}
    if($ChangeToStatus){$onholdscheduler.Add("change_to_status",@{name = $ChangeToStatus})}
    $request = @{onhold_scheduler = $onholdscheduler}
    if($Status){$Request.add("status",@{name =$Status})}
    $inputRequest = @{request=$Request} | ConvertTo-Json -Depth 4
    $Parameters = @{input_data=$inputRequest}
    $Parameters.input_data
    if($UseSDPDemo) {
        $return =Switch-ToDemo
        $sdp = $return[0]
        $ApiKey = $return[1]
    }
    
    $header = @{TECHNICIAN_KEY=$ApiKey}
    $url = $sdp +"/api/v3/requests/" + $RequestID
    $Result = Invoke-RestMethod -Method PUT -Uri $url -Headers $header -Body $Parameters -ContentType "application/x-www-form-urlencoded"
    $Result
        <#
        .SYNOPSIS
        Set a request  a status to change a later date

        .DESCRIPTION
        Set a request  a status to change a later date
        
        .PARAMETER RequestID
        The ServiceDesk Plus Request ID number. (integer)

        .PARAMETER Comments
        Any comments / reason of why the request wsa put on hold.
        
        .PARAMETER ScheduledTime
        Time and date whe the status will be changed back "25/03/2022 03:45 PM" or "25/03/2022"

        .OUTPUTS
        xxx

        .EXAMPLE
        Set-RequestStatusScheduler -RequestID 168321 -ScheduledTime "25/03/2022 03:45 PM" -ChangeToStatus Open -UseSDPDemo -comments "blabla" -Status Onhold

    #>
} #Set a request  a status to change a later date
function Add-RequestAssets{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
        [alias ("id")]
        [String]
        $RequestID,
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, Position=1)] 
        [array]
        $assetlist,
        [Parameter(Mandatory=$false)]
        [Switch]
        $UseSDPDemo
    )
    <#     $existing = Get-Request -RequestID $RequestID -UseSDPDemo
    $existing.request.assets.name
    Compare-Object -ReferenceObject $existing.request.assets.name -DifferenceObject $assetlist #>
    $list =@()
    $assetlist | ForEach-Object {
        $asset = $_
        $assetname =@{name = $asset}
        $list += $assetname
    }
    $Request = @{}
    $Request.Add("assets",$list)
    $inputRequest = @{request=$Request} | ConvertTo-Json -Depth 4
    $Parameters = @{input_data=$inputRequest}
    $Parameters.input_data
    if($UseSDPDemo) {
        $return =Switch-Todemo
        $sdp = $return[0]
        $ApiKey = $return[1]}
    
    $header = @{TECHNICIAN_KEY=$ApiKey}
    $url = $sdp +"/api/v3/requests/" + $RequestID
    $responsetAsset = Invoke-RestMethod -Uri $url -Method put -Body $Parameters -Headers $header -ContentType "application/x-www-form-urlencoded"
    $responsetAsset
}
function Add-RequestWorklog {
  [CmdletBinding()]
  param
  (
  [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)] 
  [Int32]
  $RequestID,
  [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=1)] 
  [String]
  $Description,
  [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=2)] 
  [String]
  $Owner,
  [Parameter(Mandatory=$false)]
  [Switch]
  $UseSDPDemo
  )
  
  $worklog =@{}
  if ($Owner) {$worklog.Add("owner",@{name =$Owner})}
  if ($Description) {$worklog.Add("description",$Description)}
  $inputWorklog = @{"worklog"=$worklog} | ConvertTo-Json -Depth 4


  if($UseSDPDemo) {
  $return =Switch-ToDemo
  $sdp = $return[0]
  $ApiKey = $return[1]}
  $header = @{TECHNICIAN_KEY=$ApiKey}
  $url = $sdp +"/api/v3/requests/" + $RequestID +"/worklogs"
  #$addWorklog = $Sdp + "/api/v3/worklog"
  $parameters = @{"input_data"=$inputWorklog}
  $parameters
  $Result = Invoke-RestMethod -Method POST -Uri $url -Headers $header -Body $Parameters -ContentType "application/x-www-form-urlencoded"
  $Result
  } # Add a Request Worklog
function Add-RequestTaskWorklog {
    [CmdletBinding()]
    param
    (
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)] 
    [Int32]
    $RequestID,
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=1)] 
    [Int32]
    $TaskID,
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=2)] 
    [String]
    $Description,
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=3)] 
    [String]
    $Owner,
    [Parameter(Mandatory=$false)]
    [Switch]
    $UseSDPDemo
    )
    $worklog =@{}
    if ($Owner) {$worklog.Add("owner",@{name =$Owner})}
    if ($Description) {$worklog.Add("description",$Description)}
    $inputWorklog = @{"worklog"=$worklog} | ConvertTo-Json -Depth 5

    if($UseSDPDemo) {
    $return =Switch-ToDemo
    $sdp = $return[0]
    $ApiKey = $return[1]}
    $header = @{
        TECHNICIAN_KEY=$ApiKey
        Accept="application/vnd.manageengine.sdp.v3+json"
        }
    $header
    $url = $sdp +"/api/v3/requests/" + $RequestID +"/tasks/" + $TaskID + "/worklogs"
    $url
    #$addWorklog = $Sdp + "/api/v3/worklog"
    $parameters = @{"input_data"=$inputWorklog}
    $parameters.input_data
    $Result = Invoke-RestMethod -Method POST -Uri $url -Headers $header -Body $Parameters -ContentType "application/x-www-form-urlencoded"
    $Result
} # Add a Task Request Worklog
function Add-LinkRequests {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)] 
        [alias ("id")]
        [Int32]
        $RequestID,
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=1)] 
        [String[]]
        $Requests,
        # Add Comments to link
        [Parameter(Mandatory= $false)]
        [string]
        $Comments = "",
        [Parameter(Mandatory=$false)]
        [Switch]
        $UseSDPDemo
        )
        $linkRequests =@()
        $Requests | ForEach-Object {
            $linkedRequest =@{linked_request =@{id = $_}}
    $linkRequests += $linkedRequest + @{comments = "$comments"}
}

$inputRequest = @{link_requests =$linkRequests} | ConvertTo-Json -Depth 4
$Parameters = @{input_data=$inputRequest}
$Parameters.input_data
if($UseSDPDemo) {
    $return =Switch-ToDemo
    $sdp = $return[0]
    $ApiKey = $return[1]}
    $header = @{TECHNICIAN_KEY=$ApiKey}
    $url = $sdp +"/api/v3/requests/" + $RequestID + "/link_requests"
    $url
    $Result = Invoke-RestMethod -Method POST -Uri $url -Headers $header -Body $Parameters -ContentType "application/x-www-form-urlencoded"
    $Result
}
function Remove-HideFirstNotification {
    [CmdletBinding()]
    param(
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
    [alias ("id")]
    [Int32]
    $RequestID,
    [Parameter(Mandatory=$false)]
    [Switch]
    $UseSDPDemo
    )
    $Request = @{}
    $description = (Get-Request -RequestID $RequestID).request.description
    $description = ($description).Replace("#HideFirstNotificationEmail#","")
    $Request.Add("description",$Description)
    $inputRequest = @{request=$Request} | ConvertTo-Json -Depth 4
    $Parameters = @{input_data=$inputRequest}
    $Parameters.input_data
    if($UseSDPDemo) {
        $return =Switch-ToDemo
        $sdp = $return[0]
        $ApiKey = $return[1]
    }
    
    $header = @{TECHNICIAN_KEY=$ApiKey}
    $url = $sdp +"/api/v3/requests/" + $RequestID
    $Result = Invoke-RestMethod -Method PUT -Uri $url -Headers $header -Body $Parameters -ContentType "application/x-www-form-urlencoded"
    #$Result
} # Remove First Notification Email
function Get-SDPUser{
    [CmdletBinding()]
    param
    (
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
    [String]
    $PrimaryEmail
    )

$input_data = @"
{
    "list_info": {
        "sort_field": "name",
        "start_index": 1,
        "sort_order": "asc",
        "row_count": "25",
        "get_total_count": true,
        "search_fields": {
            "email_id": "$($PrimaryEmail)"
        }
    },
    "fields_required": [
        "name",
        "is_technician",
        "citype",
        "login_name",
        "email_id",
        "department",
        "phone",
        "mobile",
        "jobtitle",
        "project_roles",
        "employee_id",
        "first_name",
        "middle_name",
        "last_name",
        "is_vipuser",
        "ciid"
    ]
}

"@
#$input_data
if($UseSDPDemo) {
    $return =Switch-ToDemo
    $sdp = $return[0]
    $ApiKey = $return[1]}
    $header = @{
        TECHNICIAN_KEY=$ApiKey
        }
    #$header
$uri = $sdp +"/api/v3/users"
$data = @{ 'input_data' = $input_data}
$response = Invoke-RestMethod -Uri $uri -Method get -Body $data -Headers $header -ContentType "application/x-www-form-urlencoded"
$response.users
}
function Search-SDPChange {
    param (
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=1)] 
        [Object]
        $SearchFields,
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, Position=1)] 
        [Int32]
        $ChangeID
    )
    Import-Module -Name "c:\Program Files\WindowsPowerShell\Modules\ServiceDeskPlus\ServiceDeskPlus.psm1" -Force
    $header = @{TECHNICIAN_KEY=$ApiKey}
    $SearchFields = $SearchFields | ConvertTo-Json 
    $input_data = @"
{
    "list_info": {
        "row_count": 1000,
        "start_index": 1,
        "get_total_count": true,
        "search_fields": $($SearchFields),
        "sort_fields": [
            {
                "field": "id",
                "order": "asc"
            }
        ]
    }
}
"@
if($UseSDPDemo) {
    $return =Switch-ToDemo
    $sdp = $return[0]
    $ApiKey = $return[1]}
    $header = @{
        TECHNICIAN_KEY=$ApiKey
        }
    #$header
$uri = $Sdp + "/api/v3/changes/"# + $ChangeID
$uri
$data = @{ 'input_data' = $input_data}
$input_data
$data
$response = Invoke-RestMethod -Uri $uri -Method get -Body $data -Headers $header -ContentType "application/x-www-form-urlencoded"
$response.changes
}
function Get-SDPChangeRoles {
    <#
    .SYNOPSIS
        Return the Custom roles from a change. It DOES NOT include Change Requestror, Change Manager, Change Owner
    #>
    [CmdletBinding()]
    param 
    (
        #Change ID of the Change you want to get the roles
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
        [Int32]
        $changeID,
        #Use this switch to switch to Demo SDP
        [Parameter(Mandatory=$false)]
        [Switch]
        $UseSDPDemo
    )
    if($UseSDPDemo) {
        $return =Switch-ToDemo
        $sdp = $return[0]
        $ApiKey = $return[1]
    }
    $uri = $Sdp + "/api/v3/changes/" + $ChangeID
    $header = @{TECHNICIAN_KEY=$ApiKey}
    $response = Invoke-RestMethod -Uri $uri -Method get -Headers $header 
    $response.change.roles
} #Get Existent roles of a change
function Add-SDPRolesToChange {
    param (
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)] 
        [String[]]
        $JourneyOwnersEmailAddress,
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=1)] 
        [Int32]
        $ChangeID,
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=2)] 
        [String]
        $SDPRole,
        [Parameter(Mandatory=$false)]
        [Switch]
        $UseSDPDemo
    )
    #Import-Module -Name "c:\Program Files\WindowsPowerShell\Modules\ServiceDeskPlus\ServiceDeskPlus.psm1" -Force
    
    if ($UseSDPDemo) 
    {
        $existingRoles = Get-SDPChangeRoles $changeID -UseSDPDemo
    }
    else {
        $existingRoles = Get-SDPChangeRoles $changeID
    }
    #$existingRoles

    $changes = @{}
    $change = @{}
    $roles = @()
    $roles += $existingRoles

    #$JourneyOwnersEmailAddress 
    $implementerRoles = $roles | Where-Object {$_.role.name -eq $SDPRole }
    $implementerRoles
    $implementerRoles.user.id
    $JourneyOwnersEmailAddress | ForEach-Object{
        $PrimaryEmail =$_
        #$PrimaryEmail = "dana.popa@bu-uk.co.uk"
        $userId = (Get-SDPUser -PrimaryEmail $PrimaryEmail).id
        $userId
        #get only the role that we are adding
        if ($userId -notin $implementerRoles.user.id){
            $userId
            $hash = @{
                role = @{name = $SDPRole}
                user = @{id = $userId}
            }
            $role = $hash | ConvertTo-Json | ConvertFrom-Json
            $role 
            $roles +=$role
        }
    }
    $roles
    $change.Add("roles",$roles)
    $changes.Add("change", $change)
    $changes  = $changes | ConvertTo-Json -Depth 9
    #$changes

    if($UseSDPDemo) {
        $return =Switch-ToDemo
        $sdp = $return[0]
        $ApiKey = $return[1]
    }
    $header = @{TECHNICIAN_KEY=$ApiKey}
    $uri = $Sdp + "/api/v3/changes/" + $ChangeID
    $uri
    $parameters = @{"input_data"= $changes}
    #$parameters.input_data
    $response = Invoke-RestMethod -Uri $uri -Method put -Body $parameters -Headers $header -ContentType "application/x-www-form-urlencoded"
    $response
}
function Get-AllSDPAttachments{
    <#
    .SYNOPSIS
    Downloades all tickets from a requests
    #>
    [CmdletBinding()]
    param 
    (
        #Request ID from which the attachments 
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
        [Int32]
        $requestID,
        #Path for the files to be downloaded. If not set default is: C:Temp\$($requestID)\$($name)
        [Parameter(ValueFromPipelineByPropertyName=$true, Position=1)]
        [string]
        $OutFolder = "c:\temp",
        #Use this switch to just output the path to the downloads instead of actually download them
        [Parameter(Mandatory=$false)]
        [Switch]
        $urlPath,
        #Use this switch to switch to Demo SDP
        [Parameter(Mandatory=$false)]
        [Switch]
        $UseSDPDemo
    )
    if($UseSDPDemo) {
        $return =Switch-ToDemo
        $sdp = $return[0]
        $ApiKey = $return[1]
    }
    $uriattach = $Sdp + "/api/v3/requests/$($requestID)/attachments"
    $header = @{TECHNICIAN_KEY=$ApiKey}
    $response_attachments = Invoke-RestMethod -Uri $uriattach -Method get -Headers $header
    $path = "$($OutFolder)\$($requestID)"
    if (-Not (Test-Path -Path $path)) {
        New-Item -ItemType Directory -Path $path
    }
    $response_attachments.attachments | ForEach-Object{
        $attachmentID = $_.id
        $name= $_.name
        $uri = $sdp + "/api/v3/requests/$($requestID)/attachments/$($attachmentID)/download"
        if($urlPath) {
            $uri
        }
        else {
            $response = Invoke-RestMethod -Uri $uri -Method get -Headers $header -OutFile "$($path)\$($name)"
        }
        $response
    }
}

function Get-TaskRequest {
    [CmdletBinding()]
    param
        (
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)] 
        [alias ("id")]
        [Int32]
        $RequestID,
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=1)]
        [Int32]
        $TaskID,
        [Parameter(Mandatory=$false)]
        [Switch]
        $UseSDPDemo
        )
    process {
        if($UseSDPDemo) {
        $return =Switch-ToDemo
        $sdp = $return[0]
        $ApiKey = $return[1]
        }
        $header = @{TECHNICIAN_KEY=$ApiKey}
        $Uri = $sdp + "/api/v3/requests/$($RequestID)/tasks/$($TaskID)"
        $Uri
        $result = Invoke-RestMethod -Method Get -Uri $Uri -Headers $header
        $result.task
    }
} # Gets information on an existing Task Request
function Get-SDPRequestConversations {
    <#
    .SYNOPSIS
    Gets all Conversations: Emails and replies. Does not include Note or System Notifications
    #>
    [CmdletBinding()]
    param
        (
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)] 
        [alias ("id")]
        [Int32]
        $RequestID,
        [Parameter(Mandatory=$false)]
        [Switch]
        $UseSDPDemo
        )
    process {
        if($UseSDPDemo) {
        $return =Switch-ToDemo
        $sdp = $return[0]
        $ApiKey = $return[1]
        }
        $input_data = @"
        {
            "list_info": {
                "start_index": 1,
                "sort_order": "desc",
                "row_count": 1000
            },
        }
"@
        $data = @{ 'input_data' = $input_data}
        $header = @{TECHNICIAN_KEY=$ApiKey}
        $Uri = $sdp + "/api/v3/requests/$($RequestID)/conversations"
        #$Uri
        $data = @{ 'input_data' = $input_data}
        #$input_data
        #$data
        $response = Invoke-RestMethod -Uri $uri -Method get -Body $data -Headers $header -ContentType "application/x-www-form-urlencoded"
        $response   
    }
} # Gets all Conversations: Emails and replies. Does not include Note or System Notifications
Export-ModuleMember -Function Search-Request,
Add-TaskRequest,
Remove-Request,
Add-Request,
Send-MailError,
update-TimeValue,
Switch-ToDemo,
Resolve-Task,
Get-Request,
Update-Request,
Get-SDPReport,
Add-RequestNote,
Set-RequestStatusScheduler,
Add-RequestAssets,
Add-Worklog,
Add-LinkRequests,
Remove-HideFirstNotification,
Add-RequestWorklog,
Add-RequestTaskWorklog,
Close-TaskRequest,
Get-SDPUser,
Search-SDPChange,
Get-SDPChangeRoles,
Add-SDPRolesToChange,
Get-AllSDPAttachments,
Get-TaskRequest,
Get-SDPRequestConversations -Variable Sdp,ApiKey,fromAddress,SMTPServer