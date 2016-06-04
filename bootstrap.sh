#!/bin/bash -eux

user="$1"
password="$2"

host=$(netstat -rn | grep '^0.0.0.0 ' | cut -d ' ' -f10)

git clone https://github.com/mattclay/ansible-hacking

sudo ansible-hacking/bootstrap.sh os -y -q
sudo apt-get install python-pip python-xmltodict -y -q
sudo pip install pywinrm

git clone https://github.com/mattclay/ansible --recursive

cd /home/ubuntu/ansible
source hacking/env-setup

cat << EOF > test/integration/inventory.winrm
[winrm]
winrm-pipelining    ansible_ssh_pipelining=true
winrm-no-pipelining ansible_ssh_pipelining=false

[winrm:vars]
ansible_connection=winrm
ansible_host=${host}
ansible_user=${user}
ansible_password=${password}
ansible_port=5986
ansible_winrm_server_cert_validation=ignore
EOF

cd test/integration

TEST_FLAGS='-vvvvv' make test_connection_winrm
