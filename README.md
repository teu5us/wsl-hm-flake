# Installation

## Install Nix

To install Nix under WSL2, follow the instructions [here](https://nixos.org/download.html#nix-install-windows). Note, that you may need to install curl first.

## Build this flake

1. Clone the repository (you want to modify stuff, right?) somewhere.

2. Change the username on the line 15 of `flake.nix`.

3. Run the following command:

   ```nix
   nix build --extra-experimental-features "nix-command flakes"  <path-to-cloned-repo>#homeConfigurations.<your-username>.activationPackage
   ```

4. Activate the environment.

   I want my nix to also be managed by home-manager configuration, so it is included in `home.packages`. Thus, you may see a warning that it conflicts with the installed version. Run `nix-env --set-flag priority 10 nix` to lower the installed version's priority and let the activation script work. Then run:

   ```nix
   ./result/activate
   ```

5. Remove the nixpkgs channel so it does not mess with the nixpkgs flake being used.

   ```nix
   nix-channel --remove nixpkgs
   ```

   This will disallow installing packages using `nix-env`, but still let home-manager work. DO NOT install packages using `nix profile install` or it will break home-manager profile activation. If this has happened to you, find your nix in the store and add it to `PATH`. Then remove `/nix/var/nix/profiles/per-user/<your-username>/profile` and rerun steps 2 and 3.

   `NIX_PATH` is set in the flake to keep nix-shell and other commands working.

   The flake also creates `~/.config/nix/nix.conf` containing `experimental-features = nix-command flakes`.
