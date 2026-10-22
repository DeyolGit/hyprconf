#!/usr/bin/env bash

# Rofi Power Menu

# Colors and appearance are handled by your Rofi theme.
# Change the lock command if you use a different locker.

lock() {
  if command -v loginctl >/dev/null 2>&1 &&
    command -v swaylock >/dev/null 2>&1; then
    swaylock
  elif command -v betterlockscreen >/dev/null 2>&1; then
    betterlockscreen -l
  elif command -v i3lock >/dev/null 2>&1; then
    i3lock
  else
    notify-send "Power Menu" "No supported screen locker found."
  fi
}

options=" Shutdown\n󰜉 Reboot\n Lock\n󰍃 Logout\n󰤄 Suspend\n󰜺 Cancel"

chosen=$(printf '%b' "$options" | rofi -dmenu \
  -no-custom \
  -p "" \
  -theme-str '
        window {
            width: 250px;
            border: 2px;
        }
        mainbox {
            children: [listview];
        }
        inputbar {
            enabled: false;
            children: [];
        }
        separator {
            enabled: false;
            height: 0px;
        }
      listview {
        border: 0px;
    }

    ')

case "$chosen" in
" Lock")
  lock
  ;;
"󰍃 Logout")
  loginctl terminate-user "$USER"
  ;;
"󰤄 Suspend")
  systemctl suspend
  ;;
"󰜉 Reboot")
  systemctl reboot
  ;;
" Shutdown")
  systemctl poweroff
  ;;
"󰜺 Cancel" | "")
  exit 0
  ;;
esac
