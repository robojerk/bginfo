On Error Resume Next

' Connect to WMI
Set wmi = GetObject("winmgmts:\\.\root\cimv2")
If Err.Number <> 0 Then
    Echo "N/A"
    WScript.Quit 1
End If

Set cpu = wmi.ExecQuery("SELECT * FROM Win32_Processor")
cpuName = "N/A"

' Get CPU name
For Each item In cpu
    If Not IsNull(item.Name) Then
        cpuName = item.Name
        Exit For
    End If
Next

Echo cpuName

' Clean up
Set cpu = Nothing
Set wmi = Nothing