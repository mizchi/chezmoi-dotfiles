{
  description = "mizchi home-manager configuration (macOS)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      privatePath = ./private.nix;
      private =
        if builtins.pathExists privatePath
        then import privatePath
        else {
          username = "user";
          gitName = "User";
          email = "user@example.com";
        };
    in
    {
      homeConfigurations = {
        macos = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.aarch64-darwin;
          modules = [
            ./common.nix
            {
              home.username = private.username;
              home.homeDirectory = "/Users/${private.username}";
              programs.git.settings.user = {
                name = private.gitName;
                email = private.email;
              };
            }
          ];
        };
      };
    };
}
