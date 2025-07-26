#!/bin/bash

set -e

tmux setw monitor-silence 3
trap 'tmux setw monitor-silence 0' EXIT

WORKING_DIR=$(pwd)

options=()

# privilege
options+=('-p' 'NoNewPrivileges=yes')


# Device Access
options+=('-p' 'PrivateDevices=yes')
options+=('-p' 'DevicePolicy=closed')
options+=('-p' 'DeviceAllow=/dev/null rw')
options+=('-p' 'DeviceAllow=/dev/random r')
options+=('-p' 'DeviceAllow=/dev/urandom r')

# User
options+=('-p' 'PrivateUsers=yes')
options+=('-p' 'LockPersonality=yes')

# Process
options+=('-p' 'PrivatePIDs=yes')

# Mount
options+=('-p' 'PrivateMounts=yes')

# Network
options+=('-p' 'PrivateNetwork=no')
options+=('-p' 'RestrictAddressFamilies=AF_UNIX AF_INET AF_INET6')

# IPC
options+=('-p' 'PrivateIPC=yes')

# filesystem

options+=('-p' 'ProtectSystem=strict')

## grant access to home directories, but only to read (no write)	
options+=('-p' 'ProtectHome=read-only')
options+=('-p' "ReadWritePaths='$WORKING_DIR'")
options+=('-p' "ReadWritePaths='$HOME/.config'")
options+=('-p' "ReadWritePaths='$HOME/.cache'")

## explicit deny list
options+=('-p' "InaccessiblePaths='$HOME/.ssh'")
options+=('-p' "InaccessiblePaths='$HOME/.gnupg'")
# options+=('-p' "InaccessiblePaths='/etc/passwd'")

## /tmp
options+=('-p' 'PrivateTmp=yes')

## /proc
options+=('-p' 'ProtectProc=invisible')
options+=('-p' 'ProcSubset=pid')

# /sys/fs/cgroup
options+=('-p' 'ProtectControlGroups=yes')

options+=('-p' 'RestrictFileSystems=ext4 tmpfs proc sysfs')

# syscall
options+=('-p' 'SystemCallArchitectures=native')
options+=('-p' 'SystemCallFilter="@system-service"')
options+=('-p' 'SystemCallFilter="~@privileged @debug"')
options+=('-p' 'SystemCallErrorNumber=EPERM')


# other

## clock
options+=('-p' 'ProtectClock=yes')

## hostname
options+=('-p' 'ProtectHostname=yes')

# kernel log
options+=('-p' 'ProtectKernelLogs=yes')

# kernel modules
options+=('-p' 'ProtectKernelModules=yes')

# kernel tunables
options+=('-p' 'ProtectKernelTunables=yes')

# namespace
options+=('-p' 'RestrictNamespaces=yes')

# realtime
options+=('-p' 'RestrictRealtime=yes')

# setuid/gid
options+=('-p' 'RestrictSUIDSGID=yes')

# capabilities
options+=('-p' 'CapabilityBoundingSet=""')
options+=('-p' 'AmbientCapabilities=""')
options+=('-p' 'MemoryDenyWriteExecute=no')
options+=('-p' 'UMask=0077')
options+=('-p' 'CoredumpFilter=0')
options+=('-p' 'KeyringMode=private')
options+=('-p' 'NotifyAccess=none')

systemd-run \
  --user \
  --pipe \
  --wait \
  --collect \
  --same-dir \
  -E PATH="$PATH" \
  "${options[@]}" \
  "$@"