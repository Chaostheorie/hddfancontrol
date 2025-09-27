{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      rust-overlay,
      flake-utils,
    }:
    (flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ rust-overlay.overlays.default ];
        };
        packages = [
          (pkgs.rust-bin.stable.latest.default.override {
            extensions = [
              "rust-src"
              "rust-analyzer"
            ];
          })

          # testing
          pkgs.cargo-nextest
          pkgs.pkg-config
          pkgs.cargo-flamegraph
          pkgs.mold
          pkgs.llvmPackages.bintools
        ];
        libs = [ ];
      in
      {
        devShells.default = pkgs.mkShell {
          packages = packages ++ libs;
        };
      }
    ));
}
