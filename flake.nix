{
  description = "NixOS Raspberry Pi Kiosk (Chromium + cage)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs = { self, nixpkgs, nixos-hardware }: let
    system = "aarch64-linux";
    pkgs = import nixpkgs { inherit system; };
  in {
    nixosConfigurations.pi-kiosk = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./configuration.nix
        nixos-hardware.nixosModules.raspberry-pi-4
        ({ modulesPath, ... }: {
          imports = [ "${modulesPath}/installer/sd-card/sd-image-aarch64.nix" ];
        })
      ];
    };

    packages.${system}.sd-image = pkgs.runCommand "sd-image" {} ''
      set -eu
      img_dir=${self.nixosConfigurations.pi-kiosk.config.system.build.sdImage}
      mkdir -p "$out"
      img=$(find "$img_dir/sd-image" -maxdepth 1 -type f -name '*.img*' | head -n 1)
      if [ -z "$img" ]; then
        echo "No .img file found in $img_dir/sd-image" >&2
        exit 1
      fi
      cp "$img" "$out/sd-image.img"
    '';

    defaultPackage.${system} = self.packages.${system}.sd-image;
  };
}
