#! /usr/bin/env bash

set -o errexit

show_help() {
  echo "Usage: $0 [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  -h, --help                 Show this help message and exit"
  echo "  -n, --hostname <name>      Specify the target hostname"
}

parse_hostname() {
  local target_host=""

  while [[ $# -gt 0 ]]; do
    case $1 in
      -h|--help)
        show_help >&2
        return 1
        ;;
      -n|--hostname)
        if [[ -n "$2" && "$2" != -* ]]; then
          target_host="$2"
          shift 2
        else
          echo "Error: Argument for $1 is missing." >&2
          return 1
        fi
        ;;
      *)
        echo "Unknown argument: $1" >&2
        show_help >&2
        return 1
        ;;
    esac
  done

  if [[ -z "$target_host" ]]; then
    echo "Error: --hostname <name> is required." >&2
    show_help >&2
    return 1
  fi

  echo "$target_host"
}

# 0. Parse the hostname.
declare -r MY_HOST=$(parse_hostname "$@")

# Exit if help was requested or an error occurred
if [[ $? -ne 0 ]]; then
  exit 1
fi
echo "Successfully parsed hostname: $MY_HOST"
echo

# 1. Stop slurm services.
#
# Stop all running slurm and authentication daemons.
sudo systemctl stop slurmd slurmctld munge
echo "Stopped all running slurm and authentication daemons."
echo

# Clear the controller state (where job queues are saved)
sudo rm -rf /var/spool/slurmctld/*

# 2. Wipe the Slurm State and Log Directories
#
# Clear the compute node spool (where active job steps are tracked)
sudo rm -rf /var/spool/slurmd/*

# Clear the Slurm log files
sudo rm -rf /var/log/slurm/*
echo "Wiped the Slurm State and Log Directories."
echo


# 3. Restart Services in a Clean State
#
# When restarting the controller and compute daemons, you must pass the -c
# (clear) flag. This forces them to ignore any old, corrupt configurations or
# broken paths and rebuild their internal state cache from scratch.

# Restart the authentication daemon first
sudo systemctl start munge

# Start the Controller and Node daemons with a clean state reset
sudo /usr/sbin/slurmctld -c
sudo /usr/sbin/slurmd -c
echo "Restarted services in a clean state."
echo

# Restore Normal Systemd Management
# 
# Kill temporary foreground processes and let systemd manage them
# normally moving forward:
sudo pkill slurmctld
sudo pkill slurmd

sudo systemctl start slurmctld
sudo systemctl start slurmd
echo "Restorted normal systemd management."
echo

echo "Information about Slurm nodes and partitions."
echo
sinfo
