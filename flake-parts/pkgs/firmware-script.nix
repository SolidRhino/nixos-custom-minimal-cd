{ pkgs }:

pkgs.stdenvNoCC.mkDerivation {
  pname = "get-apple-firmware";
  version = "360156db52c013dbdac0ef9d6e2cebbca46b955b";

  src = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/t2linux/wiki/360156db52c013dbdac0ef9d6e2cebbca46b955b/docs/tools/firmware.sh";
    hash = "sha256-IL7omNdXROG402N2K9JfweretTnQujY67wKKC8JgxBo=";
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/get-apple-firmware
    chmod +x $out/bin/get-apple-firmware
  '';

  meta = with pkgs.lib; {
    description = "Firmware extraction tool for T2 Linux devices";
    longDescription = ''
      Comprehensive script that extracts WiFi and Bluetooth firmware from macOS
      for use on T2 Macs running Linux. Supports multiple extraction methods:
      EFI partition, macOS volume, and recovery image downloads.

      Uses embedded Python to parse and rename firmware files for Linux compatibility.
    '';
    homepage = "https://wiki.t2linux.org/guides/wifi/";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
