{ config, pkgs, lib, ... }:
{
  # Enhanced bash configuration
  programs.bash = {
    enableCompletion = true;

    shellAliases = {
      # Modern replacements
      ll = "eza -alh --group-directories-first";
      la = "eza -A";
      ls = "eza";
      cat = "bat --style=plain";

      # Git shortcuts
      gs = "git status";
      gd = "git diff";
      gl = "git log --oneline -10";
      ga = "git add";
      gc = "git commit";

      # Network helpers
      myip = "ip -br addr show";
      ports = "ss -tuln";
      netinfo = "ip addr show && echo && ip route show";

      # Disk helpers
      df = "df -h";
      du = "du -h";
      diskinfo = "lsblk -f";

      # Nix shortcuts
      nxs = "nix search nixpkgs";
      nxr = "nix run nixpkgs#";
      nxd = "nix develop";
      nxb = "nix build";

      # Installation helpers
      partitions = "lsblk -f";
      mounts = "findmnt";
    };

    # Helpful prompt showing current directory
    promptInit = ''
      PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
    '';
  };
}
