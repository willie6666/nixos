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
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };

  systemd.user.services.sunshine.environment = {
    LIBVA_DRIVER_NAME = "iHD";
  };

  services.avahi = {
    enable = true;
    publish = {
      enable = true;
      userServices = true;
    };
  };

  services.udev.extraRules = ''
    KERNEL=="uinput", MODE="0660", GROUP="input", SYMLINK+="uinput"
  '';
}