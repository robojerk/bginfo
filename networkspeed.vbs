'=============================================================================
' Network Speed Info Script for BGInfo
'=============================================================================
' Description: Shows network adapter speed(s):
' - If MAC file exists: shows speed for that specific adapter
' - If no MAC file or empty: shows speeds for all active adapters
'=============================================================================

On Error Resume Next

' Connect to WMI and FSO
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
    ' Get speed for specific MAC
    query = "SELECT Speed FROM Win32_NetworkAdapter WHERE MACAddress='" & macAddress & "' AND NetEnabled=True"
Else
    ' Get speed from all active adapters
    query = "SELECT Speed FROM Win32_NetworkAdapter WHERE NetEnabled=True"
End If

' Execute query
Set adapters = wmi.ExecQuery(query)

' Format and output speeds
For Each adapter In adapters
    If Not IsNull(adapter.Speed) Then
        speed = CLng(adapter.Speed)
        
        ' Convert to appropriate units
        If speed >= 1000000000 Then
            ' Convert to Gb/s
            speedText = Round(speed/1000000000, 1) & " Gb/s"
        ElseIf speed >= 1000000 Then
            ' Convert to Mb/s
            speedText = Round(speed/1000000, 0) & " Mb/s"
        Else
            ' Show in Kb/s
            speedText = Round(speed/1000, 0) & " Kb/s"
        End If
        
        Echo speedText
    End If
Next

' Clean up
Set wmi = Nothing
Set fso = Nothing
