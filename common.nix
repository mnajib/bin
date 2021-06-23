{ config, pkgs, ... }:
#{ pkgs, ... }:

with import <nixpkgs> {};
with builtins;
with lib;
with import <home-manager/modules/lib/dag.nix> { inherit lib; };

{
  nixpkgs.config = {
    allowUnfree = true;
  };
  
  # Let Home Manager install and manage itself.
  programs.home-manager = {
    enable = true;
    path = "...";
  };

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "najib";#"$USER";
  home.homeDirectory = "/home/najib";#"$HOME";

  home.packages = [
    pkgs.htop
    pkgs.atop
    
    pkgs.fortune
    pkgs.mgba

    #pkgs.kakoune
    pkgs.neovim
    #pkgs.emacs
    
    pkgs.libreoffice
    pkgs.wpsoffice

    pkgs.brave # web browser
    pkgs.tdesktop # Telegram
    pkgs.zoom-us
  ];

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
    };

    # Extra commands that should be run when initializing a login shell.
    # ~/.profile
    profileExtra = ''
    umask 0002
    export EDITOR='kak'
    . ~/.bashrc
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
    eval "$(direnv hook bash)"
    '';

    #logoutExtra = ''
    #'';
  };

  programs.command-not-found.enable = true;

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

  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    userName = "Najib Ibrahim";
    userEmail = "mnajib@gmail.com";
  };

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
  };

  home.file = {

    ".tmux.conf" = {
    text = ''
    set-option -g default-shell /run/current-system/sw/bin/bash
    set-window-option -g mode-keys vi
    set -g default-terminal "screen-256color"
    set -ga terminal-overrides ',screen-256color:Tc'
    '';
    };

    #".profile".source = src/.profile;

    #".config/kak" = {
    #  source = ./src/.config/kak;
    #  recursive = true;
    #};

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
