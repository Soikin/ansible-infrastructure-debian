An Ansible Role on Debian/Ubuntu.

### Content

* [Requirements](#requirements)
* [Roles](#roles)
* [Roles variables](#roles-variables)
* [Dependencies](#dependencies)
* [Example playbook](#example-playbook)
* [How to use it](#how-to-use-it)
* [Tips and tricks](#tips-and-tricks)
* [TroubleShooting](#troubleshooting)
* [License](#license)


### Roles
* [standart-common](#standart-common)
* [standart-firewall](#standart-firewall)
* [standart-mongodb](#standart-mongodb)
* [standart-mysql](#standart-mysql)
* [standart-nginx](#standart-nginx)
* [standart-nodejs](#standart-nodejs)
* [standart-php](#standart-php)
* [tools-docker](#tools-docker)
* [tools-phpmyadmin](#tools-phpmyadmin)
* [tools-toolset](#tools-toolset)
* [tools-web-proxy](#tools-web-proxy)
* [tools-zabbix-agent](#tools-zabbix-agent)

### Roles variables

#### standart-common

```yml
install_updates:        boolean # default false
install_utilites:       boolean # default false
create_users:           boolean # default false
update_init:            boolean # default false
update_security:        boolean # default false
change_local_hostname:  boolean # require new_local_hostname
force_update_local_ca:  boolean # default false
user_force_add_sudo:    boolean # default false
update_ansible_key:     boolean # default false
set_default_timezone:   ""      # default Europe/Minsk
user_list_deploy:
   - user1
   - user2
user_list_remove:
   - user3
install_extra_utilites:         # default not set
   - package1
   - package2
# Global setup
new_local_hostname:     ""      # default not set, example newtest (without .com .net and etc.)
new_second_full_domain: ""      # default not set
```

#### standart-mongodb

```yml
mongodb_default_conf_replace:     boolean # default false
mongodb_package_install_version:  ""      # require, default 3.6 (optional 3.6, 3.7, 4.0, 4.1, 4.2)
```

#### standart-mysql

```yml
mysql_root_username:              ""      # default root
mysql_root_password:              ""      # require, default profigroup (override)
mysql_root_password_update:       ""      # `yes` to forcibly update the root password, default no
mysql_enabled_on_startup:         ""      # default yes
mysql_secure_installation:        boolean # default true
mysql_delete_before_installation: boolean # default false
mysql_upgrade_packages:           boolean # default false
mysql_create_databases:           boolean # default false
mysql_create_users:               boolean # default false
mysql_default_conf_replace:       boolean # default false
mysql_package_repo_enable:        boolean # default false
mysql_package_repo_version:       ""      # require, default not set (optional 5.6 or 5.7 or 8.0)
mysql_databases:
   - name: example
     collation: utf8mb4_general_ci
     encoding: utf8mb4
mysql_users:
   - name: example
     host: 127.0.0.1
     password: secret
     priv: *.*:USAGE
```

#### standart-nginx

```yml
nginx_repo_use:                   boolean # default false
nginx_repo_mainline_use:          boolean # default false
nginx_ppa_version:                ""      # default stable
nginx_version:                    ""      # optional, for install specific version
nginx_package:                    ""      # default nginx (optional nginx-full or nginx-extras)
nginx_default_conf_replace:       boolean # default false
nginx_default_vhost_delete:       boolean # default true
nginx_conf_diable_server_tokens:  boolean # default true
nginx_conf_enable_gzip:           boolean # default true
nginx_static_enable_optimization: boolean # default true
# Variables for template configs
nginx_conf_user:                  ""      # default nginx
nginx_conf_worker_processes:      ""      # default auto
nginx_conf_worker_connections:    ""      # default 1024
nginx_conf_keepalive_timeout:     ""      # default 65
# Not used in this role, but it is necessary to specify other configs
nginx_default_http_port:          ""      # require, default not set
nginx_default_https_port:         ""      # optional, default not set
```

#### standart-nodejs

```yml
nodejs_install_simple:            boolean # default false
nodejs_version:                   ""      # default "6.x" (optional "8.x", "9.x")
nodejs_npm_install_list_packages: []      # default not set
nodejs_npm_local_packages:        []      # default not set
nodejs_npm_local_path:            ""      # default not set, require nodejs_npm_local_packages
nodejs_npm_global_packages:       []      # default not set
npm_version:                      ""      # default "latest"
```

#### standart-php

```yml
php_default_version:             ""      # require, default 7.3 (optional 7.0, 7.1, 7.2, 7.3)
php_default_conf_replace:        boolean # default false
php_install_default_packages:    boolean # default true
php_list_default_packages:       []      # look default config
php_install_additional_packages: boolean # default true
php_list_additional_packages:    []      # look default config
php_install_project_packages:    boolean # default false
php_list_project_packages:       []      # default not set
php_install_force_packages:      boolean # default false, if true: disable install other lists of packages php
php_list_force_packages:         []      # default not set
php_install_fpm_package:         boolean # default false
php_install_dev_package:         boolean # default false, is the same as php_install_pear_package
php_install_pear_package:        boolean # default false, is the same as php_install_dev_package
php_list_pear_package:           []      # TODO
```

#### standart-firewall

```yml
firewall_state:                   ""      # default started
firewall_enabled_at_boot:         boolean # default true
firewall_systemd_name:            ""      # default firewall-varb

firewall_allowed_tcp_ports:       []      # default 22, 80, 443, 10050
firewall_allowed_udp_ports:       []      # default not set

firewall_log_dropped_packets:     boolean # default false

firewall_allowed_ipv6_adresses:   []      # default not set
firewall_allowed_ipv4_adresses:   []      # default not set
  # - "127.0.0.1"
  # - "127.0.0.1/8"

firewall_allowed_ports_for_ipv6:  []      # default not set
firewall_allowed_ports_for_ipv4:  []      # default not set
  # - ip: 127.0.0.1
  #   port: 228
  #   protocol: tcp

firewall_ipv4_additional_rules:   []      # default not set
firewall_ipv6_additional_rules:   []      # default not set
```

#### tools-phpmyadmin

```yml
phpmyadmin_clear_install:       boolean # default false
phpmyadmin_nginx_phpfpm_config: boolean # default true
phpmyadmin_package_name:        ""      # default is set (name of zip archive)
phpmyadmin_package_checksum:    ""      # default is set (checksum of zip archive)
phpmyadmin_package_url_debian:  "URL"   # default is set
```

#### tools-zabbix-agent

```yml
zabbix_server_ip:           ""      # default, 172.17.110.250
zabbix_version:             ""      # default 4.2
zabbix_agent_hostname:      ""      # default ansible_fqdn
zabbix_agent_clear_install: boolean # default false
```

#### tools-toolset

```yml
toolset_gen_ssl_local:      boolean # default false
toolset_copy_certificates:  boolean # default false
toolset_sni_enable:         boolean # default false
toolset_ip_listen_enable:   boolean # default false
toolset_system_user:        ""      # default toolset
toolset_web_directory:      ""      # default htdocs
toolset_copy_nginx_config:  boolean # default false
toolset_copy_apache_config: boolean # default false
toolset_multi_nginx_apache: boolean # default false
toolset_web_hostname:       ""      # require, default is inventory_hostname
toolset_web_hostname_alias: ""      # optional, default not set
#toolset_additional_hostname: ""   # not working
#toolset_additional_include: []    # not working
toolset_nginx_user:         ""      # default toolset_system_user
nginx_default_http_port:        ""      # require, default not set
nginx_default_https_port:       ""      # require, default not set
toolset_project_users:
   - name: project
     shell: /bin/bash  # default shell if not set
     home: /h/project"
```

#### tools-docker

```yml
docker_package:             "" # default is set (docker-ce package)
docker_version:             "" # default is not set
docker_compose_install:     boolean # default true
docker_compose_version:     "" # default 1.24.1
docker_compose_checksum:    "" # default is set (checksum of zip archive)
docker_list_users_to_group: [] # default toolset
docker_log_max_size:        "" # default 100m
docker_log_max_files:       "" # default 5

```

#### tools-web-proxy

```yml
project_deploy_to_proxy_host: false
project_web_proxy_sites_list: [] # default is not set
  # - name: my-site.va
  #   proxy_ip: 127.0.0.1
  #   proxy_port: 8080
  #   tls: true

```

### Dependencies
Requires Ansible >= 2.8

### Example playbook
Example host file
```sh
[web-test]
test.rit ansible_ssh_host=172.17.110.110 ansible_ssh_user=ansible
```
Example playbook
```yml
- hosts: web-test
  vars:
    # standart-common
    install_updates: true
    upgrade_packages: true
    update_init: true
    create_users: false
    install_utilites: false
  become: yes
  become_user: root
  roles:
  - { role: standart-common }
```

### How to use it

```sh
ansible-playbook -i [HOST_FILE] [PLAYBOOK]
ansible-playbook -i test-host test-playbook.yml --key-file=test-ssh/id_rsa --tags="test" --limit=test.rit --check
```

### Tips and tricks
Running a playbook in dry-run mode or check for bad syntax
```sh
--check
--syntax-check
```

A list of tasks/hosts to complete for ansible playbook
```sh
--list-tasks
--list-hosts
```

Override or add to extra variable
```sh
--extra-vars "host=test.rit"
```

To limit the run by specifying the host or group
```sh
--limit=debian-test.rit
--limit=webservers
```

Ansible tags
```sh
--skip-tags "developers"
--tags="test"
```

Use another keys
```sh
--key-file=test-ssh/id_rsa
```

Verbose mode
```sh
-v    # log level 1
-vvvv # log level 4
```

Run a live command on all of your nodes
```sh
ansible -i test-host all -m ping
ansible all -a "/bin/echo hello"
ansible all --key-file=test-ssh/id_rsa -i host_developer -m ping
ansible all --key-file=test-ssh/id_rsa -i test-host -m shell -a 'exim -bpc' --limit=mail-hub* -u root -b
--module="shell"
--user="root"
--become # yes
```

Show information discovered from system (gather_facts)
```sh
ansible -i test-host test.rit -m setup
```

### TroubleShooting
When running jobs the returned output does not format carriage returns and newline characters (\r\n & \n).
This could be fixed to return cleaner output like the standard command module.
```sh
ansible-playbook [........] |  sed 's/\\n/\n/g'
```
Ubuntu 16.04 has python3, not 2.7.x. and Ansible doesn't support for Python 3 yet.
To fix this, you must first install Python 2.7 onto the server, and add to vars, example in [HOST_FILE]
```sh
[ubuntu16:vars]
ansible_python_interpreter=/usr/bin/python2.7
```

### License
MIT / BSD
