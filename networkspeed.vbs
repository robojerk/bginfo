'=============================================================================
' Network Speed Info Script for BGInfo
'=============================================================================
' Description: Shows speed for first active adapter with IPv4
'=============================================================================

On Error Resume Next

' Connect to WMI
Set wmi = GetObject("winmgmts:\\.\root\cimv2")

If Err.Number <> 0 Then
    Echo "N/A"
    WScript.Quit 1
End If

selectedMac = ""
Set configs = wmi.ExecQuery("SELECT MACAddress, IPAddress FROM Win32_NetworkAdapterConfiguration WHERE IPEnabled=True")
For Each config In configs
    If Not IsNull(config.MACAddress) And Not IsNull(config.IPAddress) Then
        hasIPv4 = False
        For Each ip In config.IPAddress
            If InStr(ip, ":") = 0 Then
                hasIPv4 = True
                Exit For
            End If
        Next

        If hasIPv4 Then
            selectedMac = config.MACAddress
            Exit For
        End If
    End If
Next

If selectedMac = "" Then
    Echo "N/A"
    Set wmi = Nothing
    WScript.Quit 0
End If

query = "SELECT Speed FROM Win32_NetworkAdapter WHERE MACAddress='" & selectedMac & "' AND NetEnabled=True"
Set adapters = wmi.ExecQuery(query)
speedText = ""

For Each adapter In adapters
    If Not IsNull(adapter.Speed) Then
        speed = CDbl(adapter.Speed)

        If speed >= 1000000000 Then
            speedText = Round(speed/1000000000, 1) & " Gb/s"
        ElseIf speed >= 1000000 Then
            speedText = Round(speed/1000000, 0) & " Mb/s"
        Else
            speedText = Round(speed/1000, 0) & " Kb/s"
        End If

        Exit For
    End If
Next

If speedText = "" Then
    Echo "N/A"
Else
    Echo speedText
End If

' Clean up
Set wmi = Nothing
