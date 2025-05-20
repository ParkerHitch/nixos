{ config, pkgs, lib, inputs, ... }:
let
  firefox-addons = inputs.firefox-addons.packages.${pkgs.system};
  lock-false = {
    Value = false;
    Status = "locked";
  };
  lock-true = {
    Value = true;
    Status = "locked";
  };
in
{
  options = {
    modules.firefox = {
      enable = lib.mkEnableOption "whether or not to enable firefox";
    };
  };
  config = lib.mkIf config.modules.firefox.enable {
    programs.firefox = {
      enable = true;

      # see https://mozilla.github.io/policy-templates
      policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        # EnableTrackingProtection = {
        #   Value= true;
        #   Locked = true;
        #   Cryptomining = true;
        #   Fingerprinting = true;
        # };
        DisablePocket = true;
        # DisableFirefoxScreenshots = true;
        # No funny pages
        OverrideFirstRunPage = "";
        OverridePostUpdatePage = "";
        DontCheckDefaultBrowser = true;
        DisplayBookmarksToolbar = "newtab";
        DisplayMenuBar = "default-off";
        SearchBar = "unified";
      };

      profiles = {

        main = {
          id = 0;
          name = "main";
          isDefault = true;

          # Straight from about:config
          settings = {            
            # Don't sync addons or prefs with mozilla account
            "services.sync.engine.addons" = false;
            "services.sync.engine.prefs" = false;
            "extensions.pocket.enabled" = lock-false;
          };

          extensions = {
            packages = with firefox-addons; [
              ublock-origin
              bitwarden
              offline-qr-code-generator
            ];
          };
        };

        purdue = {
          id = 1;
          name = "Purdue";
          isDefault = false;

          extensions = {
            packages = with firefox-addons; [
              ublock-origin
            ];
          };
        };

      };
    };
  };
}
