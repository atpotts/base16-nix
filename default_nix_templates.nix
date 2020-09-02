{
  alacritty = theme: with theme; { 
    # Default colors
    primary = {
      background = "#${base00-hex}";
      foreground = "#${base05-hex}";
    };

    # Colors the cursor will use if `custom_cursor_colors` is true
    cursor = {
      text = "#${base00-hex}";
      cursor = "#${base05-hex}";
    };

    # Normal colors
    normal = {
      black = "#${base00-hex}";
      red = "#${base08-hex}";
      green = "#${base0B-hex}";
      yellow = "#${base0A-hex}";
      blue = "#${base0D-hex}";
      magenta = "#${base0E-hex}";
      cyan = "#${base0C-hex}";
      white = "#${base05-hex}";
    };

    # Bright colors
    bright = {
      black = "#${base03-hex}";
      red = "#${base08-hex}";
      green = "#${base0B-hex}";
      yellow = "#${base0A-hex}";
      blue = "#${base0D-hex}";
      magenta = "#${base0E-hex}";
      cyan = "#${base0C-hex}";
      white = "#${base07-hex}";
    };

    indexed_colors = [
      { index = 16; color = "#${base09-hex}"; }
      { index = 17; color = "#${base0F-hex}"; }
      { index = 18; color = "#${base01-hex}"; }
      { index = 19; color = "#${base02-hex}"; }
      { index = 20; color = "#${base04-hex}"; }
      { index = 21; color = "#${base06-hex}"; }
    ];
  };
}
