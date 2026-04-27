{
  description = "mizchi nix config (home-manager + nix-darwin, macOS)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nix-darwin, ... }:
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

      # 全 evaluation 経路で共有する overlay。home-manager standalone と
      # nix-darwin (useGlobalPkgs=true) の両方で同じ pkgs を見せる必要があるため
      # ここで一元管理。
      sharedOverlays = [
        (_: prev: {
          # macOS Nix sandbox で direnv 2.37.x の test phase が hang するため doCheck off
          direnv = prev.direnv.overrideAttrs (_: { doCheck = false; });
        })
      ];

      # home-manager 側の user モジュール（standalone と darwin module の両方で再利用）
      homeUser = { pkgs, lib, ... }: {
        imports = [ ./common.nix ];
        home.username = private.username;
        home.homeDirectory = "/Users/${private.username}";
        programs.git.settings.user = {
          name = private.gitName;
          email = private.email;
        };
      };
    in
    {
      # Standalone home-manager（後方互換: `home-manager switch --flake .#macos`）
      homeConfigurations.macos = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "aarch64-darwin";
          overlays = sharedOverlays;
        };
        modules = [ homeUser ];
      };

      # nix-darwin（system 層 + home-manager 統合: `darwin-rebuild switch --flake .#macos`）
      darwinConfigurations.macos = nix-darwin.lib.darwinSystem {
        modules = [
          { nixpkgs.overlays = sharedOverlays; }
          ./darwin.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${private.username} = homeUser;
            home-manager.backupFileExtension = "backup";
          }
        ];
        specialArgs = { inherit private; };
      };
    };
}
