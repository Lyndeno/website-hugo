{
  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-unstable;
    flake-utils.url = github:numtide/flake-utils;
  };

  outputs = { self, nixpkgs, flake-utils }:
  with flake-utils.lib; eachSystem defaultSystems (system:
  let
    pkgs = nixpkgs.legacyPackages.${system};
  in rec {
    packages = {
      website = pkgs.stdenvNoCC.mkDerivation rec {
        name = "lyndeno.ca";
        src = self;
        buildInputs = [ pkgs.coreutils pkgs.hugo ];
        buildPhase = ''
          hugo
        '';
        installPhase = ''
          cp -r public/ $out/
        '';
      };
      default = packages.website;
    };
  });
}