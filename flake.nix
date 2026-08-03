{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
  with flake-utils.lib; eachSystem defaultSystems (system:
  let
    pkgs = nixpkgs.legacyPackages.${system};

    # 1200x630 social-share banner generated from the avatar: brand gradient
    # background, circular avatar with a light ring, name, tagline and domain.
    og-image = pkgs.runCommand "og-default.jpg" {
      nativeBuildInputs = [ pkgs.imagemagick ];
    } ''
      bold=${pkgs.dejavu_fonts}/share/fonts/truetype/DejaVuSans-Bold.ttf
      reg=${pkgs.dejavu_fonts}/share/fonts/truetype/DejaVuSans.ttf

      # Brand dark-red gradient background.
      magick -size 1200x630 -define gradient:angle=155 \
        gradient:'#8f1927'-'#520c15' bg.png

      # Crop the avatar to a 300px circle.
      magick ${./static/assets/img/avatar.jpg} \
        -resize 300x300^ -gravity center -extent 300x300 \
        \( +clone -alpha transparent -fill white -draw 'circle 150,150 150,0' \) \
        -compose CopyOpacity -composite av.png

      # Compose avatar + ring + text, export an optimized JPEG to $out.
      magick bg.png \
        \( av.png \) -gravity NorthWest -geometry +110+165 -compose over -composite \
        -fill none -stroke 'rgba(255,255,255,0.55)' -strokewidth 6 -draw 'circle 260,315 260,162' \
        -stroke none \
        -font "$bold" -fill '#ffffff'               -pointsize 76 -gravity NorthWest -annotate +470+225 'Lyndon Sanche' \
        -font "$reg"  -fill 'rgba(255,255,255,0.88)' -pointsize 33 -annotate +472+330 'Senior Software Developer' \
        -font "$reg"  -fill 'rgba(255,255,255,0.72)' -pointsize 30 -annotate +472+378 'BSc. Electrical Engineering' \
        -font "$reg"  -fill 'rgba(255,255,255,0.6)'  -pointsize 27 -annotate +472+430 'lyndeno.ca' \
        -depth 8 -strip -quality 88 jpg:$out
    '';
  in rec {
    packages = {
      inherit og-image;

      website = pkgs.stdenvNoCC.mkDerivation {
        name = "lyndeno.ca";
        src = self;
        buildInputs = [ pkgs.coreutils pkgs.hugo ];
        buildPhase = ''
          # Drop in the generated social-share banner before building.
          cp ${og-image} static/assets/img/og-default.jpg
          hugo
        '';
        installPhase = ''
          cp -r public/ $out/
        '';
      };
      default = packages.website;
    };
    devShells.default = pkgs.mkShell {
      buildInputs = packages.default.buildInputs ++ [ pkgs.imagemagick ];
    };
  });
}
