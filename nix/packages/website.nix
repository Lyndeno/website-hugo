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
      # Drop in the generated social-share banner and favicons before building.
      cp ${perSystem.self.og-image} static/assets/img/og-default.jpg
      cp ${perSystem.self.favicons}/* static/assets/img/favicons/
      hugo
    '';
    installPhase = ''
      cp -r public/ $out/
    '';
  }
