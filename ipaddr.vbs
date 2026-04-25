'=============================================================================
' IP Address Info Script for BGInfo
'=============================================================================
' Description: Gets IP address based on configuration:
' - If MAC file exists: shows IP for that adapter with connection type
' - If no MAC file: shows IP from first active adapter with connection type
' Example: "192.168.1.100 (wired)" or "192.168.1.101 (wifi)"
'=============================================================================

On Error Resume Next

' Connect to WMI
Set wmi = GetObject("winmgmts:\\.\root\cimv2")
Set fso = CreateObject("Scripting.FileSystemObject")

' Try to read MAC address from file
macAddress = ""
If fso.FileExists("mac") Then
    Set file = fso.OpenTextFile("mac", 1, False)
    If Not file.AtEndOfStream Then
        macAddress = Trim(file.ReadLine())
    End If
    file.Close
End If

' Build WMI query based on whether we have a MAC address
If macAddress <> "" Then
    ' Get IP and adapter info for specific MAC
    query = "SELECT IPAddress, AdapterType, NetConnectionID FROM Win32_NetworkAdapter WHERE MACAddress='" & macAddress & "' AND NetEnabled=True"
    Set adapters = wmi.ExecQuery(query)
    
    ' Get corresponding configuration for IP
    For Each adapter In adapters
        query = "SELECT IPAddress FROM Win32_NetworkAdapterConfiguration WHERE MACAddress='" & macAddress & "'"
        Set configs = wmi.ExecQuery(query)
        
        For Each config In configs
            If Not IsNull(config.IPAddress) Then
                ' Determine connection type
                connType = "(wired)"  ' Default to wired
                If Not IsNull(adapter.AdapterType) Then
                    ' Debug connection info
                    'Echo "Type: " & adapter.AdapterType & " | Name: " & adapter.NetConnectionID
                    
                    ' Check for wireless adapter
                    If adapter.AdapterType = "Ethernet 802.3" Then
                        connType = "(wired)"
                    ElseIf adapter.AdapterType = "IEEE 802.11" Then
                        connType = "(wifi)"
                    End If
                End If
                
                ' Output IP with connection type
                For Each ip In config.IPAddress
                    If InStr(ip, ":") = 0 Then
                        Echo ip & " " & connType
                        Exit For
                    End If
                Next
            End If
        Next
    Next
Else
    ' Get IP from any active adapter
    query = "SELECT IPAddress FROM Win32_NetworkAdapterConfiguration WHERE IPEnabled=True"
    Set configs = wmi.ExecQuery(query)
    
    For Each config In configs
        If Not IsNull(config.IPAddress) Then
            ' Get adapter info for connection type
            query = "SELECT AdapterType, NetConnectionID FROM Win32_NetworkAdapter WHERE NetEnabled=True AND MACAddress='" & config.MACAddress & "'"
            Set adapters = wmi.ExecQuery(query)
            
            For Each adapter In adapters
                ' Determine connection type
                connType = "(wired)"  ' Default to wired
                If Not IsNull(adapter.AdapterType) Then
                    ' Debug connection info
                    'Echo "Type: " & adapter.AdapterType & " | Name: " & adapter.NetConnectionID
                    
                    ' Check for wireless adapter
                    If adapter.AdapterType = "Ethernet 802.3" Then
                        connType = "(wired)"
                    ElseIf adapter.AdapterType = "IEEE 802.11" Then
                        connType = "(wifi)"
                    End If
                End If
                
                ' Output IP with connection type
                For Each ip In config.IPAddress
                    If InStr(ip, ":") = 0 Then
                        Echo ip & " " & connType
                        Exit For
                    End If
                Next
            Next
            Exit For
        End If
    Next
End If

' Clean up
Set wmi = Nothing
Set fso = Nothing