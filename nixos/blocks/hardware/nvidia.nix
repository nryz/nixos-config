{ config, options, pkgs, lib, my, ... }:

with lib;
with my.lib;
let
  cfg = config.blocks.hardware.nvidia;
in
{
  options.blocks.hardware.nvidia = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    services.xserver.videoDrivers = ["nvidia"];
    hardware.opengl.enable = true;
    hardware.nvidia.modesetting.enable = true;
    environment.systemPackages = with pkgs; [
      egl-wayland
    ];
  };
}
