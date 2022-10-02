{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.blocks.programs.git;
in
{
  options.blocks.programs.git = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    hm.programs.git = {
      enable = true;

      userEmail = "mail@nryz.xyz";
      userName = "nryz";
    };

    hm.home.packages = with pkgs; [
      gitui
    ];
  };
}