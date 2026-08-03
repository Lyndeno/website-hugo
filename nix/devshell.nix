{pkgs, perSystem, ...}: pkgs.mkShell {
  buildInputs = perSystem.self.website.buildInputs ++ [ pkgs.imagemagick ];
}
