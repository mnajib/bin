{ config, pkgs, ... }:
#{ pkgs, ... }:

with import <nixpkgs> {};
with builtins;
with lib;
with import <home-manager/modules/lib/dag.nix> { inherit lib; };

# XXX:
#with import Network.HostName;

{
  nixpkgs.config = {
    allowUnfree = true;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager = {
    enable = true;
    path = "...";
  };

  # INFO: Moved to seperate file
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  #home.username = "najib"; #"najib";#"$USER";
  #home.homeDirectory = "/home/najib"; #"/home/najib";#"$HOME";
  #hostname = getHostName;

  home.packages = [
    pkgs.htop
    pkgs.atop

    pkgs.gnome.gnome-disk-utility

    pkgs.fortune
    pkgs.mgba

    #pkgs.git

    #pkgs.kakoune
    pkgs.neovim
    pkgs.vis
    #pkgs.emacs

    pkgs.ranger
    pkgs.nnn
    pkgs.broot

    pkgs.libreoffice
    pkgs.wpsoffice

    pkgs.qutebrowser
    pkgs.brave # web browser
    pkgs.tdesktop # Telegram
    pkgs.zoom-us

    pass # CLI password manager
  ];

  # ~/.Xresources
  #xresources.extraConfig = builtins.readFile ./src/.Xresources;

  programs.bash = {
    enable = true;

    #shellOptions = [
    #];

    # Environment variable t...
    #sessionVariables = {
    #};

    shellAliases = {
	aoeu = "setxkbmap us";
	asdf = "setxkbmap dvorak";

	l = "ls -alhF";
	ll = "ls --color=tty -Filah";
	j = "jobs";
	s = "sync";
	emacs = "emacs -nw";
	la = "ls -Fa";
	p = "pwd";
	a = "alias";
    };

    # Extra commands that should be run when initializing a login shell.
    # ~/.profile
    profileExtra = ''
    umask 0002
    export EDITOR='kak'
    export SHELL='fish'

    #. ~/.bashrc
    #. ~/.bash_profile
    . ~/.profile
    '';

    # Extra commands that should be run when initializing an interactive shell.
    #initExtra = ''
    #umask 0002
    #export EDITOR='kak'
    #'';

    # Extra commands that should be placed in ~/.bashrc.
    # Note that these commands will be run even in non-interactive shells.
    bashrcExtra = ''
    umask 0002
    export EDITOR='kak'
    export SHELL='fish'

    #. ~/.bashrc
    '';

    #logoutExtra = ''
    #'';
  };

  programs.direnv = { enable = true; };

  programs.command-not-found.enable = true;

  programs.broot = {
    enable = true;
  };

  programs.vim = {
    enable = true;
    extraConfig = builtins.readFile ./src/vim/vimrc; #vim/vimrc;
    settings = {
      relativenumber = true;
      number = true;
      #nowrap = true;
    };
    plugins = with pkgs.vimPlugins; [
      vim-elixir
      #vim-mix-format
      sensible
      vim-airline
      The_NERD_tree # file system explorer
      fugitive vim-gitgutter # git
      rust-vim
      #YouCompleteMe
      vim-abolish
      command-t
      vim-go
    ];
  };

  programs.emacs = {
    enable = true;
    extraPackages = epkgs: [
      epkgs.nix-mode
      epkgs.magit
    ];
  };

  programs.kakoune = {
    enable = true;
    extraConfig = builtins.readFile ./src/.config/kak/kakrc;
  };

  #programs.git = {
  #    enable = true;
  #    package = pkgs.gitAndTools.gitFull;
  #    userName = "Najib Ibrahim";
  #    userEmail = "mnajib@gmail.com";
  #    aliases = {
  #        co = "checkout";
  #        ci = "commit";
  #        st = "status";
  #        br = "branch";
  #        #hist = "log --pretty=format:'%C(yellow)%h%Cred%d%Creset - %C(cyan)%an %Creset: %s %Cgreen(%cr)' --graph --date=short --all";
  #        hist = "log --pretty=format:'%C(yellow)%h%Cred%d%Creset - %C(cyan)%an %Creset: %s %Cgreen(%cd)' --graph --date=short --all";
  #        histp = "log --pretty=format:'%C(yellow)%h%Cred%d%Creset - %C(cyan)%an %Creset: %s %Cgreen(%cd)' --graph --date=short --all -p";
  #        type = "cat-file -t";
  #        dump = "cat-file -p";
  #        branchall = "branch -a -vv";
  #    }
  #    extraConfig = {
  #        core = {
  #            editor = "vim";
  #            excludesfile = "~/.gitignore";
  #            whitespace = "trailing-space,space-before-tab";
  #        };
  #        merge = {
  #            tool = "vimdiff";
  #        };
  #        color = {
  #            ui = "auto";
  #            diff = "auto";
  #            status = "auto";
  #            branch = "auto";
  #        };
  #    };
  #};

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
  };

  services.xscreensaver = {
    enable = true;
    settings = {
      mode = "random";
      lock = false;
      fadeTicks = 20;
    };
  };

  #----------------------------------------------------------------------------
  home.file = {

    ".tmux.conf" = {
    text = ''
    set-option -g default-shell /run/current-system/sw/bin/fish # bash
    set-window-option -g mode-keys vi
    set -g default-terminal "screen-256color"
    set -ga terminal-overrides ',screen-256color:Tc'

    #set timeoutlen=1000 # Defalut 1000
    set ttimeoutlen=50 # Default 50
    #
    #set -g escape-time 10
    set -sg escape-time 10

    set -g clock-mode-style 24
    set -g history-limit 10000
    '';
    };

    #".profile".source = src/.profile;

    #".Xdefaults".source = src/.Xdefaults;

    #".config/kak" = {
    #  source = ./src/.config/kak;
    #  recursive = true;
    #};

    ".config/ranger" = {
      source = ./src/.config/ranger;
      recursive = true;
    };

    ".config/git" = {
      source = ./src/.config/git;
      recursive = true;
    };

    ".config/awesome" = {
      source = ./src/.config/awesome;
      recursive = true;
    };

    ".config/awesome/lain".source = fetchFromGitHub {
      owner = "lcpz";
      repo = "lain";
      rev = "9477093";
      sha256 = "0rfzf93b2v22iqsv84x76dy7h5rbkxqi4yy2ycmcgik4qb0crddp";
    };

    #"./bin".source = fetchFromGitHub { #fetchGit {
    #  owner = "mnajib";
    #  repo = "home-manager-conf";
    #};
    #"./bin".source = fetchGit {
      #url = "ssh://najib@mahirah:22/home/najib/GitRepos/bin.git";
      #...
    #};

    #".fonts" = {
    #  source = ./src/.fonts;
    #  recursive = true;
    #};

  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.11";
}
