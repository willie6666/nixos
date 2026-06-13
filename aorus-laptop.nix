{ lib
, stdenv
, fetchFromGitHub
, kernel
}:

stdenv.mkDerivation rec {
  pname = "aorus-laptop";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "tangalbert919";
    repo = "gigabyte-laptop-wmi";
    rev = version;

    # 第一次 rebuild 會失敗並告訴你正確 hash
    hash = "sha256-+ZRyrI3PJRIEFEcOrKh9Zuhg07o/YMkycspOBPDAaeU=";
  };

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = [
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  buildPhase = ''
    runHook preBuild
    make $makeFlags
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -D aorus-laptop.ko \
      $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/platform/x86/aorus-laptop.ko
    runHook postInstall
  '';

  meta = with lib; {
    description = "Gigabyte AERO/AORUS laptop EC/WMI kernel module";
    homepage = "https://github.com/tangalbert919/gigabyte-laptop-wmi";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
  };
}