# Runs the restore-root script from hosts/nixos/common/default/btrfs.nix
# against a scratch disk in a range of layouts, checking that it either
# restores `root` from `root-blank` or refuses without touching anything else.
{ pkgs, ... }:

let
  device = "/dev/vdb";
  script =
    builtins.replaceStrings [ "/dev/disk/by-label/nixos" ] [ device ]
      (import ../hosts/nixos/common/default/btrfs.nix).boot.initrd.systemd.services."restore-root".script;
  # Mirror how NixOS wraps a unit's `script`.
  restoreRoot = pkgs.writeShellScript "restore-root" ''
    set -e
    ${script}
  '';
in
{
  name = "restore-root";

  nodes.machine =
    { pkgs, ... }:
    {
      virtualisation.emptyDiskImages = [ 512 ];
      environment.systemPackages = [ pkgs.btrfs-progs ];
    };

  testScript = ''
    DEV = "${device}"
    OTHERS = ["nix", "persist", "home", "swap"]


    def prepare(*root_cmds, blank=True):
        machine.succeed(f"mkfs.btrfs -f {DEV}", f"mount -o subvol=/ {DEV} /mnt")
        for sv in OTHERS:
            machine.succeed(f"btrfs subvolume create /mnt/{sv}", f"echo {sv} > /mnt/{sv}/marker")
        if blank:
            machine.succeed("btrfs subvolume create /mnt/root-blank", "touch /mnt/root-blank/blank")
        if root_cmds:
            machine.succeed(*root_cmds)
        machine.succeed("umount /mnt")


    def run():
        status, out = machine.execute("${restoreRoot} 2>&1")
        print(out)
        machine.succeed(f"mount -o subvol=/ {DEV} /mnt")
        return status


    def is_subvol(path):
        return machine.execute(f"btrfs subvolume show {path}")[0] == 0


    def assert_others_intact(blank=True):
        for sv in OTHERS:
            assert is_subvol(f"/mnt/{sv}"), f"{sv} was deleted"
            machine.succeed(f"grep -qx {sv} /mnt/{sv}/marker")
        if blank:
            assert is_subvol("/mnt/root-blank"), "root-blank was deleted"
            machine.succeed("test -z \"$(ls -A /mnt/root-blank | grep -vx blank)\"")


    def assert_root_restored():
        assert is_subvol("/mnt/root"), "root is not a subvolume"
        assert machine.succeed("ls -A /mnt/root").split() == ["blank"], "root was not restored from root-blank"
        assert machine.succeed("btrfs subvolume list -o /mnt/root").strip() == "", "root has leftover subvolumes"


    machine.wait_for_unit("multi-user.target")
    machine.succeed("mkdir -p /mnt")

    with subtest("normal root with a nested subvolume is restored"):
        prepare(
            "btrfs subvolume create /mnt/root",
            "touch /mnt/root/junk",
            "mkdir -p /mnt/root/var/lib",
            "btrfs subvolume create /mnt/root/var/lib/machines",
            "touch /mnt/root/var/lib/machines/junk",
        )
        assert run() == 0
        assert_root_restored()
        assert_others_intact()
        machine.succeed("umount /mnt")

    with subtest("deeply nested subvolumes are restored"):
        prepare(
            "btrfs subvolume create /mnt/root",
            "btrfs subvolume create /mnt/root/a",
            "btrfs subvolume create /mnt/root/a/b",
            "btrfs subvolume create /mnt/root/a/b/c",
            "touch /mnt/root/a/b/c/junk",
        )
        assert run() == 0
        assert_root_restored()
        assert_others_intact()
        machine.succeed("umount /mnt")

    with subtest("nested subvolume with spaces in its name is restored"):
        prepare(
            "btrfs subvolume create /mnt/root",
            "btrfs subvolume create '/mnt/root/my subvol'",
            "touch '/mnt/root/my subvol/junk'",
        )
        assert run() == 0
        assert_root_restored()
        assert_others_intact()
        machine.succeed("umount /mnt")

    with subtest("missing root is recreated"):
        prepare()
        assert run() == 0
        assert_root_restored()
        assert_others_intact()
        machine.succeed("umount /mnt")

    with subtest("root as a plain directory is refused and nothing is deleted"):
        prepare("mkdir /mnt/root", "touch /mnt/root/junk")
        assert run() != 0
        assert not is_subvol("/mnt/root")
        machine.succeed("test -e /mnt/root/junk")
        assert_others_intact()
        machine.succeed("umount /mnt")

    # A relative symlink is the only way for root to resolve to another
    # subvolume, including the top-level one.
    for target in ["persist", "."]:
        with subtest(f"root as a symlink to {target} is refused and nothing is deleted"):
            prepare(f"ln -s {target} /mnt/root")
            assert run() != 0
            machine.succeed("test -L /mnt/root")
            assert_others_intact()
            machine.succeed("umount /mnt")

    with subtest("missing root-blank is refused and root is left alone"):
        prepare("btrfs subvolume create /mnt/root", "touch /mnt/root/junk", blank=False)
        assert run() != 0
        assert is_subvol("/mnt/root")
        machine.succeed("test -e /mnt/root/junk")
        assert_others_intact(blank=False)
        machine.succeed("umount /mnt")
  '';
}
