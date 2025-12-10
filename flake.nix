{
  description = "NixOS Raspberry Pi Kiosk (Chromium + cage)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs = { self, nixpkgs, nixos-hardware }: {
    nixosConfigurations.pi-kiosk = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        ./configuration.nix
        nixos-hardware.nixosModules.raspberry-pi-4
        ({ modulesPath, ... }: {
          imports = [ "${modulesPath}/installer/sd-card/sd-image-aarch64.nix" ];
        })
      ];
    };
  };
}
