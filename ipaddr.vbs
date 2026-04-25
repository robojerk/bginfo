'=============================================================================
' IP Address Info Script for BGInfo
'=============================================================================
' Description: Auto-detects IPv4 from first IP-enabled adapter
' Example: "192.168.1.100 (wired)" or "192.168.1.101 (wifi)"
'=============================================================================

On Error Resume Next

' Connect to WMI
Set wmi = GetObject("winmgmts:\\.\root\cimv2")

If Err.Number <> 0 Then
    Echo "N/A"
    WScript.Quit 1
End If

query = "SELECT MACAddress, IPAddress, Index FROM Win32_NetworkAdapterConfiguration WHERE IPEnabled=True"
Set configs = wmi.ExecQuery(query)
result = ""

For Each config In configs
    If Not IsNull(config.IPAddress) Then
        ipv4 = ""
        For Each ip In config.IPAddress
            If InStr(ip, ":") = 0 Then
                ipv4 = ip
                Exit For
            End If
        Next

        If ipv4 <> "" Then
            connType = "(wired)"
            adapterQuery = "SELECT AdapterType, Name, NetConnectionID FROM Win32_NetworkAdapter WHERE Index=" & config.Index
            Set adapters = wmi.ExecQuery(adapterQuery)

            For Each adapter In adapters
                aType = ""
                aName = ""
                aConn = ""

                If Not IsNull(adapter.AdapterType) Then aType = adapter.AdapterType
                If Not IsNull(adapter.Name) Then aName = adapter.Name
                If Not IsNull(adapter.NetConnectionID) Then aConn = adapter.NetConnectionID

                If InStr(1, aType, "802.11", 1) > 0 Or _
                   InStr(1, aName, "Wi-Fi", 1) > 0 Or _
                   InStr(1, aName, "Wireless", 1) > 0 Or _
                   InStr(1, aConn, "Wi-Fi", 1) > 0 Or _
                   InStr(1, aConn, "Wireless", 1) > 0 Or _
                   InStr(1, aConn, "WLAN", 1) > 0 Then
                    connType = "(wifi)"
                End If

                Exit For
            Next

            result = ipv4 & " " & connType
            Exit For
        End If
    End If
Next

If result = "" Then
    Echo "N/A"
Else
    Echo result
End If

' Clean up
Set wmi = Nothing