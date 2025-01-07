# My NeoVim Config for Nix

```bash
nix run .
```

Add to flake.nix:

```nix
{
    inputs = {
        ...
        
        nvfconfig = {
          url = "github:mikeslade/nvfconfig";
          inputs.nixpkgs.follows = "nixpkgs";
        };
    }

    outputs = inputs @ {
        nvfconfig,
        ...
    }:{
    ...
    }
}
```

Add to a host configuration.nix like so:

```nix
environment.systemPackages = with pkgs; [
    inputs.nvfconfig.packages.${system}.default
  ];
```
