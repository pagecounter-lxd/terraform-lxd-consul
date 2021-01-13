#cloud-config
packages:
- git 
- jq 
- vim 
- wget
- curl
- zip
- unzip
write_files:
  - path: /etc/systemd/resolved.conf
    permissions: "0644"
    owner: root:root
    content: |
      [Resolve]
      Domains=dc1.test dc2.test dc3.test dc4.test dc5.test
  - path: "/etc/consul_license.hclic"
    permissions: "0755"
    owner: "root:root"
    content: |
      ${license}
  - path: "/var/tmp/install-consul.sh"
    permissions: "0755"
    owner: "root:root"
    content: |
      #!/bin/bash -eux
      export DC=${dc}
      export IFACE=${iface}
      export COUNT=${consul_count}
      export RETRY_JOIN='${consul_server}'
      export WAN_JOIN='${consul_wan_join}'
      curl -sLo /tmp/consul.sh https://raw.githubusercontent.com/kikitux/curl-bash/master/consul-server/consul.sh
      bash /tmp/consul.sh
      sleep 5
      consul license put @/etc/consul_license.hclic
runcmd:
  - systemctl restart systemd-resolved.service
  - bash /var/tmp/install-consul.sh
  - touch /tmp/file
