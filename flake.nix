{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    pre-commit-hooks-nix = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ci.url = "github:Lyndeno/ci";
    ci.inputs.nixpkgs.follows = "nixpkgs";

    blueprint = {
      url = "github:numtide/blueprint";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "";
    };
  };

  outputs = inputs: inputs.blueprint {
    inherit inputs;
    prefix = "nix/";
    systems = ["x86_64-linux" "aarch64-linux"];
  };
}
