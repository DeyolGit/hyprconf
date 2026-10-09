chosen=$(printf "  Shutdown\n󰜉  Reboot\n󰒲  Suspend\n󰌾  Lock\n󰍃  Logout\n󰑐  Cancel" |
  rofi -dmenu -i -p "Power Menu")
case "$chosen" in
*Shutdown) systemctl poweroff ;;
*Reboot) systemctl reboot ;;
*Suspend) systemctl suspend ;;
*Lock) loginctl lock-session ;;
*Logout)
  # Replace this with your desktop/window manager's logout command
  ;;
*Cancel) exit 0 ;;
esac
