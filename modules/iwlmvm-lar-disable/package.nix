{ lib, stdenv, kernel, kernelModuleMakeFlags, kmod }:

stdenv.mkDerivation {
  pname = "iwlmvm-lar-disable";
  version = "${kernel.version}-21be8d8";
  src = kernel.src;
  patches = (kernel.patches or []) ++ [ ./lar_disable.patch ];

  nativeBuildInputs = kernel.moduleBuildDependencies ++ [ kmod ];
  hardeningDisable = [ "pic" "format" ];
  enableParallelBuilding = true;
  dontConfigure = true;
  # Keep module metadata and symbol version sections unchanged after validation.
  dontStrip = true;

  makeFlags = kernelModuleMakeFlags ++ [
    "-C" "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];
  buildPhase = ''
    runHook preBuild
    make $makeFlags M="$PWD/drivers/net/wireless/intel/iwlwifi" \
      -j"$NIX_BUILD_CORES" modules
    runHook postBuild
  '';
  installPhase = ''
    runHook preInstall
    module=drivers/net/wireless/intel/iwlwifi/mvm/iwlmvm.ko
    modinfo -p "$module" | grep '^lar_disable:'
    test "$(modinfo -F vermagic "$module" | cut -d ' ' -f 1)" = '${kernel.modDirVersion}'
    # depmod's updates/ directory takes precedence over the stock kernel/ copy.
    install -Dm644 "$module" "$out/lib/modules/${kernel.modDirVersion}/updates/iwlmvm.ko"
    runHook postInstall
  '';

  meta = {
    description = "Experimental iwlmvm LAR opt-out, built for the selected NixOS kernel";
    homepage = "https://github.com/lakinduakash/linux-wifi-hotspot";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
  };
}
