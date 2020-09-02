{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.themes.base16;

  # templates = importJSON ./templates.json;
  templates = import ./nix/sources.nix {
    sources = (importJSON ./templates.json) // cfg.extraTemplates;
  };

  # schemes = importJSON ./schemes.json;
  schemes = import ./nix/sources.nix {
    sources = (importJSON ./schemes.json) // cfg.extraSchemes;
  };

  # mustache engine
  mustache = template-attrs: name: src:
    pkgs.stdenv.mkDerivation (
      {
        name = "${name}-${template-attrs.scheme-slug}";
        inherit src;
        data = pkgs.writeText "${name}-data" (builtins.toJSON template-attrs);
        phases = [ "buildPhase" ];
        buildPhase = ''
          ${pkgs.mustache-go}/bin/mustache $data $src > $out
        '';
        allowSubstitutes = false; # will never be in cache
      }
    );

  # nasty python script for dealing with yaml + different output types
  python = pkgs.python.withPackages (ps: with ps; [ pyyaml ]);
  loadyaml = { src, name ? "yaml" }:
    importJSON (
      pkgs.stdenv.mkDerivation {
        inherit name src;
        builder = pkgs.writeText "builder.sh" ''
          slug_all=$(${pkgs.coreutils}/bin/basename $src)
          slug=''${slug_all%.*}
           ${python}/bin/python ${./base16writer.py} $slug < ${src} > $out
        '';
        allowSubstitutes = false; # will never be in cache
      }
    );

  theme = loadyaml {
    src = schemes."${cfg.scheme}" + "/${cfg.variant}.yaml";
  };

in
{
  options = {
    themes.base16.enable = mkEnableOption "Base 16 Color Schemes";

    themes.base16.schemes = mkOption {
      type = types.attrs;
      default = schemes;
    };

    themes.base16.extraSchemes = mkOption {
      type = types.attrs;
      default = {};
      description = "Extra base16 schemes using niv source format";
    };

    themes.base16.templates = mkOption {
      type = types.attrs;
      default = templates;
    };

    themes.base16.extraTemplates = mkOption {
      type = types.attrs;
      default = {};
      description = "Extra base16 themes using niv source format";
    };

    themes.base16.scheme = mkOption {
      type = types.str;
      default = "solarized";
    };

    themes.base16.variant = mkOption {
      type = types.str;
      default = "solarized-dark";
    };

    themes.base16.extraParams = mkOption {
      type = types.attrsOf types.str;
      default = {};
    };

    themes.base16.nixTemplates = mkOption {
      type = types.attrs;
      default = import ./default_nix_templates.nix;
    };
  };

  config = {
    lib.base16.theme = theme // cfg.extraParams;

    lib.base16.base16template = repo:
      mustache (theme // cfg.extraParams) repo (templates."${repo}" + "/templates/default.mustache");

    lib.base16.template = attrs@{ name ? "unknown-template", src, ... }:
      mustache (theme // cfg.extraParams // attrs) name src;

    lib.base16.nixTemplate = name: cfg.nixTemplates."${name}" theme;
  };


}
