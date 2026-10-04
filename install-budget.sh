#!/usr/bin/env bash
# Run on Debian as root:  sudo ./install-budget.sh
set -e
cd "$(dirname "$0")/budget"
DEST=/usr/lib/systemd/system

# 1. Install the two tiers
install -m 644 background-tier.slice "$DEST/bgbudget.slice"
mkdir -p "$DEST/user.slice.d"
install -m 644 foreground-tier.conf "$DEST/user.slice.d/10-budget.conf"

# 2. Put every service from the list into the background tier
grep -v '^\s*#' background-services.txt | grep -v '^\s*$' | while read -r name; do
  mkdir -p "$DEST/$name.d"
  printf '[Service]\nSlice=bgbudget.slice\nNice=10\nIOSchedulingClass=best-effort\nIOSchedulingPriority=7\n' \
    > "$DEST/$name.d/10-budget.conf"
done

# 3. Disk scheduler rule for old hard drives
install -m 644 hdd-scheduler.rules /usr/lib/udev/rules.d/60-hdd-bfq.rules

systemctl daemon-reload
echo "Budget installed."