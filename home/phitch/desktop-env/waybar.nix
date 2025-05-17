{ config, lib, pkgs, ... } :
let
  cfg = config.programs.waybar;
  optional = lib.optional;
in
{
  programs.waybar.enable = true;

  # programs.waybar.settings = d
  # programs.waybar.style = d

  programs.waybar.systemd.enable = false;

  # TODO:
  # Make this somehow depend on if uwsm is set in the nixos config
  
  # The home manager ppl want to attatch waybar to their weird tray systemd target.
  # That ain't gonna fly.
  # We are gonna basically use uwsm's systemd example here: https://github.com/Vladimir-csp/uwsm/blob/master/example-units/waybar.service
  # This way it'll integrate with uwsm good and no need to do weird hacks.
  systemd.user.services.waybar = {
    Unit = {
      Description = "Highly customizable Wayland bar for Sway and Wlroots based compositors.";
      Documentation = "man:waybar(5)";
      After = [ "graphical-session.target" ];
      # Not ideal but should work for now
      ConditionEnvironment = "WAYLAND_DISPLAY";
      X-Restart-Triggers = 
	optional (builtins.hasAttr "waybar/config" config.xdg.configFile) "${config.xdg.configFile."waybar/config".source}"
	++ optional (builtins.hasAttr "waybar/style.css" config.xdg.configFile) "${config.xdg.configFile."waybar/style.css".source}";
    };

    Service = {
      Type = "exec";
      # autostart is not in path. Gotta find that somewhere eventually
      # ExecCondition=''/lib/systemd/systemd-xdg-autostart-condition "wlroots:sway:Wayfire:labwc:Hyprland" ""'';
      ExecStart = "${cfg.package}/bin/waybar${lib.optionalString cfg.systemd.enableDebug " -l debug"}";
      ExecReload = "${pkgs.coreutils}/bin/kill -SIGUSR2 $MAINPID";
      Restart = "on-failure";
      Slice = "app-graphical.slice";
    };

    Install = {
      WantedBy = [
	"graphical-session.target"
      ];
    };
  };
}
