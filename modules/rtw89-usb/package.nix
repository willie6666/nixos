{ lib, stdenv, fetchFromGitHub, kernel, kernelModuleMakeFlags, kmod }:

stdenv.mkDerivation {
  pname = "rtw89-usb-backport";
  version = "${kernel.version}-unstable-2026-10-05";

  src = fetchFromGitHub {
    owner = "morrownr";
    repo = "rtw89";
    rev = "8bbbacadf6fa73c3a3195aefbd4b2ec2422ae356";
    hash = "sha256-1fzsbIGN8gFmfuQnSfghvNltLodh3Rf/AvNKtFE5Z6k=";
  };

  nativeBuildInputs = kernel.moduleBuildDependencies ++ [ kmod ];
  hardeningDisable = [ "pic" "format" ];
  dontConfigure = true;
  dontStrip = true;
  enableParallelBuilding = true;

  postPatch = ''
    substituteInPlace Makefile --replace-fail \
      '$(shell git --git-dir=$(src)/.git rev-parse HEAD)' \
      '8bbbacadf6fa73c3a3195aefbd4b2ec2422ae356'
  '';

  makeFlags = kernelModuleMakeFlags ++ [
    "-C" "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  buildPhase = ''
    runHook preBuild
    make $makeFlags M="$PWD" -j"$NIX_BUILD_CORES" modules
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    test "$(modinfo -F vermagic rtw89_8852cu_git.ko | cut -d ' ' -f 1)" = '${kernel.modDirVersion}'
    modinfo -F alias rtw89_8852cu_git.ko | grep -q 'v0BDApC832'
    install -Dm644 -t "$out/lib/modules/${kernel.modDirVersion}/updates/rtw89" *.ko
    runHook postInstall
  '';

  meta = {
    description = "rtw89 backport with RTL8832CU/RTL8852CU USB client and AP support";
    homepage = "https://github.com/morrownr/rtw89";
    license = with lib.licenses; [ gpl2Only bsd3 ];
    platforms = lib.platforms.linux;
  };
}
