{ config, pkgs, ... }:

{

  networking.firewall = {
    enable = true;

    checkReversePath = false;

    trustedInterfaces = [ "virbr0" ];
    
    allowedTCPPorts = [ ];
    allowedUDPPorts = [ ];
  };
}