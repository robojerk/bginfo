On Error Resume Next

' Connect to WMI
Set wmi = GetObject("winmgmts:\\.\root\cimv2")
Set cpu = wmi.ExecQuery("SELECT * FROM Win32_Processor")

' Get CPU name
For Each item In cpu
    ' Return the value directly - this is how BGInfo expects it
    Echo item.Name
    Exit For
Next

' Clean up
Set cpu = Nothing
Set wmi = Nothing