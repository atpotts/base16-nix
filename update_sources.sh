#! /usr/bin/env nix-shell
#! nix-shell -i bash -p bash curl nix-prefetch-git gnused jq

# Run from within the directory which needs the templates.json/schemes.json

# Not very safe - should be cleaner & could be more parallel
# should always be permitted to run to completion

generate_sources () {
  out=$1
  curl "https://raw.githubusercontent.com/chriskempson/base16-${out}-source/master/list.yaml"\
  | sed -nE "s~^([-_[:alnum:]]+): *(.*)~\1 \2~p"\
  | while read name src; do
      echo "{\"key\":\"$name\",\"value\":"
      nix-prefetch-git $src | jq '. + { "repo": "\(.url).git", "ref": "master", "type": "git" } | del(.url)'
      echo "}"
    done\
  | jq -s ".|del(.[].value.date)|from_entries"\
  > $out.json
}

generate_sources templates &
generate_sources schemes &
wait
