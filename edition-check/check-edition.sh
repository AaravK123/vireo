#!/usr/bin/env bash
# Which Vireo fits this PC? Works on any Linux, including the Check USB.
source "$(dirname "$0")/thresholds.conf"

# ---------- 1. Look at the PC ----------
ram_mb=$(awk '/MemTotal/ {print int($2/1024)}' /proc/meminfo)
ram_gb=$(awk -v m="$ram_mb" 'BEGIN {printf "%.1f", m/1024}')
cores=$(nproc)

drive="unknown"
for d in /sys/block/sd* /sys/block/nvme*; do
  [ -e "$d" ] || continue
  [ "$(cat "$d/removable" 2>/dev/null)" = "1" ] && continue   # skip USB sticks
  case "$d" in *nvme*) drive="SSD"; break ;; esac
  if [ "$(cat "$d/queue/rotational")" = "1" ]; then drive="HDD"; else drive="SSD"; fi
  break
done

# ---------- 2. Apply the rules ----------
flow_ok=yes
reasons=()
if [ "$ram_mb" -lt "$FLOW_MIN_RAM_MB" ]; then
  flow_ok=no; reasons+=("Memory is ${ram_gb} GB. Flow works best with about 4 GB or more.")
fi
if [ "$cores" -lt "$FLOW_MIN_CORES" ]; then
  flow_ok=no; reasons+=("This processor has ${cores} core. Flow wants at least ${FLOW_MIN_CORES}.")
fi
if [ "$drive" = "HDD" ] && [ "$ram_mb" -lt "$FLOW_HDD_MIN_RAM_MB" ]; then
  flow_ok=no; reasons+=("This PC has an old spinning hard drive. Flow would feel slow on it without lots of memory.")
fi

# ---------- 3. Say it in plain English ----------
echo
echo "Your PC:  ${ram_gb} GB memory  |  ${cores} processor core(s)  |  ${drive} drive"
echo
if [ "$flow_ok" = "yes" ]; then
  echo "Recommended: VIREO FLOW"
  echo "Your PC can handle the animated, colorful version. Lite also works here."
else
  echo "Recommended: VIREO LITE"
  for r in "${reasons[@]}"; do echo " - $r"; done
  echo "Lite is quick on exactly this kind of PC."
fi
echo
echo "Download it at: $DOWNLOAD_URL"
echo