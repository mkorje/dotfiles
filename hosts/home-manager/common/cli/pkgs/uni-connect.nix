{
  stdenvNoCC,
  writeShellScript,
  writeShellScriptBin,
  makeDesktopItem,
  copyDesktopItems,
  gpauth,
  gpclient,
  inotify-tools,
  vpn-slice,
}:

let
  disconnect = writeShellScriptBin "disconnect" ''
    { tail --pid=$1 -f /dev/null; ${gpclient}/bin/gpclient -qq disconnect; } &
  '';
  setup = writeShellScript "uni-connect" ''
    set -euo pipefail

    server=vpn.unimelb.edu.au
    script="${vpn-slice}/bin/vpn-slice --no-host-names --no-ns-hosts $1 &>/dev/null"

    doas ${disconnect}/bin/disconnect $PPID

    ${gpauth}/bin/gpauth --fix-openssl --default-browser $server 2>/dev/null |
    doas ${gpclient}/bin/gpclient --fix-openssl connect --cookie-on-stdin -s "$script" -qq $server &
    ${inotify-tools}/bin/inotifywait -q --include gpclient.lock -e create /var/run

    nc $1 $2
  '';

in
stdenvNoCC.mkDerivation {
  name = "uni-connect";

  dontUnpack = true;

  nativeBuildInputs = [ copyDesktopItems ];

  installPhase = ''
    runHook preInstall
    install -Dm555 ${setup} $out/bin/${setup.name}
    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "uni-connect";
      desktopName = "uni-connect";
      exec = "${gpclient}/bin/gpclient launch-gui %u";
      mimeTypes = [ "x-scheme-handler/globalprotectcallback" ];
      noDisplay = true;
    })
  ];
}
