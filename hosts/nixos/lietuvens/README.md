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

Press `DEL` to enter the BIOS.
Set a password for the BIOS and reset Secure Boot to setup mode.
Go to [Security] and click [Reset To Setup Mode].
Go to the exit, and click on the UEFI OS boot option (don't save and reset/exit as it will leave setup mode then!).
Boot the system and login (the encryption password is blank).
Enroll the secure boot keys, and then reboot again.

```bash
doas sbctl enroll-keys
reboot
```

Go to the bios and enable Secure Boot.
Save and reset.
Again, let the system boot and login.
Check secure boot status.

```bash
bootctl status
```

Now we can enroll the TPM.
Make sure to save the recovery key.

```bash
doas systemd-cryptenroll /dev/sda2 --recovery-key
doas systemd-cryptenroll /dev/sda2 --wipe-slot=empty --tpm2-device=auto --tpm2-pcrs=7
```

All should be done!
