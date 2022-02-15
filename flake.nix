{
  description = "Home Manager configuration for user suess";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-store-emacs-packages.url = "github:teu5us/nix-store-emacs-packages";
    nix-store-emacs-packages.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs:
    let
      system = "x86_64-linux";
      username = "suess";
      homeDirectory = "/home/${username}";
    in {
      homeConfigurations.${username} = inputs.home-manager.lib.homeManagerConfiguration {
        inherit system username homeDirectory;
        stateVersion = "21.11";
        extraSpecialArgs = { inherit inputs; };
        configuration = import ./home.nix;
        extraModules = [
          ({ pkgs, config, inputs, ... }: {
            nix.registry.nixpkgs.flake = inputs.nixpkgs;
            home.packages = [ pkgs.nixFlakes ];
            home.sessionVariables = {
              NIX_PATH = "nixpkgs=${pkgs.path}";
            };
            xdg.configFile."nix/nix.conf".text = ''
              experimental-features = nix-command flakes
            '';
            nixpkgs.overlays = [
              inputs.nix-store-emacs-packages.overlay
            ];
          })
        ];
      };
    };
}
