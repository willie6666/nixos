{ config, lib, ... }:
let
  cfg = config.hardware.intelWifiLarDisable;
in {
  options.hardware.intelWifiLarDisable.enable = lib.mkEnableOption
    "the experimental iwlmvm LAR opt-out using Taiwan's regulatory database";

  config = lib.mkIf cfg.enable {
    boot.extraModulePackages = [
      (config.boot.kernelPackages.callPackage ./package.nix { })
    ];
    hardware.wirelessRegulatoryDatabase = true;
    boot.extraModprobeConfig = ''
      options iwlmvm lar_disable=1
      options cfg80211 ieee80211_regdom=TW
    '';
    # Do not change NetworkManager ownership or enable a competing AP service.
    # Reboot to load this module; switching the system does not replace a loaded .ko.
  };
}
