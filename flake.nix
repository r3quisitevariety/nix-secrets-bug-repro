{
  description = "nix-secrets manifest error repro flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nix-secrets.url = "github:unnamed-systems/nix-secrets/dev";
  };

  outputs = {
    nixpkgs,
    nix-secrets,
    ...
  }: {
    packages.x86_64-linux.nix-secrets = nix-secrets.packages.x86_64-linux.nix-secrets;

    devShells.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
      packages = [nix-secrets.packages.x86_64-linux.nix-secrets];
    };

    nixosConfigurations.repro = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        nix-secrets.nixosModules.default
        {
          security.nix-secrets = {
            enable = true;
            storage = ./secrets;
            identityPaths = ["./age/keys.txt"];
            recipientAliases = {
              master = "age1lyxkz3ngzaljtvdx8ah63p23ueqhzrew0x9az4uljvcfzdr7hf0sca3xj7";
            };
            secrets = {
              chungus-secret = {
                recipients = ["master"];
                owner = "repro";
                group = "users";
                mode = "0600";
              };
            };
          };
          system.stateVersion = "25.11";
          boot.isContainer = true;
        }
      ];
    };
  };
}
