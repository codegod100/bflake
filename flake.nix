{
  description = "A flake overlay for Bun using the binary from the newest release";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
        };
      in {
        packages = {
          inherit (pkgs) bun;
          default = pkgs.bun;
        };
      }
    ) // {
      #https://github.com/oven-sh/bun/releases/download/bun-v1.2.0/bun-linux-x64.zip
      overlays.default = final: prev: {
        bun = prev.stdenv.mkDerivation rec {
          pname = "bun";
          version = "1.2.0"; # Update version and sha256 when new release is available
          src = prev.fetchurl {
            url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-${systemPlatform}.zip";
            sha256 = "0lx4x5fgkzzsb32baw7xiayph5xgy2jm3ds1agda24qb29qfjiq7"; # Get actual hash with nix-prefetch-url
          };

          nativeBuildInputs = [ prev.unzip ];
          sourceRoot = ".";

          installPhase = ''
              ls .
            install -Dm755 ./bun-linux-x64/bun $out/bin/bun
          '';

          # Map Nix system to Bun's platform identifiers
          systemPlatform = {
            "x86_64-linux" = "linux-x64";
            "aarch64-linux" = "linux-aarch64";
            "x86_64-darwin" = "darwin-x64";
            "aarch64-darwin" = "darwin-aarch64";
          }.${prev.stdenv.system} or (throw "Unsupported system: ${prev.stdenv.system}");
        };
      };
    };
}
