{ pkgs, config, lib, ... }:

let
  aliases = let
    exa = "${pkgs.exa}/bin/exa --group-directories-first";
  in {
    ls = "${exa}";
    ll = "${exa} -l";
    la = "${exa} -a";
    lla = "${exa} -al";
    mkd = "mkdir -p";
    cp = "cp -i";
    diff = "diff --color=auto";
    grep = "grep --color=auto";
    cat = "bat";
    hm = "home-manager";
  };
in
{
  programs = {
    home-manager.enable = true;

    emacs = {
      enable = true;
      package = pkgs.emacs.override { imagemagick = pkgs.imagemagickBig; };
      extraPackages = (epkgs:
        let requiredPackages =
              map (p: epkgs.${p})
                (builtins.filter
                  (p: builtins.hasAttr p epkgs && lib.isDerivation epkgs.${p})
                  (import ./emacs-packages.nix));
        in epkgs.withStraightOverrides requiredPackages
      );
    };

    zsh = {
      enable = true;
      shellAliases = aliases;
      enableCompletion = true;
      history = {
        extended = true;
        expireDuplicatesFirst = true;
        ignoreDups = true;
      };
      enableSyntaxHighlighting = true;
      enableAutosuggestions = true;
      autocd = true;
      # dotDir = ".config/zsh";
      defaultKeymap = "viins";
      plugins = [
        # sfz-prompt
        {
          name = "sfz";
          src = builtins.fetchGit {
            url = "https://github.com/teu5us/sfz-prompt.zsh";
            rev = "1419b468675c367fa44cd14e1bf86997f2ada5fc";
          };
        }
        {
          name = "fzf-tab";
          src = builtins.fetchGit {
            url = "https://github.com/Aloxaf/fzf-tab";
            rev = "c5c6e1d82910fb24072a10855c03e31ea2c51563";
          };
        }
      ];
      initExtra = ''
              # Emacs tramp fix
              if [[ "$TERM" == "dumb" ]]
              then
                unsetopt zle
                unsetopt prompt_cr
                unsetopt prompt_subst
                # unfunction precmd
                # unfunction preexec
                export PS1='$ '
              fi
              bindkey '^F' autosuggest-accept
              bindkey '^G' toggle-fzf-tab
              # indicate mode by cursor shape
              zle-keymap-select () {
              if [ $KEYMAP = vicmd ]; then
                  printf "\033[2 q"
              else
                  printf "\033[6 q"
              fi
                              }
              zle-line-init () {
                  zle -K viins
                  printf "\033[6 q"
                              }
              zle-line-finish () {
                  printf "\033[2 q"
                              }
              zle -N zle-keymap-select
              zle -N zle-line-init
              zle -N zle-line-finish
              DISABLE_AUTO_TITLE="true"
              function precmd() {
                # echo -en "\e]2;$@\a"
                print -Pn "\e]0;%~\a"
              }
            '';
    };

    bat.enable = true;

    git = {
      enable = true;
      userName = "Pavel Stepanov";
      userEmail = "paulkreuzmann@gmail.com";
      extraConfig = {
        core.compression = 9;
        http.followRedirects = "true";
        http.maxRequests = 5;
        protocol.version = 2;
      };
    };

    autojump.enable = true;

    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };

    fzf = {
      enable = true;
      defaultCommand = "fd --type f";
      defaultOptions = [ "--height 40%" "--prompt »" "--layout=reverse" ];
      fileWidgetCommand = "fd --type f";
      fileWidgetOptions = [ "--preview 'head {}'" ];
      changeDirWidgetCommand = "fd --type d";
      changeDirWidgetOptions = [ "--preview 'tree -C {} | head -200'" ];
      # historyWidgetCommand = "history";
      # historyWidgetOptions = [ ];
      enableBashIntegration = true;
      enableZshIntegration = true;
    };

    direnv = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
  };

  home.packages = with pkgs; [
    github-cli
    fd
    ripgrep
    roswell
    sbcl
  ];
}
