# Runs on the first text screen (tty1) of the Check USB. Nothing else is affected.
if [ "$(tty)" = "/dev/tty1" ]; then
  while true; do
    clear
    echo "VIREO: checking this PC. Nothing is installed or changed."
    /opt/vireo/check-edition.sh
    read -rn1 -p "Press R to check again, or any other key to shut down... " key
    echo
    case "$key" in
      r|R) continue ;;
      *)   sudo systemctl poweroff; break ;;
    esac
  done
fi