# Boots through systemd stage 1 with an impermanent btrfs root using the real
# restore-root unit, checking that `/` is wiped on every boot while `/persist`
# survives. With `luks = true` the btrfs filesystem sits inside a LUKS
# container like on the desktops, and the rollback is checked to wait for it
# to be unlocked.
{
  luks ? false,
}:
{ lib, ... }:

{
  name = "restore-root-boot" + lib.optionalString luks "-luks";

  nodes.machine =
    { pkgs, ... }:
    {
      virtualisation = {
        emptyDiskImages = [ 1024 ];
        useBootLoader = true;
        useEFIBoot = true;
        # The btrfs root starts out empty, so the store has to come from the host.
        mountHostNixStore = true;
      };
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.initrd.systemd.enable = true;
      environment.systemPackages = [
        pkgs.btrfs-progs
        pkgs.cryptsetup
      ];

      specialisation.impermanent.configuration = {
        imports = [ ../hosts/nixos/common/default/btrfs.nix ];

        # qemu-vm.nix clears this with mkVMOverride, so it has to match.
        boot.initrd.luks.devices = lib.mkIf luks (
          lib.mkVMOverride { "nixos-enc".device = "/dev/disk/by-label/nixos-crypt"; }
        );

        fileSystems = lib.mkVMOverride {
          "/" = {
            fsType = lib.mkForce "btrfs";
            options = [ "subvol=root" ];
          };
          "/persist" = {
            device = "/dev/disk/by-label/nixos";
            fsType = "btrfs";
            options = [ "subvol=persist" ];
            neededForBoot = true;
          };
        };
      };
    };

  testScript =
    { nodes, ... }:
    let
      impermanent = nodes.machine.specialisation.impermanent.configuration.system.build.toplevel;
    in
    ''
      import re
      import datetime
      import time

      LUKS = ${if luks then "True" else "False"}


      def first_timestamp(unit, pattern):
          out = machine.succeed(f"journalctl -b -o short-monotonic --no-pager 'UNIT={unit}'")
          for line in out.splitlines():
              m = re.match(r"\[\s*([0-9.]+)\].*" + pattern, line)
              if m:
                  return float(m.group(1))
          raise Exception(f"no '{pattern}' for {unit} in this boot's journal")


      def check_ordering():
          device = first_timestamp(r"dev-disk-by\x2dlabel-nixos.device", "Found device")
          started = first_timestamp("restore-root.service", "Starting")
          finished = first_timestamp("restore-root.service", "Finished")
          sysroot = first_timestamp("sysroot.mount", "Mounting")
          events = [(device, "found /dev/disk/by-label/nixos"), (started, "rollback started"), (finished, "rollback finished"), (sysroot, "mounting /sysroot")]
          if LUKS:
              events.append((first_timestamp(r"systemd-cryptsetup@nixos\x2denc.service", "Finished"), "cryptsetup finished"))
          print("initrd ordering:\n" + "\n".join(f"  {t:10.6f}  {e}" for t, e in sorted(events)))
          assert device <= started, "rollback started before the root device appeared"
          assert finished <= sysroot, "/sysroot was mounted before the rollback finished"


      def boot():
          machine.start()
          if LUKS:
              machine.wait_for_console_text("Please enter passphrase for disk", timeout=datetime.timedelta(minutes=2))
              # Make unlocking visibly slow so an ordering bug would show up.
              time.sleep(3)
              machine.send_console("supersecret\n")
          machine.wait_for_unit("multi-user.target")
          assert "(initrd)" in machine.succeed("systemd-analyze")
          assert "subvol=/root" in machine.succeed("findmnt -no OPTIONS /")
          machine.succeed("journalctl -b | grep -q 'Restoring blank subvolume'")
          check_ordering()


      def reboot():
          machine.shutdown()
          boot()


      machine.wait_for_unit("multi-user.target")

      with subtest("set up the btrfs disk and boot from it"):
          dev = "/dev/vdb"
          if LUKS:
              machine.succeed(
                  "echo -n supersecret | cryptsetup luksFormat -q --type luks2 --iter-time=1 --label nixos-crypt /dev/vdb -",
                  "echo -n supersecret | cryptsetup luksOpen -q /dev/vdb nixos-enc",
              )
              dev = "/dev/mapper/nixos-enc"
          machine.succeed(
              f"mkfs.btrfs -L nixos {dev}",
              f"mkdir -p /mnt && mount -o subvol=/ {dev} /mnt",
              "btrfs subvolume create /mnt/root-blank",
              "btrfs subvolume create /mnt/persist",
              "btrfs subvolume snapshot /mnt/root-blank /mnt/root",
              "umount /mnt",
          )
          if LUKS:
              machine.succeed("cryptsetup luksClose nixos-enc")
          machine.succeed(
              # The VM's own root is also labelled nixos; get it out of the way.
              "e2label $(findmnt -no SOURCE /) old-root",
              "udevadm settle",
          )
          machine.succeed("${impermanent}/bin/switch-to-configuration boot")
          reboot()

      with subtest("root is wiped and persist survives across reboots"):
          for _ in range(2):
              machine.succeed(
                  "touch /junk",
                  "mkdir -p /srv",
                  "btrfs subvolume create /srv/a",
                  "btrfs subvolume create /srv/a/b",
                  "touch /srv/a/b/junk",
                  "date >> /persist/boots",
              )
              reboot()
              machine.fail("test -e /junk")
              machine.fail("test -e /srv/a")
          assert len(machine.succeed("cat /persist/boots").splitlines()) == 2
    '';
}
