{ pkgs }:
pkgs.rustPlatform.buildRustPackage {
  pname = "shellv2";
  version = "0.1.0";
  src = ./.;
  cargoLock.lockFile = ./Cargo.lock;
  nativeBuildInputs = [ pkgs.pkg-config ];
  buildInputs = [ pkgs.dbus ];
}