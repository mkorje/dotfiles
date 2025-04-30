# auseklis

MacBookPro16,2

## System Information

## Installation

Download the Minimal ISO image from <https://nixos.org/download/#nixos-iso> for 64-bit Intel/AMD.

```bash
wget https://channels.nixos.org/nixos-23.11/latest-nixos-minimal-x86_64-linux.iso
wget https://channels.nixos.org/nixos-23.11/latest-nixos-minimal-x86_64-linux.iso.sha256
```

Check its integrity against the SHA-256 checksum.

```bash
$ sha256sum -c latest-nixos-minimal-x86_64-linux.iso.sha256
nixos-minimal-23.11.6510.a5e4bbcb4780-x86_64-linux.iso: OK
```

Flash ISO image to a USB flash drive. You may need to use `sudo` if permission is denied trying to open your USB flash drive.

```bash
dd bs=4M if=nixos-minimal-23.11.6510.a5e4bbcb4780-x86_64-linux.iso of=/dev/USB conv=fsync oflag=direct status=progress
sudo sync
```

Secure Boot must be disabled on the computer before proceeding.

1. Power on the system and press [Delete] key to enter BIOS [Advanced Mode] as below picture
1. Click [Boot]
1. Click [Secure Boot] option
1. If OS Type Default is: Other OS, then Secure Boot state is off; Windows UEFI mode, then Secure Boot state is on.

Plug the USB flash drive into the computer and turn it on. You should be booted into the installer. If not, you may need to configure the boot order in the BIOS.

Switch to root user.

```bash
sudo -i
```

Configure networking in the installer.

```bash
$ systemctl start wpa_supplicant
$ wpa_cli
> add_network
0
> set_network 0 ssid "myhomenetwork"
OK
> set_network 0 psk "mypassword"
OK
> set_network 0 key_mgmt WPA-PSK
OK
> enable_network 0
OK
> quit
```

Run the install script and follow the instructions.

```bash
$ sh <(curl -s -L https://git.mkor.je/mkorje/nixos/raw/branch/main/hosts/auseklis/install.sh)
Enter disk encryption password: 
Public key: age186tu77ygurlctg5ng0yjflfzhp7hnxw6egmnekz4kfzwdsllm4nsd368wu
Add this public key to sops as auseklis. When done, press enter to continue.

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

Install home-manager.

```bash
nix run home-manager/master -- switch --flake git+https://git.mkor.je/mkorje/home-manager.git
```

One final reboot and all should be done!

```bash
reboot
```
