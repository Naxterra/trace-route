#!/bin/bash
# ------------------------------------------------------------------------------
# Script Name : tr.sh
# Description : Connects to multiple servers and ports to check if they are open
# Author      : Naxterra
# Contact     : github@shades.systems
# License     : GPL-3.0 license
# ------------------------------------------------------------------------------

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# See <https://www.gnu.org/licenses/gpl-3.0.html> for details.

[ -n "$BASH_VERSION" ] || { echo "Please run this script with bash."; exit 1; }

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

expand_ip_range() {
    local range=$1
    local ips=()

    IFS=',' read -ra ADDR <<< "$range"
    for ip in "${ADDR[@]}"; do
        if [[ $ip =~ ^([0-9]+\.[0-9]+\.[0-9]+)\.([0-9]+)-([0-9]+)$ ]]; then
            prefix="${BASH_REMATCH[1]}"
            start="${BASH_REMATCH[2]}"
            end="${BASH_REMATCH[3]}"
            for ((i=start; i<=end; i++)); do
                if (( i >= 0 && i <= 255 )); then
                    ips+=("$prefix.$i")
                fi
            done
        elif [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            ips+=("$ip")
        else
            echo "Warning: Skipping invalid IP format: $ip" >&2
        fi
    done

    echo "${ips[@]}"
}

expand_port_range() {
    local range=$1
    local ports=()

    IFS=',' read -ra PR <<< "$range"
    for p in "${PR[@]}"; do
        if [[ $p =~ ^([0-9]+)-([0-9]+)$ ]]; then
            for ((i=${BASH_REMATCH[1]}; i<=${BASH_REMATCH[2]}; i++)); do
                if (( i >= 1 && i <= 65535 )); then
                    ports+=("$i")
                fi
            done
        elif [[ $p =~ ^[0-9]+$ ]] && (( p >= 1 && p <= 65535 )); then
            ports+=("$p")
        else
            echo "Warning: Skipping invalid port: $p" >&2
        fi
    done

    echo "${ports[@]}"
}

# ---- Input Prompts ----
read -rp "Enter IPs (e.g., 192.168.1.1,192.168.1.5-192.168.1.7): " input_ips
read -rp "Enter ports (e.g., 22,80,443,8000-8005): " input_ports

hosts=($(expand_ip_range "$input_ips"))
ports=($(expand_port_range "$input_ports"))

echo -e "\nScanning...\n"

# ---- Scanning Loop ----
for host in "${hosts[@]}"; do
    for port in "${ports[@]}"; do
        timeout 1 bash -c "echo > /dev/tcp/$host/$port" 2>/dev/null && \
            echo -e "${GREEN}OPEN  - $host:$port${NC}" || \
            echo -e "${RED}CLOSED - $host:$port${NC}"
    done
done
