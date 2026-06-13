{ config, pkgs, lib, ... }:

let
  aorus-laptop = config.boot.kernelPackages.callPackage ../aorus-laptop.nix {};
in
{
  # ── Bootloader ────────────────────────────────────────────────────────────

  boot.loader.systemd-boot.enable    = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  boot.kernelParams         = [ "nvidia-drm.modeset=1" ];
  
  boot.extraModulePackages = [ aorus-laptop ];
  boot.kernelModules = [ "aorus-laptop" "coretemp" ];

  # ── Hardware ──────────────────────────────────────────────────────────────

  hardware.graphics.enable   = true;
  hardware.bluetooth.enable  = true;
  hardware.nvidia-container-toolkit.enable = true;

  # ── NVIDIA（PRIME Offload）────────────────────────────────────────────────

  services.xserver.videoDrivers = [ "modesetting" "nvidia" ];

  hardware.nvidia = {
    modesetting.enable              = true;
    powerManagement.enable          = true;
    powerManagement.finegrained     = true;
    dynamicBoost.enable             = true;
    open                            = true;
    nvidiaSettings                  = true;
    package                         = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      offload = {
        enable          = true;
        enableOffloadCmd = true;
      };
      intelBusId  = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # ── Audio（Pipewire）─────────────────────────────────────────────────────

  services.pulseaudio.enable = false;
  security.rtkit.enable      = true;

  services.pipewire = {
    enable           = true;
    alsa.enable      = true;
    alsa.support32Bit = true;
    pulse.enable     = true;
  };
}
