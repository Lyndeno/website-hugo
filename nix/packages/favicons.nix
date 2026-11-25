# Favicon set generated from the avatar, at the sizes referenced by head.html,
# manifest.json and browserconfig.xml, plus a multi-resolution favicon.ico.
{pkgs, ...}:
pkgs.runCommand "favicons" {
  nativeBuildInputs = [pkgs.imagemagick];
} ''
  mkdir -p $out
  src=${../../static/assets/img/avatar.jpg}

  icon() {
    magick "$src" -resize "$1x$1^" -gravity center -extent "$1x$1" -strip "$out/$2"
  }

  for s in 36 48 72 96 144 192; do icon $s android-icon-''${s}x$s.png; done
  for s in 57 60 72 76 114 120 144 152 180; do icon $s apple-icon-''${s}x$s.png; done
  for s in 16 32 96; do icon $s favicon-''${s}x$s.png; done
  for s in 70 144 150 310; do icon $s ms-icon-''${s}x$s.png; done
  icon 192 apple-icon.png
  icon 192 apple-icon-precomposed.png

  magick "$src" -define icon:auto-resize=48,32,16 -strip $out/favicon.ico
''
