'=============================================================================
' OS Version Info Script for BGInfo
'=============================================================================
' Description: This script gets Windows version details from registry and WMI
' Example outputs: "Windows 11 Pro 24H2"
'=============================================================================

' Configuration
REMOVE_MICROSOFT = True  ' Set to False to keep "Microsoft" in the name

On Error Resume Next

' Connect to registry and create shell
Set shell = CreateObject("WScript.Shell")
regPath = "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\"

' Get OS Caption from WMIC
Set wmicExec = shell.Exec("wmic os get Caption /value")
osCaption = wmicExec.StdOut.ReadAll()

' Clean up the caption text
osCaption = Replace(osCaption, "Caption=", "")
osCaption = Replace(osCaption, vbCr, "")
osCaption = Replace(osCaption, vbLf, "")
osCaption = Replace(osCaption, vbTab, "")
osCaption = Trim(osCaption)

' Remove "Microsoft" if configured
If REMOVE_MICROSOFT Then
    osCaption = Replace(osCaption, "Microsoft ", "")
End If

' Get Display Version from registry and clean it
displayVersion = Trim(shell.RegRead(regPath & "DisplayVersion"))

' Output the formatted version (single space between parts)
If displayVersion <> "" Then
    Echo osCaption & " " & displayVersion
Else
    Echo osCaption
End If

' Clean up
Set shell = Nothing
Set wmicExec = Nothing