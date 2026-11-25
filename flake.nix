{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ci.url = "github:Lyndeno/ci";
    ci.inputs.nixpkgs.follows = "nixpkgs";

    blueprint = {
      url = "github:numtide/blueprint";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # GitHub profile photo; refresh with `nix flake update avatar`.
    avatar = {
      url = "file+https://github.com/Lyndeno.png";
      flake = false;
    };
  };

  outputs = inputs:
    inputs.blueprint {
      inherit inputs;
      prefix = "nix/";
      systems = ["x86_64-linux" "aarch64-linux"];
    };
}
