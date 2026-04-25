'=============================================================================
' Hard Drive Info Script for BGInfo
'=============================================================================
' Description: Shows fixed drive letters with free and total space
' Output Styles:
'   1 = Percentage (C:\ 74.7GB/118GB (63% free))
'   2 = Bar       (C:\ [¦¦¦¦¦¦¦¦¦¦] 74.7GB free)
'   3 = Compact   (C:\ 74.7/118 GB)
'   4 = Detailed  (C:\ Free: 74.7GB | Total: 118GB | Used: 43.3GB)
'   5 = Simple    (C:\ 74.7 of 118GB)
'   6 = Minimal   (C:\ 74.7/118)
'=============================================================================

' Configuration
If IsEmpty(OUTPUT_STYLE) Then OUTPUT_STYLE = 1  ' Default to Percentage style
If OUTPUT_STYLE < 1 Or OUTPUT_STYLE > 6 Then OUTPUT_STYLE = 1
IGNORE_USB = True    ' Set to False to show USB drives
SHOW_DRIVE_TYPE = False  ' Set to True to show drive type (HDD/SSD)

On Error Resume Next

' Connect to WMI
Set wmi = GetObject("winmgmts:\\.\root\cimv2")

' Get fixed drives only (Type 3)
Set drives = wmi.ExecQuery("SELECT DeviceID, FreeSpace, Size FROM Win32_LogicalDisk WHERE DriveType=3")

' Format and output drive info
For Each drive In drives
    If Not IsNull(drive.Size) Then
        ' Calculate sizes in GB
        freeGB = Round(drive.FreeSpace / 1024 / 1024 / 1024, 1)
        totalGB = Round(drive.Size / 1024 / 1024 / 1024, 0)
        usedGB = Round(totalGB - freeGB, 1)
        percentFree = Round((freeGB / totalGB) * 100, 0)
        
        ' Format output based on style
        Select Case OUTPUT_STYLE
            Case 1  ' Percentage
                Echo drive.DeviceID & "\ " & freeGB & "GB/" & totalGB & "GB (" & percentFree & "% free)"
                
            Case 2  ' Bar (10 segments)
                barCount = Round(percentFree/10, 0)
                bar = String(barCount, "¦") & String(10-barCount, "¦")
                Echo drive.DeviceID & "\ [" & bar & "] " & freeGB & "GB free"
                
            Case 3  ' Compact
                Echo drive.DeviceID & "\ " & freeGB & "/" & totalGB & " GB"
                
            Case 4  ' Detailed
                Echo drive.DeviceID & "\ Free: " & freeGB & "GB | Total: " & totalGB & "GB | Used: " & usedGB & "GB"
                
            Case 5  ' Simple
                Echo drive.DeviceID & "\ " & freeGB & " of " & totalGB & "GB"
                
            Case 6  ' Minimal
                Echo drive.DeviceID & "\ " & freeGB & "/" & totalGB
                
            Case Else  ' Default to Simple if invalid style
                Echo drive.DeviceID & "\ " & freeGB & " of " & totalGB & "GB"
        End Select
    End If
Next

' Clean up
Set wmi = Nothing