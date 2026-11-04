#!/usr/bin/env bash
# Used by the simctl probe job on the tests/ci-stall-probe branch only. Not for merging.
#
#   ci_simctl_probe.sh start          record the CoreSimulator state, start watching simdiskimaged
#   ci_simctl_probe.sh call COMMAND   time the first and a second simctl call; COMMAND is list or runfirstlaunch
#   ci_simctl_probe.sh stop           wait for simdiskimaged to go idle, then collect the logs
set -uo pipefail

dir="${PROBE_DIR:-probe}"
mkdir -p "$dir"

now() { perl -MTime::HiRes=time -e 'printf "%.3f", time'; }
stamp() { date -u +%H:%M:%S; }

# Runs a command with a time limit, prints how long it took; while it runs, samples it once at 3 s
timed() {
  local name=$1 limit=$2; shift 2
  local start end status pid
  start=$(now)
  perl -e 'alarm shift; exec @ARGV' "$limit" "$@" > "$dir/$name.out" 2>&1 &
  pid=$!
  ( sleep 3; kill -0 $pid 2>/dev/null && for p in $(pgrep -P $pid) $pid; do sudo sample "$p" 2 -file "$dir/${name}_sample_$p.txt" > /dev/null 2>&1; done ) &
  wait $pid
  status=$?
  end=$(now)
  echo "$(stamp) $name: $(perl -e "printf '%.1f', $end - $start")s exit $status: $*" | tee -a "$dir/timings.txt"
}

state() {
  {
    echo "=== $(stamp) $1"
    echo "--- runner: $ImageOS $ImageVersion, $(sysctl -n hw.ncpu) cores, $(( $(sysctl -n hw.memsize) / 1073741824 )) GB"
    echo "--- booted: $(sysctl -n kern.boottime)"
    uptime
    echo "--- xcode-select: $(xcode-select -p)"
    echo "--- processes"
    ps -axo pid,lstart,etime,time,%cpu,comm | grep -E 'simdiskimaged|CoreSimulator|diskimagesiod|simctl|mobileassetd' | grep -v grep || echo "none"
    echo "--- /Library/Developer/CoreSimulator"
    sudo ls -laT /Library/Developer/CoreSimulator /Library/Developer/CoreSimulator/Images /Library/Developer/CoreSimulator/Volumes 2>&1
    echo "--- Cryptex"
    sudo find /Library/Developer/CoreSimulator/Cryptex -maxdepth 3 -exec ls -ldT {} + 2>&1 | head -60
    echo "--- caches"
    sudo ls -laT /Library/Developer/CoreSimulator/Caches ~/Library/Developer/CoreSimulator/Caches 2>&1
    echo "--- mounts"
    mount | grep -i -E 'simulator|cryptex' || echo "none"
  } > "$dir/state_$1.txt" 2>&1
}

case "${1:-}" in
  start)
    date -u +"%Y-%m-%d %H:%M:%S" > "$dir/start_time.txt"
    sudo log config --subsystem com.apple.CoreSimulator --mode "level:debug" 2>&1 | tee "$dir/log_config.txt"
    sudo cp /Library/Developer/CoreSimulator/Images/images.plist "$dir/images_before.plist" 2>/dev/null
    state 1-start
    # CPU time of the simulator processes every second
    nohup bash -c 'while true; do ps -axo lstart=,pid=,time=,%cpu=,comm= | grep -E "simdiskimaged|CoreSimulatorService|diskimagesiod" | grep -v grep | sed "s/^/$(date -u +%H:%M:%S) /"; sleep 1; done' > "$dir/cpu.txt" 2>&1 &
    echo $! > "$dir/pids"
    # Every file system call of simdiskimaged, from the moment it appears
    nohup bash -c '
      until pid=$(pgrep -x simdiskimaged); do sleep 0.2; done
      echo "$(date -u +%H:%M:%S) simdiskimaged $pid" > "$0/fs_usage_started.txt"
      sudo fs_usage -w -f filesys "$pid" > "$0/simdiskimaged_fs_usage.txt" 2>&1' "$dir" > /dev/null 2>&1 &
    echo $! >> "$dir/pids"
    # Once simdiskimaged uses over half a core: a 5 s sample of all its threads
    nohup bash -c '
      until pid=$(ps -axo pid=,%cpu=,comm= | awk "\$3 ~ /\/simdiskimaged\$/ && \$2 > 50 {print \$1; exit}") && [ -n "$pid" ]; do sleep 0.5; done
      echo "$(date -u +%H:%M:%S) sampling simdiskimaged $pid" > "$0/simdiskimaged_sampled.txt"
      sudo sample "$pid" 5 1 -file "$0/simdiskimaged_sample.txt" >> "$0/simdiskimaged_sampled.txt" 2>&1' "$dir" > /dev/null 2>&1 &
    echo $! >> "$dir/pids"
    ;;

  call)
    state 2-before-call
    case "$2" in
      list) timed first_call 600 xcrun simctl list -j devices ;;
      runfirstlaunch)
        timed check_first_launch 600 xcodebuild -checkFirstLaunchStatus
        timed run_first_launch 600 xcodebuild -runFirstLaunch
        timed first_call 600 xcrun simctl list -j devices ;;
      *) echo "unknown call $2" >&2; exit 2 ;;
    esac
    timed second_call 600 xcrun simctl list -j devices
    state 3-after-call
    ;;

  stop)
    # The scan may outlast the call: wait until simdiskimaged has used under 1 s of CPU in 15 s, at most 5 minutes
    cpu() { ps -o time= -p "$(pgrep -x simdiskimaged)" 2>/dev/null | awk -F'[:.]' '{print $1 * 60 + $2}'; }
    for _ in $(seq 20); do
      before=$(cpu); sleep 15; after=$(cpu)
      echo "$(stamp) simdiskimaged cpu ${before:-none} -> ${after:-none}" >> "$dir/timings.txt"
      [ "${before:-0}" = "${after:-0}" ] && break
    done
    state 4-end
    # Runtime identifiers, to compare across VMs of the same image (actions/runner-images#14946)
    xcrun simctl runtime list -j > "$dir/runtimes.json" 2>&1
    xargs kill < "$dir/pids" 2>/dev/null
    sudo pkill -INT -x fs_usage
    sleep 2
    sudo cp /Library/Developer/CoreSimulator/Images/images.plist "$dir/images_after.plist" 2>/dev/null
    cp ~/Library/Logs/CoreSimulator/CoreSimulator.log "$dir/" 2>/dev/null || echo "no CoreSimulator.log"
    # Everything since boot, at info and debug level
    sudo log show --info --debug --style compact --start "$(date -r "$(sysctl -n kern.boottime | sed -E 's/^\{ sec = ([0-9]+),.*/\1/')" +"%Y-%m-%d %H:%M:%S")" \
      --predicate 'process == "simdiskimaged" OR process == "diskimagesiod" OR process CONTAINS "CoreSimulator" OR subsystem BEGINSWITH "com.apple.CoreSimulator" OR process == "lsd" OR process == "coreservicesd" OR process == "cryptexd" OR process == "mobileassetd" OR subsystem == "com.apple.launchservices"' \
      > "$dir/unified_log.txt" 2>&1
    sudo chown "$(id -u)" "$dir"/* 2>/dev/null
    gzip -f "$dir/unified_log.txt" "$dir/simdiskimaged_fs_usage.txt" 2>/dev/null
    cat "$dir/timings.txt"
    ls -la "$dir"
    ;;

  *)
    echo "usage: $0 start | call list|runfirstlaunch | stop" >&2
    exit 2
    ;;
esac
