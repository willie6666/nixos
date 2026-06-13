{ config, pkgs, ... }:

{
  # Time & Locale
  time.timeZone = "Asia/Taipei";
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "zh_TW.UTF-8";
    LC_IDENTIFICATION = "zh_TW.UTF-8";
    LC_MEASUREMENT = "zh_TW.UTF-8";
    LC_MONETARY = "zh_TW.UTF-8";
    LC_NAME = "zh_TW.UTF-8";
    LC_NUMERIC = "zh_TW.UTF-8";
    LC_PAPER = "zh_TW.UTF-8";
    LC_TELEPHONE = "zh_TW.UTF-8";
    LC_TIME = "zh_TW.UTF-8";
  };

  # User Account
  users.users.willie = {
    isNormalUser = true;
    description = "willie";
    extraGroups = [ "networkmanager" "wheel" "docker" "libvirtd" "ydotool" "wireshark" ];
    shell = pkgs.fish;
    packages = with pkgs; [];
  };

  environment.shells = with pkgs; [ fish ];
}