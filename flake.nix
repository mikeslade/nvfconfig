{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf.url = "github:notashelf/nvf";
  };

  outputs = inputs @ {
    self,
    flake-parts,
    nixpkgs,
    treefmt-nix,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.treefmt-nix.flakeModule
      ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: let
        neovimConfigured = inputs.nvf.lib.neovimConfiguration {
          inherit (nixpkgs.legacyPackages.${system}) pkgs;
          modules = [
            {
              config.vim = {
                # Enable custom theming options
                theme.enable = true;

                lsp.enable = true;

                languages = {
                  enableTreesitter = true;
                  bash.enable = true;
                  html.enable = true;
                  markdown.enable = true;
                  nix.enable = true;
                  # nu.enable = true;
                  rust.enable = true;
                  sql.enable = true;
                  tailwind.enable = true;
                  ts.enable = true;
                };

                # lazy.plugins = {
                #   direnv.nvim = {
                #   # ^^^^^^^^^ this name should match the package.pname or package.name
                #     package = direnv-nvim;

                #     setupModule = "direnv";
                #     setupOpts = {option_name = false;};

                #     after = "print('direnv loaded')";
                #   };
                # };

                autocomplete.nvim-cmp.enable = true;
                statusline.lualine.enable = true;
                telescope.enable = true;
              };
            }
          ];
        };
      in {
        # checks = {
        #   # Run `nix flake check .` to verify that your config is not broken
        #   default = nvfLib.check.mkTestDerivationFromNixvimModule nixvimModule;
        # };

        packages = {
          # Lets you run `nix run .` to start nixvim
          default = neovimConfigured.neovim;
        };

        # Add your auto-formatters here.
        # cf. https://numtide.github.io/treefmt/
        treefmt.config = {
          projectRootFile = "flake.nix";
          programs = {
            alejandra.enable = true;
            just.enable = true;
            # jsonfmt.enable = true;
            mdformat.enable = true;
            # prettier.enable = true;
            # rustfmt.enable = true;
            shfmt.enable = true;
            # stylua.enable = true;
            # yamlfmt.enable = true;
          };
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = [
            config.treefmt.build.devShell
          ];
          nativeBuildInputs = with pkgs; [
            alejandra
            just
            statix
            nix-tree

            # so the shell doesn't get messed up
            bashInteractive
            bash-completion
          ];
        };
      };
    };
}
