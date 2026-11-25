{
  pkgs,
  inputs,
  perSystem,
  flake,
  system,
  ...
}:
pkgs.mkShell {
  buildInputs = perSystem.self.website.buildInputs ++ [pkgs.imagemagick pkgs.statix pkgs.deadnix];
  shellHook =
    flake.checks.${system}.git-hooks.shellHook
    + ''
      # Copy the untracked generated images into static/ for `hugo server`.
      img="$(git rev-parse --show-toplevel)/static/assets/img"
      cp --no-preserve=mode -f ${inputs.avatar} "$img/avatar.jpg"
      cp --no-preserve=mode -f ${perSystem.self.og-image} "$img/og-default.jpg"
      cp --no-preserve=mode -f ${perSystem.self.favicons}/* "$img/favicons/"
    '';
}
