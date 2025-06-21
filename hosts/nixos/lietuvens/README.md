# lietuvens

## System Information

## Installation

Download the Minimal ISO image from <https://nixos.org/download/#nixos-iso> for 64-bit Intel/AMD.

```bash
wget https://channels.nixos.org/nixos-25.05/latest-nixos-minimal-x86_64-linux.iso
wget https://channels.nixos.org/nixos-25.05/latest-nixos-minimal-x86_64-linux.iso.sha256
```

Check its integrity against the SHA-256 checksum.

```bash
$ sha256sum -c latest-nixos-minimal-x86_64-linux.iso.sha256
nixos-minimal-25.05.804391.b2485d569675-x86_64-linux.iso: OK
```

Flash ISO image to a USB.

```bash
doas dd bs=4M conv=fsync oflag=direct status=progress if=nixos-minimal-25.05.804391.b2485d569675-x86_64-linux.iso of=/dev/sdX
doas sync
```

Secure Boot must be disabled on the computer before proceeding.

Plug the USB flash drive into the computer and boot into the installer.

Switch to root user.

```bash
sudo -i
```

Run the install script and follow the instructions.

```bash
$ source <(curl -s https://raw.githubusercontent.com/mkorje/dotfiles/refs/heads/main/hosts/nixos/lietuvens/install.sh)
Public key: age10x8y3u64h0z8reh2s4279wmu8sksv6l3vndv0a07449c2wl6tstqt5jplp
Add this public key to sops as lietuvens. When done, press enter to continue.
```

Then reboot the machine.

```bash
reboot
```

Press `F2` or `DEL` to enter BIOS. Set a password for the BIOS.

1. Click [Main]
1. Click [Security] option
1. Click Administrator Password
   Then change to UEFI firmware Setup Mode.
1. Click [Boot]
1. Click [Secure Boot] option
1. Set OS Default Type to Windows UEFI mode
1. Click [Key Management] option
1. Click Clear Secure Boot Keys
   Then click [Exit] and save changes and reset.

Now let the system boot and enter the encryption password. At the login screen, press `F2` and change the command to bash. Then login.

Enroll the secure boot keys and then reboot again.

```bash
doas sbctl enroll-keys --tpm-eventlog
reboot
```

Again, let the system boot and enter the encryption password. At the login screen, press `F2` and change the command to bash. Then login.

Check secure boot status.

```bash
bootctl status
```

All should be done!
