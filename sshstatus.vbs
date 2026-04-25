'=============================================================================
' SSH Status Script for BGInfo
'=============================================================================
' Description: Shows if SSH Server is installed and its running status
' Example outputs: "Running" or "Stopped" or "Not Installed"
'=============================================================================

On Error Resume Next

' Connect to WMI
Set wmi = GetObject("winmgmts:\\.\root\cimv2")
If Err.Number <> 0 Then
    Echo "N/A"
    WScript.Quit 1
End If

' Check for SSH Server service
Set services = wmi.ExecQuery("SELECT State FROM Win32_Service WHERE Name='sshd'")
result = "Not Installed"

' Determine SSH status
If services.Count > 0 Then
    For Each service In services
        If service.State = "Running" Then
            result = "Running"
        Else
            result = "Stopped"
        End If
        Exit For
    Next
End If
Echo result

' Clean up
Set wmi = Nothing