{
  pkgs,
  inputs,
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
      # Drop in the avatar, generated social-share banner and favicons before building.
      cp ${inputs.avatar} static/assets/img/avatar.jpg
      cp ${perSystem.self.og-image} static/assets/img/og-default.jpg
      cp ${perSystem.self.favicons}/* static/assets/img/favicons/
      hugo
    '';
    installPhase = ''
      cp -r public/ $out/
    '';
  }
