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
              type = types.enum [ "unimelb" ];
            };

            config = mkIf (config.flavor == "unimelb") {
              userName = mkDefault config.address;
              imap = {
                host = "outlook.office365.com";
                port = 993;
                tls.enable = true;
                authentication = mkDefault "xoauth2";
              };
              smtp = {
                host = "smtp.office365.com";
                port = 587;
                tls = {
                  enable = true;
                  useStartTls = true;
                };
                authentication = mkDefault "xoauth2";
              };
              thunderbird = mkIf config.thunderbird.enable {
                settings = id: {
                  "mail.server.server_${id}.moveOnSpam" = true;
                  "mail.server.server_${id}.moveTargetMode" = 1;
                  "mail.server.server_${id}.spamActionTargetAccount" = server;
                  "mail.server.server_${id}.spamActionTargetFolder" = "${server}/Junk Email";
                  "mail.server.server_${id}.trash_folder_name" = "Deleted Items";
                  "mail.server.server_${id}.using_subscription" = false;
                };
                perIdentitySettings = id: {
                  "mail.identity.id_${id}.archive_folder" = "${server}/Archive";
                  "mail.identity.id_${id}.archives_folder_picker_mode" = "1";
                  "mail.identity.id_${id}.draft_folder" = "${server}/Drafts";
                  "mail.identity.id_${id}.drafts_folder_picker_mode" = "1";
                  "mail.identity.id_${id}.fcc" = false;
                  "mail.identity.id_${id}.fcc_folder" = "${server}/Sent Items";
                  "mail.identity.id_${id}.fcc_folder_picker_mode" = "1";
                };
              };
            };
          }
        )
      );
    };
  };
}
