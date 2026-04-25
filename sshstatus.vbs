'=============================================================================
' SSH Status Script for BGInfo
'=============================================================================
' Description: Shows if SSH Server is installed and its running status
' Example outputs: "Running" or "Stopped" or "Not Installed"
'=============================================================================

On Error Resume Next

' Connect to WMI
Set wmi = GetObject("winmgmts:\\.\root\cimv2")

' Check for SSH Server service
Set services = wmi.ExecQuery("SELECT State FROM Win32_Service WHERE Name='sshd'")

' Determine SSH status
If services.Count > 0 Then
    For Each service In services
        If service.State = "Running" Then
            Echo "Running"
        Else
            Echo "Stopped"
        End If
        Exit For
    Next
Else
    Echo "Not Installed"
End If

' Clean up
Set wmi = Nothing