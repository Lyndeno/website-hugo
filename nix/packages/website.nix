{
  pkgs,
  flake,
  perSystem,
  ...
}: let
  inherit (pkgs) lib;
in
  pkgs.stdenvNoCC.mkDerivation {
    name = "lyndeno.ca";
    src = lib.cleanSource flake;
    buildInputs = [pkgs.coreutils pkgs.hugo];
    buildPhase = ''
      # Drop in the generated social-share banner before building.
      cp ${perSystem.self.og-image} static/assets/img/og-default.jpg
      hugo
    '';
    installPhase = ''
      cp -r public/ $out/
    '';
  }
