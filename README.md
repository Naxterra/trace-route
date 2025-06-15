# tr.sh

A simple Bash script to scan multiple servers and ports — including ranges — to check which are reachable and which are not.

## Features

- Supports individual IPs, hostnames, and IP ranges like `192.168.1.5-192.168.1.10`
- Accepts port ranges like `22,80,443,1000-1005`
- Fast socket check using `/dev/tcp`
- Outputs colored results for easy readability
- Written in pure Bash, no external tools required

## Requirements

- Bash 4.x+
- Linux or macOS (supports `/dev/tcp`)
- `timeout` command (usually part of GNU coreutils)

## Installation

Clone the repository:

```bash
git clone https://github.com/yourusername/yourrepo.git
cd yourrepo
chmod +x tr.sh
