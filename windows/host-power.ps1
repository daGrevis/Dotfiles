# Shuts down or reboots this Windows host when the NixOS guest asks for it.
# The guest writes "shutdown" or "reboot" to .host-power in the shared folder.
# See README.md.

$vm   = "Nixo"
$flag = "C:\Users\me\Desktop\NixOS-Shared\.host-power"
$vbox = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"

# Ignore a request from before logon.
Remove-Item $flag -Force -ErrorAction SilentlyContinue

while ($true) {
    Start-Sleep 1
    $cmd = "$(Get-Content $flag -Raw -ErrorAction SilentlyContinue)".Trim()
    if ($cmd -notin "shutdown", "reboot") { continue }
    # Never shut down while the flag exists, or each logon shuts down again.
    Remove-Item $flag -Force -ErrorAction SilentlyContinue
    if (Test-Path $flag) { continue }

    # Stop the guest with ACPI, because Windows shutdown kills the VM.
    & $vbox controlvm $vm acpipowerbutton

    # At the same time, ask the apps to close. Skip the apps of Windows, because
    # WM_CLOSE to the taskbar opens a dialog. Skip the VM window, because
    # WM_CLOSE to it opens the close dialog of the VM.
    $apps = Get-Process | Where-Object { $_.MainWindowHandle -ne 0 -and $_.Path -notlike "$env:windir\*" -and $_.ProcessName -ne "VirtualBoxVM" }
    $apps | ForEach-Object { $_.CloseMainWindow() } | Out-Null

    # Wait until the VM is off and the apps are closed (maximum 2 minutes).
    $end = (Get-Date).AddMinutes(2)
    while ((Get-Date) -lt $end -and (((& $vbox list runningvms) -match "`"$vm`"") -or ($apps | Where-Object { $_.Refresh(); !$_.HasExited -and $_.MainWindowHandle -ne 0 }))) { Start-Sleep 1 }

    # Force, because an app that blocks the shutdown (for example VBoxSVC)
    # stops it forever.
    if ($cmd -eq "shutdown") { shutdown /s /f /t 0 } else { shutdown /r /f /t 0 }
}
