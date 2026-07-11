{ config, pkgs, ... }:

{
  # Networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Power Management
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;

  # Disk & File Systems
  services.udisks2.enable = true;
  services.gvfs.enable = true;

  # Printing
  services.printing.enable = true;
  
  # MIME support
  xdg.mime.enable = true;

  hardware.logitech.wireless.enable = true;

  services.gnome.gnome-keyring.enable = true;
  services.cloudflare-warp.enable = true;

  services.sunshine = {
    enable = true;
    autoStart = true;   # 登入圖形介面時自動啟動 (Systemd user service)
    capSysAdmin = true; # Wayland 環境必備！允許免 root 進行 KMS 畫面擷取
    openFirewall = true; # 自動放行 Moonlight 所需的所有 TCP/UDP 連接埠
  };

  services.avahi = {
    enable = true;
    publish = {
      enable = true;
      userServices = true;
    };
  };
}