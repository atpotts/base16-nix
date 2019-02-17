{config,lib,pkgs,...}:
with lib;
let
  cfg = config.themes.base16;
  templates = importJSON ./templates.json;
  schemes = importJSON ./schemes.json;

  # pure bash mustache engine
  mustache = template-attrs: name: src:
    pkgs.stdenv.mkDerivation (
      {
          name="${name}-${template-attrs.scheme-slug}";
          inherit src;
          data = pkgs.writeText "${name}-data" (builtins.toJSON template-attrs);
          phases = [ "buildPhase" ];
          buildPhase ="${pkgs.mustache-go}/bin/mustache $data $src > $out";
          allowSubstitutes = false;  # will never be in cache
      });

  # nasty python script for dealing with yaml + different output types
  python = pkgs.python.withPackages (ps: with ps; [ pyyaml ]);
  loadyaml = {src, name ? "yaml"}:
       importJSON (pkgs.stdenv.mkDerivation {
            inherit name src;
            builder = pkgs.writeText "builder.sh" ''
             slug_all=$(${pkgs.coreutils}/bin/basename $src)
             slug=''${slug_all%.*}
              ${python}/bin/python ${./base16writer.py} $slug < ${src} > $out
            '';
            allowSubstitutes = false;  # will never be in cache
        });

  theme = loadyaml {
      src="${pkgs.fetchgit (schemes."${cfg.scheme}")}/${cfg.variant}.yaml";
    };

in
{
  options = {
    themes.base16.enable = mkEnableOption "Base 16 Color Schemes";
    themes.base16.scheme = mkOption {
        type=types.str;
        default="solarized";
       };
    themes.base16.variant = mkOption {
        type=types.str;
        default="solarized-dark";
       };
    themes.base16.extraParams = mkOption {
       type = types.attrsOf types.string; default = {};
    };
  };

  config = {
      lib.base16.theme = theme // cfg.extraParams;
      lib.base16.base16template = repo:
          mustache (theme // cfg.extraParams) repo
            "${pkgs.fetchgit (templates."${repo}")}/templates/default.mustache";
      lib.base16.template = attrs@{name ? "unknown-template", src , ...}:
          mustache (theme // cfg.extraParams // attrs) name src;
  };


}



