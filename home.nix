{ config, pkgs, inputs, pkgs-unstable, system, ... }:

let
  catppuccinGtk = pkgs.magnetic-catppuccin-gtk.override {
    accent = [ "blue" ];
    shade = "dark";
    size = "standard";
    tweaks = [ ];
  };
in
{
  home.username    = "willie";
  home.homeDirectory = "/home/willie";
  home.stateVersion  = "26.05";

  # ── Home Packages ─────────────────────────────────────────────────────────

  home.packages = with pkgs; [
    inputs.zen-browser.packages.${system}.default

    foot

    kdePackages.filelight

    steamcmd
    heroic

    pkgs-unstable.opencode
    inputs.claude-code.packages.${system}.default

    blender
    blockbench
    pkgs-unstable.godot

    scrcpy
    wireshark
    tcpdump

    pkgs-unstable.rustdesk-flutter

    pkgs-unstable.jetbrains.idea
    prismlauncher

    spotify
    # vesktop
    equibop
    swayidle
    cloudflare-warp
    proton-vpn
    solaar

    pkgs-unstable.android-studio

    inputs.antigravity-nix.packages.${system}.google-antigravity-cli

    dbeaver-bin

    pkgs-unstable.burpsuite

    pkgs-unstable.codex

    qt6Packages.qtstyleplugin-kvantum
    libsForQt5.qtstyleplugin-kvantum
    qt6Packages.qt6ct
    libsForQt5.qt5ct
    catppuccin-kvantum
    catppuccin-cursors.mochaBlue
    catppuccin-papirus-folders
    catppuccinGtk

    aseprite
  ];

  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "blue";
  };

  gtk = {
    enable = true;

    theme = {
      name = "Catppuccin-GTK-Blue-Dark";
      package = catppuccinGtk;
    };

    cursorTheme = {
      name = "catppuccin-mocha-blue-cursors";
      package = pkgs.catppuccin-cursors.mochaBlue;
      size = 24;
    };

    colorScheme = "dark";
  };

  qt = {
    enable = true;
    platformTheme.name = "qtct";

    style = {
      name = "kvantum";
    };
  };

  catppuccin.kvantum = {
    enable = true;
    flavor = "frappe";
    accent = "blue";
    apply = true;
  };

  catppuccin.qt5ct = {
    enable = true;
    flavor = "frappe";
    accent = "blue";
  };

  # ── OBS Studio ────────────────────────────────────────────────────────────

  programs.obs-studio = {
    enable  = true;
    package = pkgs.obs-studio.override { cudaSupport = true; };
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-pipewire-audio-capture
      obs-gstreamer
      obs-vkcapture
    ];
  };

  # ── Swayidle ──────────────────────────────────────────────────────────────

  services.swayidle = {
    enable = true;

    timeouts = [
      {
        timeout = 300;
        command = "${inputs.noctalia.packages.${system}.default}/bin/noctalia-shell ipc call lockScreen lock";
      }
      {
        timeout = 305;
        command = "${pkgs.niri}/bin/niri msg action power-off-monitors";
      }
    ];

    events = {
      before-sleep = "${inputs.noctalia.packages.${system}.default}/bin/noctalia-shell ipc call lockScreen lock";
    };
  };

  # ── MPV ───────────────────────────────────────────────────────────────────

  programs.mpv = {
    enable = true;
    config = {
      profile      = "gpu-hq";
      vo           = "gpu";
      hwdec        = "auto-safe";
      ytdl-format  = "bestvideo+bestaudio";
      keep-open    = true;
    };
    scripts = with pkgs.mpvScripts; [
      mpris
      uosc
      thumbfast
      autosubsync-mpv
    ];
  };

  # ── Direnv ────────────────────────────────────────────────────────────────

  programs.direnv = {
    enable               = true;
    enableBashIntegration = true;
    nix-direnv.enable    = true;
  };

  # ── Steam Desktop Entry（HiDPI 修正）─────────────────────────────────────

  xdg.desktopEntries.steam = {
    name    = "Steam";
    comment = "Application for managing and playing games on Steam";
    exec    = "env GDK_SCALE=2 GDK_DPI_SCALE=0.625 steam %U";
    icon    = "steam";
    terminal = false;
    type    = "Application";
    categories = [ "Network" "FileTransfer" "Game" ];
    mimeType   = [ "x-scheme-handler/steam" "x-scheme-handler/steamlink" ];
    settings.Keywords = "Games";
  };

  programs.home-manager.enable = true;
}
