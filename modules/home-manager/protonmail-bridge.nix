{ lib, ... }:

let
  inherit (lib)
    mkOption
    mkDefault
    mkIf
    types
    ;
in
{
  options = {
    accounts.email.accounts = mkOption {
      type = types.attrsOf (
        types.submodule (
          { config, ... }:
          let
            server = "imap://${lib.escapeURL config.userName}@${config.imap.host}";
          in
          {
            options.flavor = mkOption {
              type = types.enum [ "protonmail-bridge" ];
            };

            config = mkIf (config.flavor == "protonmail-bridge") {
              userName = mkDefault config.address;
              imap = {
                host = "127.0.0.1";
                port = 1143;
                tls = {
                  enable = true;
                  useStartTls = true;
                };
              };
              smtp = {
                host = "127.0.0.1";
                port = 1025;
                tls = {
                  enable = true;
                  useStartTls = true;
                };
              };
              thunderbird = mkIf config.thunderbird.enable {
                settings = id: {
                  "mail.server.server_${id}.moveOnSpam" = true;
                  "mail.server.server_${id}.moveTargetMode" = 1;
                  "mail.server.server_${id}.spamActionTargetAccount" = server;
                  "mail.server.server_${id}.spamActionTargetFolder" = "${server}/Spam";
                  "mail.server.server_${id}.trash_folder_name" = "Trash";
                };
                perIdentitySettings = id: {
                  "mail.identity.id_${id}.archive_folder" = "${server}/Archive";
                  "mail.identity.id_${id}.archives_folder_picker_mode" = "1";
                  "mail.identity.id_${id}.draft_folder" = "${server}/Drafts";
                  "mail.identity.id_${id}.drafts_folder_picker_mode" = "0";
                  "mail.identity.id_${id}.fcc_folder" = "${server}/Sent";
                  "mail.identity.id_${id}.fcc_folder_picker_mode" = "0";
                };
              };
            };
          }
        )
      );
    };
  };
}
