# ==================================================================================================
# plugins Development Flake
# ==================================================================================================

{
  description = "Hakula's agent skills, packaged as plugins";

  nixConfig = {
    extra-substituters = [
      "https://hakula.cachix.org"
    ];
    extra-trusted-public-keys = [
      "hakula.cachix.org-1:7zwB3fhMfReHdOjh6DmnaLXgqbPDBcojvN9F+osZw0k="
    ];
  };

  # ------------------------------------------------------------------------------------------------
  # Inputs
  # ------------------------------------------------------------------------------------------------
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    devkit = {
      url = "github:hakula139/devkit/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # ------------------------------------------------------------------------------------------------
  # Outputs
  # ------------------------------------------------------------------------------------------------
  outputs =
    {
      nixpkgs,
      devkit,
      ...
    }:
    devkit.lib.eachSystem devkit.lib.systems (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        dk = devkit.lib.mkLib pkgs;

        preCommit = dk.preCommit {
          src = ./.;
        };
      in
      {
        # ------------------------------------------------------------------------------------------
        # Dev shell
        # ------------------------------------------------------------------------------------------
        devShells.default = pkgs.mkShell {
          name = "plugins-dev";
          inputsFrom = [
            preCommit.shell
          ];
        };

        # ------------------------------------------------------------------------------------------
        # Checks
        # ------------------------------------------------------------------------------------------
        checks.pre-commit = preCommit.check;

        # ------------------------------------------------------------------------------------------
        # Formatter
        # ------------------------------------------------------------------------------------------
        formatter = pkgs.nixfmt-tree;
      }
    );
}
