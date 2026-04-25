'=============================================================================
' OS Version Info Script for BGInfo
'=============================================================================
' Description: This script gets Windows version details from registry and WMI
' Example outputs: "Windows 11 Pro 24H2"
'=============================================================================

' Configuration
REMOVE_MICROSOFT = True  ' Set to False to keep "Microsoft" in the name

On Error Resume Next

' Connect to registry and WMI
Set shell = CreateObject("WScript.Shell")
Set wmi = GetObject("winmgmts:\\.\root\cimv2")
regPath = "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\"

If Err.Number <> 0 Then
    Echo "N/A"
    WScript.Quit 1
End If

' Get OS caption from WMI (wmic.exe-free)
osCaption = ""
Set osItems = wmi.ExecQuery("SELECT Caption FROM Win32_OperatingSystem")
For Each osItem In osItems
    If Not IsNull(osItem.Caption) Then
        osCaption = Trim(osItem.Caption)
        Exit For
    End If
Next

' Remove "Microsoft" if configured
If REMOVE_MICROSOFT And osCaption <> "" Then
    osCaption = Replace(osCaption, "Microsoft ", "")
End If

' Get DisplayVersion, then fallback to ReleaseId for older versions
displayVersion = ""
displayVersion = Trim(CStr(shell.RegRead(regPath & "DisplayVersion")))
If Err.Number <> 0 Then
    Err.Clear
    displayVersion = Trim(CStr(shell.RegRead(regPath & "ReleaseId")))
    If Err.Number <> 0 Then
        Err.Clear
        displayVersion = ""
    End If
End If

' Output the formatted version (single space between parts)
If osCaption = "" And displayVersion = "" Then
    Echo "N/A"
ElseIf displayVersion <> "" And osCaption <> "" Then
    Echo osCaption & " " & displayVersion
Else
    If osCaption <> "" Then
        Echo osCaption
    Else
        Echo displayVersion
    End If
End If

' Clean up
Set shell = Nothing
Set wmi = Nothing
Set osItems = Nothing