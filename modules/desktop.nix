{ config, pkgs, lib, ... }:

{
  # Display Manager & Desktop
  services.xserver.enable = true;
  services.xserver.xkb.layout = "us";
  
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "catppuccin-mocha-blue";
  };

  services.flatpak.enable = true;

  programs.niri.enable = true;
  programs.dconf.enable = true;

  # XDG Portals
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      kdePackages.xdg-desktop-portal-kde
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
    config.niri = {
      default = [ "gnome" "gtk" ];
      "org.freedesktop.impl.portal.FileChooser" = [ "kde" ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
    };
  };

  # Theming & Variables
  qt.enable = true;
  
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    QT_QPA_PLATFORM = "wayland;xcb";
    # QT_STYLE_OVERRIDE = "kvantum";
    QT_QPA_PLATFORMTHEME = "qt6ct";
    GTK_USE_PORTAL = "1";
    XCURSOR_THEME = "catppuccin-mocha-blue-cursors";
    XCURSOR_SIZE = "24";

    WGPU_BACKEND = "vulkan";
  };

  # Fix for Dolphin Menu
  environment.etc."xdg/menus/applications.menu".source = "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";

  # Fonts
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = [
        "Noto Sans CJK TC"
      ];

      serif = [
        "Noto Serif CJK TC"
      ];

      monospace = [
        "Noto Sans Mono CJK TC"
      ];
      
      emoji = [ "Noto Color Emoji" ];
    };
  };

  # Security & Polkit Agent Service
  security.polkit.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;
  
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
    };
  };
}