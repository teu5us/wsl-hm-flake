{
  description = "Home Manager configuration for user suess";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-store-emacs-packages.url = "github:teu5us/nix-store-emacs-packages";
    nix-store-emacs-packages.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs:
    let
      system = "x86_64-linux";
      pkgs = inputs.nixpkgs.legacyPackages.${system};
      username = "suess";
      homeDirectory = "/home/${username}";
    in {
      homeConfigurations.${username} = inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit inputs; };
        modules = [

          ({ pkgs, config, inputs, ... }: {
            nix.registry.nixpkgs.flake = inputs.nixpkgs;
            home = {
              inherit username homeDirectory;
              stateVersion = "21.11";
              packages = [  ];
              sessionVariables = {
                NIX_PATH = "nixpkgs=${pkgs.path}";
              };
            };
            xdg.configFile."nix/nix.conf".text = ''
              experimental-features = nix-command flakes
            '';
            nixpkgs.overlays = [
              inputs.nix-store-emacs-packages.overlay
            ];
          })

          ./home.nix

        ];
      };
    };
}
