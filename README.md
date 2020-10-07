vpn_or_bust
===========

vpn_or_bust can force external traffic through a VPN, like an always-on VPN, but with iptables

# How

Based on the ovpn file you specify or select from the current folder,
the VPN IPs get allowed using iptables, while the policy gets set to DROP mode.
It will also allow local IP address ranges (such as 192.168.x.x),
which will allow you to connect to new networks and local machines without the VPN.
You will however not be able to make any external requests before connecting to the VPN,
though you can configure that to happen automatically when connecting to certain networks.

# Enable

- Acquire or generate an ovpn file (either store it next to the script, or give it as an argument)
- Optional: make a `credentials.txt` next to the script (1st line for username, 2nd line for password)
- Run `./enable.sh <config.ovpn>` or `./enable.sh` and pick a ovpn file from the same folder using FZF

To switch to a different VPN, simply run `./enable.sh` again and use a different ovpn file.
If you want to combine vpn_or_bust with [hoyaf](https://github.com/Jelmerro/hoyaf),
make sure to run vpn_or_bust first.
If the rules are not persistent when rebooting,
check if the iptables location at the end of the program is correct for your linux distribution.

# Disable

Simply run `./disable.sh` to undo any changes to iptables (tables are flushed and policies are reset).
Finally consider deleting `/etc/sysconfig/iptables` to stop auto-loading on reboot.

# License

These scripts are released into the public domain under the terms of the [UNLICENSE](./UNLICENSE).
