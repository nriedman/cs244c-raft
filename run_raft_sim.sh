#!/usr/bin/env bash
set -euo pipefail

# run_raft_sim.sh - helper for running raftexample inside the network namespaces
# created by network/setup_network.sh
#
# Usage:
#   ./run_raft_sim.sh start <N>   # create namespaces and launch N raftexample nodes
#   ./run_raft_sim.sh stop        # stop running raftexample nodes
#   ./run_raft_sim.sh clean       # stop nodes + tear down namespaces
#   ./run_raft_sim.sh status      # show running nodes
#
# This script assumes you have built raftexample in the repo root (./raftexample).

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SIMDIR="$SCRIPT_DIR/.raft_sim"
PIDS_FILE="$SIMDIR/pids.txt"
NODES_FILE="$SIMDIR/nodes.txt"

NETWORK_SCRIPT="$SCRIPT_DIR/network/setup_network.sh"
RAFT_BIN="$SCRIPT_DIR/raftexample"

if [[ ! -x "$RAFT_BIN" ]]; then
  echo "raftexample binary not found; building it..."
  (cd "$SCRIPT_DIR/raftexample" && go build -o "$RAFT_BIN")
fi

function usage() {
  cat <<EOF
Usage: $0 <command>

Commands:
  start <N>   Create network namespaces and launch N raftexample nodes.
  stop        Stop raftexample nodes (does not tear down network).
  clean       Stop raftexample nodes and remove network namespaces.
  status      Show status of running raftexample nodes.

Example:
  sudo $0 start 3
  sudo $0 status
  sudo $0 stop
  sudo $0 clean
EOF
  exit 1
}

function ensure_root() {
  if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root (use sudo)"
    exit 1
  fi
}

function ensure_simdir() {
  mkdir -p "$SIMDIR"
}

function get_cluster_urls() {
  local n=$1
  local urls=()
  for i in $(seq 1 "$n"); do
    urls+=("http://10.10.0.$i:12379")
  done
  IFS=','; echo "${urls[*]}"; unset IFS
}

function start_nodes() {
  local n=$1
  ensure_simdir

  # Ensure the network is configured
  "$NETWORK_SCRIPT" "$n"

  local cluster
  cluster=$(get_cluster_urls "$n")

  # Launch one raftexample per namespace.
  # Each node uses the same ports inside its namespace.
  : > "$PIDS_FILE"
  : > "$NODES_FILE"

  for i in $(seq 1 "$n"); do
    ns="node$i"
    echo "Starting node $i in namespace $ns"

    ip netns exec "$ns" "$RAFT_BIN" --id "$i" --cluster "$cluster" --port 12380 &
    pid=$!

    echo "$i:$pid" >> "$PIDS_FILE"
    echo "$ns" >> "$NODES_FILE"
  done

  echo "Launched $n raftexample nodes (PIDs recorded in $PIDS_FILE)."
  echo "Each node listens for Raft traffic on 10.10.0.X:12379 and KV API on 10.10.0.X:12380."
}

function stop_nodes() {
  if [[ ! -f "$PIDS_FILE" ]]; then
    echo "No pid file found; nothing to stop."
    return
  fi

  echo "Stopping raftexample nodes..."
  while IFS= read -r line; do
    pid="${line#*:}"
    if [[ -n "$pid" && -e /proc/$pid ]]; then
      kill "$pid" 2>/dev/null || true
      wait "$pid" 2>/dev/null || true
      echo "Stopped pid $pid"
    fi
  done < "$PIDS_FILE"
  rm -f "$PIDS_FILE"
}

function status() {
  if [[ ! -f "$PIDS_FILE" ]]; then
    echo "No running nodes tracked."
    return
  fi
  echo "Tracked raftexample node PIDs:";
  while IFS= read -r line; do
    id="${line%%:*}"
    pid="${line#*:}"
    if [[ -e /proc/$pid ]]; then
      echo "  node $id -> pid $pid (running)"
    else
      echo "  node $id -> pid $pid (not running)"
    fi
  done < "$PIDS_FILE"
}

function clean() {
  stop_nodes
  echo "Tearing down network namespaces..."
  "$NETWORK_SCRIPT" clean
  rm -rf "$SIMDIR"
}

if [[ $# -lt 1 ]]; then
  usage
fi

cmd="$1"; shift
case "$cmd" in
  start)
    ensure_root
    if [[ $# -ne 1 ]]; then
      usage
    fi
    start_nodes "$1"
    ;;
  stop)
    ensure_root
    stop_nodes
    ;;
  clean)
    ensure_root
    clean
    ;;
  status)
    status
    ;;
  *)
    usage
    ;;
esac
