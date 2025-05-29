{ config, lib, pkgs, nix-colors, ... } :
let
  cfg = config.programs.waybar;
  optional = lib.optional;
  palette = config.colorScheme.palette;
  dc = name: hex: "@define-color ${name} #${hex};\n";
  colorStr = lib.strings.concatStrings [
    (dc "darkbg" palette.base00)
    (dc "bg" palette.base01)
    (dc "fg" palette.base04)
    (dc "hoverbg" palette.base02)
    (dc "activefg" palette.base0A)
    (dc "warnbg" palette.base07)
    (dc "warnfg" palette.base08)
  ];
in
{
  programs.waybar = {
    enable = true;
    style = lib.strings.concatStrings [
      colorStr
      (builtins.readFile ./waybarStyle.css)
    ];
    settings = [{
      layer = "top"; # Waybar at top layer
      position = "top"; # waybar position (top|bottom|left|right)
      height = 24; # Waybar height
      modules-left = ["custom/apple" "clock" "hyprland/workspaces"];
      modules-right = ["wireplumber" "backlight" "bluetooth" "network" "battery"];
      "hyprland/workspaces" = {
        sort-by-number = true;
        format = "{icon}";
        on-click = "activate";
        format-icons = {
            "1" = "1";
            "2" = "2";
            "3" = "3";
            "4" = "4";
            "5" = "5";
            "6" = "6";
            "7" = "7";
            "8" = "8";
            "9" = "9";
            "10" = "10";
            focused = "";
        };
      };
      "clock" = {
        # TODO: Dumbass fucking waybar doesn't work
        format = "{:%-I}";
      };
      "backlight" = {
        device = "kbd_backlight";
      };
      "custom/apple" = {
        format = "";
        # on-click = wlogout",
        tooltip = false;
      };
      "wireplumber" = {
        format =  "{icon}   {volume}% {node_name}";
        format-muted = "";
        format-icons = ["" "" ""];
      };
      "network" = {
        format-wifi = "   {essid} ({signalStrength}%)";
        format-ethernet = " {ifname}: {ipaddr}/{cidr}";
        format-linked = " {ifname} (No IP)";
        format-disconnected = "⚠ Disconnected";
        format-alt = "{ifname}: {ipaddr}/{cidr}";
      };
    }];
  };


  # TODO:
  # Make this somehow depend on if uwsm is set in the nixos config

  # The home manager ppl want to attatch waybar to their weird tray systemd target.
  # That ain't gonna fly.
  # We are gonna basically use uwsm's systemd example here: https://github.com/Vladimir-csp/uwsm/blob/master/example-units/waybar.service
  # This way it'll integrate with uwsm good and no need to do weird hacks.
  programs.waybar.systemd.enable = false;
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
