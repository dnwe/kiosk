{ config, lib, pkgs, ... }:

{
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  users.users.kiosk = {
    isNormalUser = true;
    createHome = true;
  };

  services.cage = {
    enable = true;
    user = "kiosk";
    program = "${pkgs.chromium}/bin/chromium --incognito --app=https://www.bbc.co.uk/news --kiosk --disable-features=Translate --enable-features=UseOzonePlatform --ozone-platform=wayland";
    environment = {
      # Disables all local input devices (keyboard, mouse, touch)
      WLR_LIBINPUT_NO_DEVICES = "1";
    };
  };

  systemd.services."cage-tty1" = {
    after = [ "network-online.target" "systemd-resolved.service" ];
    wants = [ "network-online.target" ];
  };

  nix.channel.enable = false;
  nix.settings.experimental-features = "nix-command flakes";

  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = false;
    };
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIdummyDummyKEYexampleONLYdontUSErealKEYS kiosk@example"
  ];

  time.timeZone = "UTC";

  networking.useDHCP = lib.mkDefault true;

  disko.devices.disk1 = {
    device = lib.mkDefault "/dev/mmcblk0";
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          type = "EF00";
          size = "500M";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };

  system.stateVersion = "24.11";
}
