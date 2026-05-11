{
  description = "Manas' deterministic macOS and dotfiles setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, ... }:
    let
      system = "aarch64-darwin";
      mkDarwin = { username, profile ? "personal" }:
        let
          specialArgs = { inherit inputs username profile; };
        in
        nix-darwin.lib.darwinSystem {
          inherit system specialArgs;
          modules = [
            ./nix/darwin.nix
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "hm-backup";
              home-manager.extraSpecialArgs = specialArgs;
              home-manager.users.${username} = import ./nix/home.nix;
            }
          ];
        };
    in
    {
      darwinConfigurations = {
        personal = mkDarwin {
          username = "manas";
          profile = "personal";
        };

        work = mkDarwin {
          username = "manas";
          profile = "work";
        };

        "manas-personal" = mkDarwin {
          username = "manas";
          profile = "personal";
        };

        "manas-work" = mkDarwin {
          username = "manas";
          profile = "work";
        };
      };
    };
}
