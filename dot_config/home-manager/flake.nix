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
              # programs.git の user.name/email は ~/.gitconfig が引き続き提供する。
              # home-manager に寄せたい時は次の行を有効化:
              # programs.git.settings.user = { name = private.username; email = private.email; };
            }
          ];
        };
      };
    };
}
