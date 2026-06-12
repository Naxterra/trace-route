# tr.sh

`tr.sh` is a small Bash TCP reachability checker. It scans one or more hosts against one or more ports and reports which connections are open or closed.

It is useful for quick checks when you do not need a full port scanner like `nmap`.

## Features

- Supports IPv4 addresses, hostnames, and localhost.
- Supports comma-separated host lists.
- Supports last-octet IPv4 ranges:
  - `192.168.1.5-10`
  - `192.168.1.5-192.168.1.10`
- Supports comma-separated ports and port ranges:
  - `22,80,443`
  - `8000-8010`
- Uses Bash `/dev/tcp` for TCP connection checks.
- Avoids unsafe interpolation of user input into shell code.
- Detects `timeout` or `gtimeout`.
- Supports interactive prompts or command-line options.
- Includes colored output, `--no-color`, and `NO_COLOR` support.
- Includes `--open-only` for cleaner output.
- Prints a scan summary.

## Requirements

- Bash 4.x or newer.
- Linux, macOS, or another environment where Bash supports `/dev/tcp`.
- `timeout` from GNU coreutils.

On most Linux systems, `timeout` is already available.

On macOS, install GNU coreutils:

```bash
brew install coreutils
```

The script automatically uses `gtimeout` if `timeout` is not available.

## Installation

```bash
git clone https://github.com/yourusername/yourrepo.git
cd yourrepo
chmod +x tr.sh
```

## Usage

Interactive mode:

```bash
./tr.sh
```

Command-line mode:

```bash
./tr.sh --hosts 192.168.1.1,192.168.1.5-10 --ports 22,80,443
```

Short options:

```bash
./tr.sh -H localhost,example.com -p 80,443 -t 2
```

Show only open ports:

```bash
./tr.sh -H 192.168.1.1-20 -p 22,80,443 --open-only
```

Disable colors:

```bash
./tr.sh -H example.com -p 80,443 --no-color
```

## Options

| Option | Description |
| --- | --- |
| `-H`, `--hosts` | Comma-separated hosts, IPs, or IPv4 ranges. |
| `-p`, `--ports` | Comma-separated ports or port ranges. |
| `-t`, `--timeout` | Timeout per connection in seconds. Default: `1`. |
| `--open-only` | Print only open results. |
| `--no-color` | Disable colored output. |
| `-h`, `--help` | Show help. |
| `-v`, `--version` | Show version. |

## Host Input Examples

Single IPv4 address:

```text
192.168.1.10
```

Multiple IPv4 addresses:

```text
192.168.1.10,192.168.1.20
```

Short last-octet range:

```text
192.168.1.5-10
```

Full last-octet range:

```text
192.168.1.5-192.168.1.10
```

Hostnames:

```text
localhost,example.com
```

## Port Input Examples

Single port:

```text
22
```

Multiple ports:

```text
22,80,443
```

Port range:

```text
8000-8010
```

Mixed:

```text
22,80,443,8000-8010
```

## Example Output

```text
Scanning 2 host(s), 3 port(s), 6 check(s), timeout 1s...

OPEN  - localhost:22
CLOSED - localhost:80
CLOSED - localhost:443
OPEN  - example.com:80
OPEN  - example.com:443
CLOSED - example.com:8080

Summary: 3 open, 3 closed, 6 total
```

## Notes

This script checks TCP connectability only. It does not identify services, perform UDP scans, detect operating systems, or replace a full scanner such as `nmap`.

Use it only on systems and networks you own or have permission to test.

## License

GPL-3.0-or-later. See <https://www.gnu.org/licenses/gpl-3.0.html>.
