# Base16 themes for home manager

This is a messy, personal set of scripts for managing colour schemes within
hame manager. I am yet to share it because there are some unprincipled
components likely to break (e.g. using `sed` to read yaml files), and because
the build functions it introduces use sizable external dependencies.

I have found aspects of this very nice to use, and have tried to clean it up
enough to be suitable for others to adapt. YMMV however.

## Usage

N.b. this example roughly reflects y usage, but I haven't tried to use it
directly, so there may be typos / bugs

```nix
{pkgs, lib, config, ...}:
{
  imports = [ ./base16.nix ];
   config = {

    # Choose your themee
    themes.base16 = {
      enable = true;
      scheme = "solarized";
      variant = "solarized-dark";

      # Add extra variables for inclusion in custom templates
      extraParams = {
        fontname = mkDefault  "Inconsolata LGC for Powerline";
        headerfontname = mkDefault  "Cabin";
        bodysize = mkDefault  "10";
        headersize = mkDefault  "12";
        xdpi= mkDefault ''
          Xft.hintstyle: hintfull
        '';
    };
    };

    # 1. Use pre-provided templates
    ###############################

    programs.bash.initExtra = ''
      source ${config.lib.base16.base16template "shell"}
    '';
    home.file.".vim/colors/mycolorscheme.vim".source =
      config.lib.base16.base16template "vim";

    # 2. Use your own templates
    ###########################

    home.file.".Xresources".source = config.lib.base16.template {
      src = ./examples/Xresources;
    };
    home.file.".xmonad/xmobarrc".source = config.lib.base16.template {
      src = ./examples/xmobarrc;
    };

    # 3. Template strings directly into other home-manager configuration
    ####################################################################

    services.dunst = {
        enable = true;
        settings = with config.lib.base16.theme;
            {
              global = {
                geometry         =  "600x1-800+-3";
                font             = "${headerfontname} ${headersize}";
                icon_path =
                  config.services.dunst.settings.global.icon_folders;
                alignment        = "right";
                frame_width      = 0;
                separator_height = 0;
                sort             = true;
              };
              urgency_low = {
                background = "#${base01-hex}";
                foreground = "#${base03-hex}";
              };
              urgency_normal = {
                background = "#${base01-hex}";
                foreground = "#${base05-hex}";
              };
              urgency_critical = {
                msg_urgency = "CRITICAL";
                background  = "#${base01-hex}";
                foreground  = "#${base08-hex}";
              };
        };
     };


  };
}
```

## Reloading

Changing themes involves switching the theme definitoin and typing
`home-manager switch`. There is no attempt in general to force programs to
reload, and not all are able to reload their configs, although I have found
that reloading xmonad and occasionally restarting applications has been
enough.

You are unlikely to achieve a complet switch without logging out and logging back
in again.

## Todo

Provide better support for custom schemes (currently this assumes you'll
want to use something in the base16 repositories, but there is no reason
for this).

## Updating Sources

`cd` into the directory in which the templates.yaml and schemes.yaml are
located, and run update_sources.sh
