#!/usr/bin/env bash
# Used by the stall probe job on the tests/ci-stall-probe branch only. Not for merging.
#
#   ci_stall_probe.sh start            start the background monitors
#   ci_stall_probe.sh snapshot NAME    record the runner and CoreSimulator state; TIME_SIMCTL=true also times simctl
#   ci_stall_probe.sh stop             stop the monitors and collect the logs
set -uo pipefail

dir="${PROBE_DIR:-probe}"
mkdir -p "$dir"

stamp() { date -u +%H:%M:%S; }

# Runs a command with a time limit and prints how long it took
timed() {
  local limit=$1; shift
  local start end status
  start=$(perl -MTime::HiRes=time -e 'printf "%.3f", time')
  perl -e 'alarm shift; exec @ARGV' "$limit" "$@" > "$dir/last_output.txt" 2>&1
  status=$?
  end=$(perl -MTime::HiRes=time -e 'printf "%.3f", time')
  echo "$(stamp) $(perl -e "printf '%.1f', $end - $start")s exit $status: $*"
}

case "${1:-}" in
  start)
    date -u +"%Y-%m-%d %H:%M:%S" > "$dir/start_time.txt"
    nohup iostat -w 2 > "$dir/iostat.txt" 2>&1 &
    echo $! > "$dir/pids"
    nohup bash -c "while true; do echo \"=== \$(date -u +%H:%M:%S)\"; vm_stat | grep -E 'free|compressor|Pageouts|Swapouts'; ps -axro pid,ppid,etime,%cpu,rss,state,command | head -16; sleep 2; done" > "$dir/top.txt" 2>&1 &
    echo $! >> "$dir/pids"
    ;;

  snapshot)
    name=$2
    out="$dir/snapshot_$name.txt"
    {
      echo "=== $(stamp) $name"
      echo "--- runner: $ImageOS $ImageVersion, $(sysctl -n hw.ncpu) cores, $(( $(sysctl -n hw.memsize) / 1073741824 )) GB"
      echo "--- booted: $(sysctl -n kern.boottime)"
      uptime
      echo "--- spotlight"
      mdutil -s / 2>&1
      pgrep -lf 'mds|mdworker' || echo "no mds processes"
      echo "--- /Library/Developer/CoreSimulator/Images"
      ls -la /Library/Developer/CoreSimulator/Images 2>&1
      echo "--- simulator mounts"
      mount | grep -i -E 'simulator|cryptex' || echo "none"
      echo "--- CoreSimulator processes"
      pgrep -lf 'CoreSimulator|simdiskimaged' || echo "none"
      if [ "${TIME_SIMCTL:-false}" = "true" ]; then
        echo "--- simctl timings"
        timed 300 xcrun simctl runtime list
        cat "$dir/last_output.txt"
        timed 300 xcrun simctl list -j runtimes
        timed 300 xcrun simctl list devices
        timed 300 xcrun --find simctl
      fi
    } > "$out" 2>&1
    cat "$out"
    ;;

  stop)
    [ -f "$dir/pids" ] && xargs kill < "$dir/pids" 2>/dev/null
    cp ~/Library/Logs/CoreSimulator/CoreSimulator.log "$dir/" 2>/dev/null || echo "no CoreSimulator.log"
    sudo log show --style compact --start "$(cat "$dir/start_time.txt")" \
      --predicate 'process == "simdiskimaged" OR process CONTAINS "CoreSimulator" OR subsystem BEGINSWITH "com.apple.CoreSimulator" OR process == "mds" OR process == "mds_stores"' \
      > "$dir/unified_log.txt" 2>&1
    gzip -f "$dir/unified_log.txt"
    ls -la "$dir"
    ;;

  *)
    echo "usage: $0 start | snapshot NAME | stop" >&2
    exit 2
    ;;
esac
