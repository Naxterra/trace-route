#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script Name : tr.sh
# Description : Checks TCP connectivity for multiple hosts and ports.
# Author      : Naxterra
# Contact     : github@shades.systems
# License     : GPL-3.0-or-later
# ------------------------------------------------------------------------------
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# See <https://www.gnu.org/licenses/gpl-3.0.html> for details.

[ -n "${BASH_VERSION:-}" ] || { echo "Please run this script with bash." >&2; exit 1; }

set -o nounset
set -o pipefail

VERSION="1.0.0"
CONNECT_TIMEOUT="1"
HOST_INPUT=""
PORT_INPUT=""
OPEN_ONLY=0
USE_COLOR=1

if [[ -n "${NO_COLOR:-}" || ! -t 1 ]]; then
    USE_COLOR=0
fi

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

usage() {
    cat <<'EOF'
tr.sh - TCP reachability checker

Usage:
  ./tr.sh [options]

Options:
  -H, --hosts HOSTS       Comma-separated hosts/IPs/ranges.
                          Examples:
                            192.168.1.10
                            192.168.1.10-20
                            192.168.1.10-192.168.1.20
                            localhost,example.com

  -p, --ports PORTS       Comma-separated ports/ranges.
                          Examples:
                            22,80,443
                            8000-8010

  -t, --timeout SECONDS   Per-connection timeout. Default: 1
      --open-only         Show only open ports.
      --no-color          Disable colored output.
  -h, --help              Show this help message.
  -v, --version           Show version.

Interactive mode:
  If --hosts or --ports are omitted, the script prompts for them.

Examples:
  ./tr.sh --hosts 192.168.1.1,192.168.1.10-20 --ports 22,80,443
  ./tr.sh -H localhost,example.com -p 80,443 -t 2 --open-only
EOF
}

die() {
    echo "Error: $*" >&2
    exit 1
}

warn() {
    if (( USE_COLOR )); then
        printf "${YELLOW}Warning:${NC} %s\n" "$*" >&2
    else
        printf "Warning: %s\n" "$*" >&2
    fi
}

trim() {
    local value=$1
    value="${value#"${value%%[![:space:]]*}"}"
    value="${value%"${value##*[![:space:]]}"}"
    printf '%s' "$value"
}

is_uint() {
    [[ $1 =~ ^[0-9]+$ ]]
}

is_valid_octet() {
    is_uint "$1" && (( 10#$1 >= 0 && 10#$1 <= 255 ))
}

is_valid_port() {
