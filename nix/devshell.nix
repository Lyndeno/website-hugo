{
  pkgs,
  perSystem,
  flake,
  system,
  ...
}:
pkgs.mkShell {
  buildInputs = perSystem.self.website.buildInputs ++ [pkgs.imagemagick pkgs.statix pkgs.deadnix];
  inherit (flake.checks.${system}.git-hooks) shellHook;
}
