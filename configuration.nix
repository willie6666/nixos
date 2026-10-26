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
    ./modules/iwlmvm-lar-disable
    ./modules/rtw89-usb
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

  nixpkgs.overlays = [
    (final: prev: {
      solaar = prev.solaar.overrideAttrs (old: {
        disabledTestPaths = (old.disabledTestPaths or []) ++ [
          "tests/logitech_receiver/test_desktop_notifications.py::test_show"
          "tests/solaar/ui/test_desktop_notifications.py::test_show"
        ];
      });
    })
  ];

  system.stateVersion = "25.11";
}
