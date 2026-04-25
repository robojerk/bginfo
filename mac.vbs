'=============================================================================
' MAC Address Info Script for BGInfo
'=============================================================================
' Description: Returns MAC address for the first active adapter with IPv4
'=============================================================================

On Error Resume Next

Set wmi = GetObject("winmgmts:\\.\root\cimv2")

If Err.Number <> 0 Then
    Echo "N/A"
    WScript.Quit 1
End If

Set configs = wmi.ExecQuery("SELECT MACAddress, IPAddress FROM Win32_NetworkAdapterConfiguration WHERE IPEnabled=True")
result = ""

For Each config In configs
    If Not IsNull(config.MACAddress) And Not IsNull(config.IPAddress) Then
        For Each ip In config.IPAddress
            If InStr(ip, ":") = 0 Then
                result = config.MACAddress
                Exit For
            End If
        Next
    End If

    If result <> "" Then Exit For
Next

If result = "" Then
    Echo "N/A"
Else
    Echo result
End If

Set wmi = Nothing
