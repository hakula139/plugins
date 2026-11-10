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
      url = "github:hakula139/devkit/v3";
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
    let
      inherit (nixpkgs) lib;

      isDirectory = _: type: type == "directory";
      directories = path: lib.attrNames (lib.filterAttrs isDirectory (builtins.readDir path));
      plugins = directories ./plugins;

      pluginSkills =
        plugin:
        let
          root = ./plugins + "/${plugin}/skills";
        in
        lib.genAttrs (directories root) (name: devkit.lib.skillSource (root + "/${name}"));
    in
    # ----------------------------------------------------------------------------------------------
    # Library
    # ----------------------------------------------------------------------------------------------
    {
      lib.skills = lib.foldl' lib.attrsets.unionOfDisjoint { } (map pluginSkills plugins);
    }
    // devkit.lib.eachSystem devkit.lib.systems (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        dk = devkit.lib.mkLib pkgs;

        preCommit = dk.preCommit {
          src = ./.;
          hooks = {
            doctoc.enable = true;
            nu-check.enable = true;
            prettier.enable = true;
            shellcheck.enable = true;
            shfmt.enable = true;
          };
        };
      in
      {
        # ------------------------------------------------------------------------------------------
        # Dev shell
        # ------------------------------------------------------------------------------------------
        devShells.default = pkgs.mkShell {
          name = "plugins-dev";
          packages = [
            dk.nushell
          ];
          inputsFrom = [
            preCommit
          ];
        };

        # ------------------------------------------------------------------------------------------
        # Checks
        # ------------------------------------------------------------------------------------------
        checks = {
          skills =
            let
              source = lib.fileset.toSource {
                root = ./.;
                fileset = lib.fileset.unions [
                  ./.claude-plugin
                  ./plugins
                ];
              };
            in
            pkgs.runCommand "plugins-skills" { } ''
              ${lib.getExe dk.nushell} --no-config-file ${./nix/check-skills.nu} ${source}
              touch "$out"
            '';
        };

        # ------------------------------------------------------------------------------------------
        # Formatter
        # ------------------------------------------------------------------------------------------
        formatter = pkgs.nixfmt-tree;
      }
    );
}
