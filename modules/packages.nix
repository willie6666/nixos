{ config, pkgs, inputs, system, ... }:

{
  # ── Programs ──────────────────────────────────────────────────────────────

  programs.fish.enable = true;
  programs.nix-ld.enable = true;

  programs.steam = {
    enable = true;
    # remotePlay.openFirewall = true;      # Steam Remote Play
    # dedicatedServer.openFirewall = true; # Source Dedicated Server
  };

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  programs.noisetorch.enable = true;
  programs.gamescope.enable  = true;
  programs.gamemode.enable   = true;

  programs.virt-manager.enable = true;
  programs.ydotool.enable      = true;
  programs.wireshark.enable    = true;

  # ── Virtualisation ────────────────────────────────────────────────────────

  virtualisation.libvirtd = {
    enable = true;
    qemu.vhostUserPackages = with pkgs; [ virtiofsd ];
  };

  virtualisation.vmware.host.enable = true;
  virtualisation.docker.enable      = true;
  virtualisation.waydroid.enable    = true;

  # ── nix-ld Libraries ──────────────────────────────────────────────────────

  programs.nix-ld.libraries = with pkgs; [
    # 核心系統與基礎函式庫
    stdenv.cc.cc.lib
    glibc
    glib
    zlib
    zstd
    libz
    openssl
    curl
    libxml2
    util-linux
    icu
    dbus
    systemd

    # 圖形、字體與多媒體
    libGL
    libxkbcommon
    fontconfig
    freetype
    ffmpeg_7-full
    alsa-lib

    # 瀏覽器與底層網路渲染安全依賴
    nss
    nspr

    # 視窗系統：Wayland
    wayland

    # 視窗系統：X11 與 XCB 家族（含 Qt/PySide6 所需依賴）
    libxcb
    libx11
    libxcursor
    libxrandr
    libxext
    libxi
    libxrender
    libxcomposite
    libxdamage
    libxfixes
    libxcb-util
    libxcb-cursor
    libxcb-wm
    libxcb-image
    libxcb-keysyms
    libxcb-render-util
  ];

  # ── System Packages ───────────────────────────────────────────────────────

  environment.systemPackages = with pkgs; [
    # 核心工具
    wget
    git
    vim
    fastfetch
    file
    pciutils
    usbutils
    lzip
    pigz

    # 開發工具
    gcc
    go
    gh
    docker-buildx
    android-tools
    rkdeveloptool

    # 網路工具
    dig
    wireguard-tools
    dnsmasq
    rclone

    # 桌面工具
    vscode
    wl-clipboard
    cliphist
    xwayland-satellite
    libnotify
    tlrc

    # KDE / Qt 元件
    kdePackages.dolphin
    kdePackages.qtsvg
    kdePackages.kio
    kdePackages.kio-fuse
    kdePackages.kio-extras
    kdePackages.kservice
    kdePackages.qt6ct
    kdePackages.qt5compat
    kdePackages.qtdeclarative
    kdePackages.qtwayland
    kdePackages.qqc2-desktop-style
    kdePackages.kirigami
    kdePackages.kquickcharts
    kdePackages.ksystemstats
    kdePackages.libksysguard
    kdePackages.plasma-systemmonitor
    kdePackages.gwenview
    kdePackages.ark

    # 主題
    kdePackages.breeze-gtk
    gnome-themes-extra
    glib
    gsettings-desktop-schemas
    (catppuccin-gtk.override { accents = [ "blue" ]; variant = "mocha"; })
    (catppuccin-sddm.override {
      flavor = "mocha";
      accent = "blue";
      font   = "Noto Sans";
      fontSize = "12";
      # background = "${./wallpaper.png}";
      loginBackground = true;
    })

    # 認證
    polkit_gnome

    # Flake Inputs
    inputs.quickshell.packages.${system}.default
    inputs.noctalia.packages.${system}.default

    # 音影與媒體
    ffmpeg-full
    crosspipe

    # CUDA
    cudatoolkit
    cudaPackages.cuda_cudart
    cudaPackages.cudnn
    nvtopPackages.full

    # 系統監控
    mission-center

    # 雜項
    shared-mime-info
    xdg-utils

    comma

    nix-index

    rclone

    jq
    wl-mirror

    # inputs.globalprotect-openconnect.packages.${system}.default

    v4l-utils


    frida-tools

    ccache
    tesseract

    lm_sensors
  ];

  # ── 輸入法 ────────────────────────────────────────────────────────────────

  i18n.inputMethod = {
    enable = true;
    type   = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-gtk
      fcitx5-mcbopomofo
    ];
  };
}
