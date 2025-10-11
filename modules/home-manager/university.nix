{ lib, ... }:

with lib;

{
  options = {
    accounts.email.accounts = mkOption {
      type = types.attrsOf (
        types.submodule (
          { config, ... }:
          let
            cfg = config.university;
          in
          {
            options.university = {
              enable = mkEnableOption "automatic configuration for university email";
              domain = mkOption {
                type = types.str;
                default = "unimelb.edu.au";
              };
              subdomain = mkOption {
                type = types.str;
                default = "";
              };
              fullDomain = mkOption {
                type = types.str;
                readOnly = true;
              };
              username = mkOption {
                type = types.str;
              };
              aliases = mkOption {
                type = with types; listOf str;
                default = [ ];
              };
            };

            config = mkIf cfg.enable {
              university.fullDomain =
                if cfg.subdomain == "" then cfg.domain else "${cfg.subdomain}.${cfg.domain}";
              address = "${cfg.username}@${cfg.fullDomain}";
              aliases = map (alias: "${alias}@${cfg.fullDomain}") cfg.aliases;
              smtp.authentication = "xoauth2";
              imap.authentication = "xoauth2";
              flavor = "outlook.office365.com";
              thunderbird = mkIf config.thunderbird.enable {
                settings = id: {
                  "mail.smtpserver.smtp_${id}.authMethod" = 10; # 10 = OAuth2
                  "mail.server.server_${id}.authMethod" = 10; # 10 = OAuth2
                  "mail.server.server_${id}.moveOnSpam" = true;
                  "mail.server.server_${id}.moveTargetMode" = 1;
                  "mail.server.server_${id}.spamActionTargetAccount" =
                    "imap://${cfg.username}%40${cfg.fullDomain}@outlook.office365.com";
                  "mail.server.server_${id}.spamActionTargetFolder" =
                    "imap://${cfg.username}%40${cfg.fullDomain}@outlook.office365.com/Junk Email";
                  "mail.server.server_${id}.trash_folder_name" = "Deleted Items";
                  "mail.server.server_${id}.using_subscription" = false;
                };
                perIdentitySettings = id: {
                  "mail.identity.id_${id}.archive_folder" =
                    "imap://${cfg.username}%40${cfg.fullDomain}@outlook.office365.com/Archive";
                  "mail.identity.id_${id}.archives_folder_picker_mode" = 1;
                  "mail.identity.id_${id}.draft_folder" =
                    "imap://${cfg.username}%40${cfg.fullDomain}@outlook.office365.com/Drafts";
                  "mail.identity.id_${id}.drafts_folder_picker_mode" = 1;
                  "mail.identity.id_${id}.fcc_folder" =
                    "imap://${cfg.username}%40${cfg.fullDomain}@outlook.office365.com/Sent Items";
                  "mail.identity.id_${id}.fcc_folder_picker_mode" = 1;
                };
              };
            };
          }
        )
      );
    };
  };
}
