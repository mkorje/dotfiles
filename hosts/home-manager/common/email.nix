{
  accounts.email = {
    accounts = {
      personal = {

      };
      student = {
        realName = "Max Kortge";
        thunderbird.enable = true;
        primary = true;
        university = {
          enable = true;
          username = "mkortge";
          aliases = [ "max.kortge" ];
          subdomain = "student";
        };
      };
      staff = {
        realName = "Max Kortge";
        thunderbird.enable = true;
        university = {
          enable = true;
          username = "kortgem";
          aliases = [ "m.kortge" ];
        };
      };
    };
  };

  programs.thunderbird = {
    enable = true;
    profiles = {
      mkorje = {
        isDefault = true;
      };
    };
    settings = {
      "mail.shell.checkDefaultClient" = false;
      "mail.accounthub.addressbook.enabled" = false;
      "mail.accounthub.enabled" = false;

      # https://github.com/HorlogeSkynet/thunderbird-user.js/blob/master/user.js

      # STARTUP
      "mailnews.start_page.enabled" = false;
      "browser.newtabpage.enabled" = false;

      # GEOLOCATION
      "geo.provider.ms-windows-location" = false;
      "geo.provider.use_corelocation" = false;
      "geo.provider.use_geoclue" = false;

      # QUIETER BIRD
      "extensions.getAddons.showPane" = false;
      "extensions.htmlaboutaddons.recommendations.enabled" = false;
      "browser.discovery.enabled" = false;

      # STUDIES
      "app.shield.optoutstudies.enabled" = false;
      "app.normandy.enabled" = false;
      "app.normandy.api_url" = "";

      # CRASH REPORTS
      "breakpad.reportURL" = "";
      "browser.tabs.crashReporting.sendReport" = false;
      "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;

      # OTHER
      "captivedetect.canonicalURL" = "";
      "network.captive-portal-service.enabled" = false;
      "network.connectivity-service.enabled" = false;
      "mail.instrumentation.postUrl" = "";
      "mail.instrumentation.askUser" = false;
      "mail.instrumentation.userOptedIn" = false;
      "mail.rights.override" = true;
      "app.donation.eoy.version.viewed" = 999;

      # MISCELLANEOUS
      "browser.download.start_downloads_in_tmp_dir" = true;
      "browser.uitour.enabled" = false;
      "browser.uitour.url" = "";
      "devtools.debugger.remote-enabled" = false;
      "permissions.manager.defaultsUrl" = "";
      "network.IDN_show_punycode" = true;
      "pdfjs.disabled" = false;
      "pdfjs.enableScripting" = false;
      "browser.tabs.searchclipboardfor.middleclick" = false;
      "browser.contentanalysis.enabled" = false;
      "browser.contentanalysis.default_result" = 0;
      "privacy.antitracking.isolateContentScriptResources" = true;
      "security.csp.reporting.enabled" = false;

      # TELEMETRY
      "datareporting.policy.dataSubmissionEnabled" = false;
      "datareporting.healthreport.uploadEnabled" = false;
      "toolkit.telemetry.unified" = false;
      "toolkit.telemetry.enabled" = false;
      "toolkit.telemetry.server" = "data: =";
      "toolkit.telemetry.archive.enabled" = false;
      "toolkit.telemetry.newProfilePing.enabled" = false;
      "toolkit.telemetry.shutdownPingSender.enabled" = false;
      "toolkit.telemetry.updatePing.enabled" = false;
      "toolkit.telemetry.bhrPing.enabled" = false;
      "toolkit.telemetry.firstShutdownPing.enabled" = false;
      "toolkit.coverage.opt-out" = true;
      "toolkit.coverage.endpoint.base" = "";

      # AUTO CONFIG
      "mailnews.auto_config.guess.enabled" = false;
      "mailnews.auto_config.fetchFromISP.enabled" = false;
      "mailnews.auto_config.fetchFromISP.sendEmailAddress" = false;
      "mailnews.auto_config.fetchFromISP.sslOnly" = true;
      "mailnews.auto_config.guess.sslOnly" = true;
      "mailnews.auto_config.guess.requireGoodCert" = true;
      "mail.provider.enabled" = false;

      # CHAT
      "mail.chat.enabled" = false;
      "purple.logging.log_chats" = false;
      "purple.logging.log_ims" = false;
      "purple.logging.log_system" = false;
      "purple.conversations.im.send_typing" = false;
      "mail.chat.notification_info" = 2;
    };
  };

  services.protonmail-bridge.enable = true;
}
