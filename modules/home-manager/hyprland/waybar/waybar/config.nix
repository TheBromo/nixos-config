[{
  height = 33;
  layer = "top";
  position = "top";
  modules-center = [ "clock" ];
  modules-left = [ "custom/logo" "hyprland/workspaces" ];
  modules-right = [
    "backlight"
    "pulseaudio"
    "tray"
    "network"
    "battery"
  ];
  "custom/logo" = {
    "format" = " ";
  };
  "hyprland/workspaces" = {
    "persistent-workspaces" = {
      "*" = 5;
    };
    "format" = "{icon}";
    "format-icons" = {
      "default" = "󰝦";
      "active" = "󰝥";
    };
  };

  "sway/workspaces" = {
    "disable-scroll" = true;
    "all-outputs" = true;
    "format" = "{icon}";
    "format-icons" = {
      "default" = "󰝦";
      "focused" = "󰝥";
    };
    "persistent-workspaces" = {
      "1" = [ ];
      "2" = [ ];
      "3" = [ ];
      "4" = [ ];
      "5" = [ ];
    };
    "disable-click" = true;
  };
  "hyprland/submap" = {
    "format" = "󱨈";
  };
  "sway/mode" = {
    "format" = "{}";
  };
  "battery" = {
    "format" = "{icon} {capacity}";
    "format-icons" = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
    "tooltip" = false;
  };
  "custom/notifications" = {
    "exec" = "dunst-toggle-mode --read";
    "interval" = 1;
    "return-type" = "json";
    "format" = "{icon}{}";
    "on-click" = "dunst-toggle-mode --toggle";
    "signal" = 8;
  };
  clock = {
    interval = 60;
    format = "{: %H:%M  %d/%m}";
  };

  "backlight" = {
    "format" = "{icon} {percent}";
    "format-icons" = [ "" ];
  };
  "network" = {
    interval = 1;
    "format" = "{icon} {essid}";
    "format-alt" = "{ipaddr}/{cidr} {icon}";
    "format-alt-click" = "click-right";
    "format-icons" = {
      "wifi" = [ "󰤯" "󰤢" "󰤢" "󰤥" "󰤨" ];
      "ethernet" = [ "" ];
      "disconnected" = [ "󰤮" ];
    };
    "on-click" = "alacritty -e nimcli";
    "tooltip" = false;
  };
  pulseaudio = {
    format = "{icon} {volume}%";
    format-bluetooth = "{volume}% {icon} {format_source}";
    format-bluetooth-muted = " {icon} {format_source}";
    format-icons = {
      car = "";
      default = [ "" "" "" ];
      handsfree = "";
      headphones = "";
      headset = "";
      phone = "";
      portable = "";
    };
    on-click = "pavucontrol";
  };
}]
