#!/bin/bash
# Wrapper to deploy the AIO guest
AIO="10.10.1.5"
ansible-playbook -i localhost, -b -K bootstrap.yaml

function port_open() {
  local host=$1
  nc -z -w 3 $host 22
}

while ! port_open $AIO
do
  echo "SSH port on $AIO is not open, sleeping.."
  sleep 3
done

# wipe and fetch the latest ssh fingerprint after a build
sed -i -e "/.*$AIO.*/d" $HOME/.ssh/known_hosts
echo "SSH port on $1 is now open, fetching ssh-keys"
ssh-keyscan $AIO >> /home/greg/.ssh/known_hosts

# Eject the initial nocloud datasource after the VM is bootstrapped
export VM_NAME="rhos-17-1"
export CDROM_DEVICE=$(sudo -E virsh domblklist ${VM_NAME} | grep cidata.iso | awk '{ print $1 }')
sudo -E virsh change-media ${VM_NAME} ${CDROM_DEVICE} --eject && \
echo "CD-ROM eject successfully."
