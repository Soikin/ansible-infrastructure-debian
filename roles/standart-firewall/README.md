# Ansible Role: Firewall (iptables)

Installs an iptables-based firewall for Linux. Supports both IPv4 (`iptables`) and IPv6 (`ip6tables`).

This firewall aims for simplicity over complexity, and only opens a few specific ports for incoming traffic (configurable through Ansible variables). If you have a rudimentary knowledge of `iptables` and/or firewalls in general, this role should be a good starting point for a secure system firewall.

After the role is run, a `firewall` init service will be available on the server. You can use `service firewall [start|stop|restart|status]` to control the firewall.

## Requirements

None.

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

    firewall_state: started
    firewall_enabled_at_boot: true
    firewall_systemd_name: firewall-varb

Controls the state of the firewall service; whether it should be running (`firewall_state`) and/or enabled on system boot (`firewall_enabled_at_boot`).

Firewall allow ports.

    firewall_allowed_tcp_ports:
      - "22"
      - "80"
      ...
    firewall_allowed_udp_ports: []

Firewall allow ip adresses.

    firewall_allowed_ipv4_adresses: []
      - "127.0.0.1"
      - "127.0.0.1/8"
    firewall_allowed_ipv6_adresses: []

Firewall allow ports to ip adresses.

    firewall_allowed_ports_for_ipv4:
      - ip: 127.0.0.1
        port: 228
        protocol: tcp
    firewall_allowed_ports_for_ipv6: []

Firewall additional rules.

    firewall_ipv4_additional_rules: []
    firewall_ipv6_additional_rules: []

Any additional (custom) rules to be added to the firewall (in the same format you would add them via command line, e.g. `iptables [rule]`/`ip6tables [rule]`). A few examples of how this could be used:

    # Allow only the IP 167.89.89.18 to access port 4949 (Munin).
    firewall_ipv4_additional_rules:
      - "iptables -A INPUT -p tcp --dport 4949 -s 167.89.89.18 -j ACCEPT"

    # Allow only the IP 214.192.48.21 to access port 3306 (MySQL).
    firewall_ipv4_additional_rules:
      - "iptables -A INPUT -p tcp --dport 3306 -s 214.192.48.21 -j ACCEPT"

See [Iptables Essentials: Common Firewall Rules and Commands](https://www.digitalocean.com/community/tutorials/iptables-essentials-common-firewall-rules-and-commands) for more examples.

    firewall_log_dropped_packets: false

Whether to log dropped packets to syslog (messages will be prefixed with "Dropped by firewall: ").

## Dependencies

None.

## Example Playbook

    - hosts: server
      vars_files:
        - vars/main.yml
      roles:
        - { role: standart-firewall }

*Inside `vars/main.yml`*:

    firewall_allowed_tcp_ports:
      - "22"
      - "25"
      - "80"
