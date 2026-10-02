{ config, pkgs, lib, ... }:

{
  # Display Manager & Desktop
  services.xserver.enable = true;
  services.xserver.xkb.layout = "us";

  services.displayManager.noctalia-greeter = {
    enable = true;

    settings = {
      cursor = {
        theme = "Bibata-Modern-Ice";
        size = 24;
        path = "${pkgs.bibata-cursors}/share/icons";
      };
    };
  };

  services.flatpak.enable = true;

  programs.niri.enable = true;
  programs.dconf.enable = true;

  # ── Qt / Kvantum ─────────────────────────────────────────────────────────
  #
  # 讓 system-level Qt apps（包含 polkit-kde-agent）也能找到
  # qt5ct / qt6ct 以及 Kvantum plugins。
  #
  # Home Manager 仍然負責 Catppuccin 的實際 theme config。

  qt = {
    enable = true;
    platformTheme = "qt5ct";
    style = "kvantum";
  };

  # ── XDG Portals ──────────────────────────────────────────────────────────

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

  # Fix for Dolphin Menu
  environment.etc."xdg/menus/applications.menu".source =
    "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";

  # ── Fonts ────────────────────────────────────────────────────────────────

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

      emoji = [
        "Noto Color Emoji"
      ];
    };
  };

  # ── Security / Polkit ────────────────────────────────────────────────────

  security.polkit.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
}