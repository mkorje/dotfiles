# laima

## System Information

## Installation

Download the Minimal ISO image from <https://nixos.org/download/#nixos-iso> for 64-bit Intel/AMD.

```bash
wget https://channels.nixos.org/nixos-25.05/latest-nixos-minimal-x86_64-linux.iso
wget https://channels.nixos.org/nixos-25.05/latest-nixos-minimal-x86_64-linux.iso.sha256
```

Plug the USB flash drive into the computer and boot into the installer.
Switch to root user.

```bash
sudo -i
```

Run the install script and follow the instructions.

```bash
$ source <(curl -s https://raw.githubusercontent.com/mkorje/dotfiles/refs/heads/main/hosts/nixos/laima/install.sh)
Public key: age10x8y3u64h0z8reh2s4279wmu8sksv6l3vndv0a07449c2wl6tstqt5jplp
Add this public key to sops as laima. When done, press enter to continue.
```

Then reboot the machine.

```bash
reboot
```
