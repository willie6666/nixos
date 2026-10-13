{ config, lib, pkgs, ... }:

let
  # RTL8832CU/RTL8852CU USB support first appears in the native 6.19 driver.
  needsBackport = lib.versionOlder config.boot.kernelPackages.kernel.version "6.19";
  driver = config.boot.kernelPackages.callPackage ./package.nix { };
in
{
  # The dongle starts as 0bda:1a2b (driver disk), then becomes 0bda:c832.
  hardware.usb-modeswitch.enable = true;
  hardware.enableRedistributableFirmware = lib.mkDefault true;

  boot.extraModulePackages = lib.optionals needsBackport [ driver ];
  boot.kernelModules = [ (if needsBackport then "rtw89_8852cu_git" else "rtw89_8852cu") ];

  # Backport and stock rtw89 export the same symbols: use one complete family.
  # These are the stock module names listed in the upstream rtw89.conf.
  boot.blacklistedKernelModules = lib.optionals needsBackport [
    "rtw89_8851bu" "rtw89_8851be" "rtw89_8851b"
    "rtw89_8852au" "rtw89_8852ae" "rtw89_8852a"
    "rtw89_8852b_common" "rtw89_8852bu" "rtw89_8852be" "rtw89_8852b"
    "rtw89_8852bte" "rtw89_8852bt"
    "rtw89_8852cu" "rtw89_8852ce" "rtw89_8852c"
    "rtw89_8922au" "rtw89_8922ae" "rtw89_8922a"
    "rtw89_8922de" "rtw89_8922d"
    "rtw89_core" "rtw89_usb" "rtw89_pci"
  ];

  boot.extraModprobeConfig = lib.optionalString needsBackport ''
    options rtw89_usb_git switch_usb_mode=y
  '';
}
