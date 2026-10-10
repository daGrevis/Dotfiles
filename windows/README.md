# Windows

## About

Scripts and settings for the Windows host that runs NixOS in VirtualBox.

## VirtualBox VM

### VM Settings

The VM is `Nixo`. These settings are different from the defaults:

- Display: 3D acceleration off.
- Network: bridged adapter, adapter type virtio-net.
- Storage: no optical drive. NixOS installs the Guest Additions
  (`virtualisation.virtualbox.guest.enable`), so the VM does not need
  `VBoxGuestAdditions.iso`.
- Shared folders: `NixOS-Shared` for `C:\Users\me\Desktop\NixOS-Shared`,
  writable, no auto-mount. NixOS mounts it at `/mnt/nixos-shared`.
- General: shared clipboard and drag and drop are `Bidirectional`.

### Setting the Icon File

```sh
cd C:\Program Files\Oracle\VirtualBox
VBoxManage.exe modifyvm Nixo --iconfile "C:\Users\me\Pictures\Icons\nixos.png"
```

## Host Power

### How It Works

`bb-host` and `brb-host` in the guest shut down or reboot the Windows host.
The guest writes `shutdown` or `reboot` to `.host-power` in the shared folder.
The `./host-power.ps1` script reads that file every second. It stops the VM
with ACPI and asks the apps to close at the same time. When the VM is off and
the apps are closed (maximum 2 minutes), it runs `shutdown /f`, which kills the
apps that are still open.

The script accepts only `shutdown` and `reboot`. It ignores all other content.

### Setup

1. Copy `host-power.ps1` to `C:\Users\me\Desktop\Scripts\host-power.ps1`. Do not
   put it in the shared folder, because the guest can write to that folder.
2. In PowerShell as administrator, register a task that starts the script at logon:

```powershell
Register-ScheduledTask HostPower `
  -Trigger (New-ScheduledTaskTrigger -AtLogOn) `
  -Action (New-ScheduledTaskAction -Execute powershell.exe -Argument '-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File C:\Users\me\Desktop\Scripts\host-power.ps1') `
  -Settings (New-ScheduledTaskSettingsSet -ExecutionTimeLimit 0)
Start-ScheduledTask HostPower
```

### Remove

```powershell
Unregister-ScheduledTask HostPower
```
