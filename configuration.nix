{ config, pkgs, inputs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/hardware.nix
    ./modules/desktop.nix
    ./modules/packages.nix
    ./modules/services.nix
    ./modules/users.nix
    ./modules/firewall.nix
    ./cachix.nix
  ];

  nix.gc = {
    automatic = true;
    dates = "weekly";

    options = "--delete-older-than 7d";
  };

  nix.settings = {
    substituters = [
      "https://cache.nixos-cuda.org"
    ];
    trusted-public-keys = [
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
    ];
    auto-optimise-store = true;
    experimental-features = [ "nix-command" "flakes" ];
  };
  nixpkgs.config.allowUnfree = true;
  # nixpkgs.config.cudaSupport = true;
  # nixpkgs.config.cudaVersion = "12";

  system.stateVersion = "25.11";
}