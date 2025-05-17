{ pkgs, specialArgs, ... }:
let
  hyprland = specialArgs.inputs.hyprland;
in
{
  wayland.windowManager.hyprland.enable = true;

  # Use the nixos module
  wayland.windowManager.hyprland.package = null;
  # And let uwsm manage it
  wayland.windowManager.hyprland.systemd.enable = false;

  # Also use the portal package from the flake
  wayland.windowManager.hyprland.portalPackage = hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;

  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";
    bind = [
      "$mod, F, exec, firefox"
      "$mod, Q, exec, ghostty"
      "$mod, M, exit"
    ] ++ 
    (
      builtins.concatLists (builtins.genList (i:
        let ws = (i + 1);
            key = if (ws==10) then 0 else ws;
        in [
          "$mod, ${toString key}, workspace, ${toString ws}"
          "$mod SHIFT, ${toString key}, movetoworkspace, ${toString ws}"
        ]
      ) 10)
    );
  };
  
  # Make xdg use hyprland backend. Dumb ass setting bro.
  xdg.portal.config.hyprland.default = "hyprland";
}
