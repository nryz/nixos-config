{ config, options, pkgs, lib, my, ... }:

with lib;
with my.lib;
let
  cfg = config.persist;
  
  state.userDirs = filter (x: !(hasPrefix "/" x)) cfg.state.directories;
  state.userFiles = filter (x: !(hasPrefix "/" x)) cfg.state.files;
  state.dirs = filter (x: hasPrefix "/" x) cfg.state.directories;
  state.files = filter (x: hasPrefix "/" x) cfg.state.files;
in
{

  options.persist = with types; {
    path = mkOpt' str;
    
    users = mkOpt (listOf str) [];
    
    state = {
      directories = mkOpt (listOf str) [];
      files = mkOpt (listOf str) [];
    };
  };
  
  config = mkIf (cfg.path != "") {
    assertions = [{
        assertion = config.fileSystems."/".fsType == "tmpfs"; 
        message = "no root tmpfs found";
    }];

    programs.fuse.userAllowOther = true;

    environment.persistence."${cfg.path}/system" = {
      hideMounts = true;

      directories = [
        "/var/log"
        "/var/lib/systemd/coredump"
        "/var/db/sudo/lectured"
      ] ++ state.dirs;

      files = [
        "/etc/machine-id"
      ] ++ state.files;

    };

    environment.persistence."${cfg.path}" = {
      hideMounts = true;
      users = listToAttrs (map (n: nameValuePair n {
        files = map (f: { file = f; parentDirectory = { user = n; group = "users"; }; }) 
          state.userFiles;

        directories = [
          "Downloads"
          "Media"
          "projects"
          "config"
        ] ++ map (f: { directory = f; user = n; group = "users"; }) 
          state.userDirs;
      }) cfg.users);
    };
  };
}
