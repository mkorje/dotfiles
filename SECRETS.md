# Secret management

## Yubikeys

yubikey serials

- primary:   18630670 (yka)
- secondary: 18630960 (ykb)

| ID | Created | Public Key |
|---|---|---|
| yka-age1-nixos | Wed, 21 Feb 2024 04:52:45 +0000 | age1yubikey1qfcdnl3tyfyexd2d6qw9n4m6m3c9h8kpakx5dsvlvar7s2kduluxc5suwcg |
| ykb-age1-nixos | Fri, 08 Mar 2024 08:59:44 +0000 | age1yubikey1qv6cjrv7zdw9rmkwkluyzxyjc50ad3sxuft45yp3jtgn98u0xdjnc6hzcnr |
| nixos-a_yka-age1-nixos | | age1ye5vlhfayp9glvxa4xn4z7jactekk2qelavmevn780uxmxqfsqrspjp6vv |
| nixos-b_ykb-age1-nixos | | age1sdhk4k70cymunsgtpys0fjxlzrfw0qpl99h5g460evs43gec4paqg0lt83 |
| yka-age2-files | Wed, 21 Feb 2024 05:10:04 +0000 | age1yubikey1q0vjcxgue4cvydzndvt6yxln6pw076c8syyy764uf47fqrruqs3tw05u839 |
| ykb-age2-files | Fri, 08 Mar 2024 09:01:02 +0000 | age1yubikey1qwrunnkavx2q996cg4rax3a7k8eshr0zedxm8d3gzv8532h9dm05ckpszus |
| yka-fido-ssh:nixos | 2024-02-21 | <sk-ssh-ed25519@openssh.com> AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIAy85V584V07OJ5VrT4sppXhOUguaUOtIvzw9GNw2J6XAAAACXNzaDpuaXhvcw== ssh:nixos |
| ykb-fido-ssh:nixos | 2024-03-08 | <sk-ssh-ed25519@openssh.com> AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIL7Bw28cFjA5JWcwBEA/LT4ILIA0HikwTic+7agOAkhnAAAACXNzaDpuaXhvcw== ssh:nixos |
| yka-fido-ssh:git-auth | 2024-03-04 | <sk-ssh-ed25519@openssh.com> AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIPbeiRyeKkmTpBmU1jUPV7rDfzVqfsJXlnxOevKC5fz8AAAADHNzaDpnaXQtYXV0aA== ssh:git-auth |
| ykb-fido-ssh:git-auth | 2024-03-08 | <sk-ssh-ed25519@openssh.com> AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIP1S8LK7srLzZTWMCl9aq0z7a4zOhseWpkwplrfGS79EAAAADHNzaDpnaXQtYXV0aA== ssh:git-auth |
| yka-fido-ssh:git-sign | 2024-03-04 | <sk-ssh-ed25519@openssh.com> AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIF8WxK7cDi0iuCous6VEp58VPJv5ZpjiXSBxxtBJ/uHBAAAADHNzaDpnaXQtc2lnbg== ssh:git-sign |
| ykb-fido-ssh:git-sign | 2024-03-08 | <sk-ssh-ed25519@openssh.com> AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIKlgP5z70ru2goxTGh3xNKytLGgdyaKbMHW8MICrIGdiAAAADHNzaDpnaXQtc2lnbg== ssh:git-sign |
| yka-fido-ssh:comp30023 | 2025-03-04 | <sk-ssh-ed25519@openssh.com> AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAINvK1J1/YAmEiYwe6DbHqfdo+EBegUwoe9xJ91s/xD6FAAAADXNzaDpjb21wMzAwMjM= ssh:comp30023 |

### FIDO2 Resident Keys (for ssh)

| ID | Date Created | Public Key |
|---|---|---|
| ykX-fido-ssh:NAME | 2024-01-01 | <sk-ssh-ed25519@openssh.com> AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIMLFdO6VjZKwNs/2HIqf9q1oNOAPwBvHz/0rnUDhdYzxAAAACHNzaDpOQU1F ssh:NAME |

To create an ssh key that is stored on the Yubikey:

```shell
$ ssh-keygen -t ed25519-sk -a 1000 -O resident -O verify-required -O application=ssh:<NAME> -N "" -f ~/.ssh/id_ed25519_sk_rk_<NAME>
Generating public/private ed25519-sk key pair.
You may need to touch your authenticator to authorize key generation.
Enter PIN for authenticator:
You may need to touch your authenticator again to authorize key generation.
Your identification has been saved in /home/USERNAME/.ssh/id_ed25519_sk_rk_<NAME>
Your public key has been saved in /home/USERNAME/.ssh/id_ed25519_sk_rk_<NAME>.pub
The key fingerprint is:
SHA256:5yAtdwUn3oqNMiknNlvnj6b/h1otEFP9KqOgTJA04XE USERNAME@HOSTNAME
The key's randomart image is:
+[ED25519-SK 256]-+
|  o.E     +..    |
| .oo     o =.    |
| ..o    o . o.   |
|  o    o * o  .  |
|   .= O S =  .   |
|   ..B.O *o..    |
|   o.. ...++.    |
|    o   o+...    |
|      .++oo.     |
+----[SHA256]-----+
```

When on a new system, to generate the identity key file:

```shell
$ cd ~/.ssh
$ ssh-keygen -K
Enter PIN for authenticator:
You may need to touch your authenticator to authorize key download.
Enter passphrase for "id_ed25519_sk_rk_nixos" (empty for no passphrase): # there is no passphrase
Enter same passphrase again:
Saved ED25519-SK key ssh:nixos to id_ed25519_sk_rk_nixos
Saved ED25519-SK key ssh:git-auth to id_ed25519_sk_rk_git-auth
Saved ED25519-SK key ssh:git-sign to id_ed25519_sk_rk_git-sign
Saved ED25519-SK key ssh:comp30023 to id_ed25519_sk_rk_comp30023
```

### PIV Certificate Slots 82-95: Retired Key Management (for age)

| ID | Created | Public Key |
|---|---|---|
| ykX-ageSLOT-NAME | Mon, 01 Jan 2024 00:00:00 +0000 | age1yubikey1qdu59n526k27kxgqw2wngctwq9rm2jchfk004a7fzp5qflwp6ys3ypkpk9a |
| NAME-X_ykX-ageSLOT-NAME | | age186tu77ygurlctg5ng0yjflfzhp7hnxw6egmnekz4kfzwdsllm4nsd368wu |

To generate an age identity that is stored inside a Yubikey:

```shell
$ age-plugin-yubikey -g --slot SLOT --name NAME
🎲 Generating key...

Enter PIN for YubiKey with serial SERIAL (default is 123456): [hidden]

🔏 Generating certificate...
👆 Please touch the YubiKey
#       Serial: SERIAL, Slot: SLOT
#         Name: NAME
#      Created: Mon, 01 Jan 2024 00:00:00 +0000
#   PIN policy: Once   (A PIN is required once per session, if set)
# Touch policy: Always (A physical touch is required for every decryption)
#    Recipient: age1yubikey1qdu59n526k27kxgqw2wngctwq9rm2jchfk004a7fzp5qflwp6ys3ypkpk9a
AGE-PLUGIN-YUBIKEY-1PEYPCQVRUZUKVRC8ZTUZV
```

Once an identity has been created, you can regenerate it later and store it in a file to use with an age client:

```shell
$ age-plugin-yubikey --identity --slot SLOT > ~/.age/ykX-ageSLOT-NAME.txt
Recipient: age1yubikey1qdu59n526k27kxgqw2wngctwq9rm2jchfk004a7fzp5qflwp6ys3ypkpk9a
```

To use an age identity that is stored inside a Yubikey with SOPS, we create an age identity and encrypt it with the age identity on a Yubikey:

```shell
$ age-keygen | age -e -r age1yubikey1qdu59n526k27kxgqw2wngctwq9rm2jchfk004a7fzp5qflwp6ys3ypkpk9a -o ~/.age/NAME-X_ykX-ageSLOT-NAME.enc
Public key: age186tu77ygurlctg5ng0yjflfzhp7hnxw6egmnekz4kfzwdsllm4nsd368wu
```

Note that this key _cannot_ be regenerated. Do not lose it!

Now to use the identity with SOPS, in bash:

```bash
SOPS_AGE_KEY=$(age -i ~/.age/ykX-ageSLOT-NAME.txt -d ~/.age/NAME-X_ykX-ageSLOT-NAME.enc) sops FILE
```

And in fish:

```fish
SOPS_AGE_KEY=(age -i ~/.age/ykX-ageSLOT-NAME.txt -d ~/.age/NAME-X_ykX-ageSLOT-NAME.enc | string split0) sops FILE
```

## TODO

- For home-manager, store ssh key "private" key file encrypted with sops + public key in repo
