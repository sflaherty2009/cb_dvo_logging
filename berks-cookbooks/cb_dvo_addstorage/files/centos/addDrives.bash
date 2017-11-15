#!/bin/bash

IFS=' ' read -r -a STANDARD <<< `lsblk -o NAME,SIZE | grep sd | sed 's/^\(.*\)\(sd.*\)$/\2/' | sort -r | uniq -u --check-char 3 | grep 979 | cut -d' ' -f 1 | sed ':a;N;$!ba;s/\n/ /g' `
IFS=' ' read -r -a PREMIUM <<< `lsblk -o NAME,SIZE | grep sd | sed 's/^\(.*\)\(sd.*\)$/\2/' | sort -r | uniq -u --check-char 3 | grep -v 979 | cut -d' ' -f 1 | sed ':a;N;$!ba;s/\n/ /g'`

declare -a allDrives
allDrives=("${PREMIUM[@]}" "${STANDARD[@]}")
echo "Preparing drive(s) ${allDrives[@]}"

for drive in ${allDrives[@]}; do
  echo -e "n\np\n1\n\n\np\nt\n8e\nw\n" | fdisk /dev/${drive}
  pvcreate /dev/${drive}1
done

if [[ ! -z ${STANDARD[0]} ]]; then
  declare -a allStandardDevices=()
  for standardDisk in ${STANDARD[@]}; do
    allStandardDevices+=("/dev/${standardDisk}1")
  done
  vgcreate standard_vg ${allStandardDevices[@]}
  lvcreate --name standard_lv -l 100%FREE standard_vg
  mkfs.xfs /dev/standard_vg/standard_lv
  mkdir /standard
  echo -e "/dev/standard_vg/standard_lv\t/standard\txfs\tdefaults\t0 0" >> /etc/fstab
  mount -a
  xfs_growfs -m 25% /standard
  chmod 777 /standard
fi

if [[ ! -z ${PREMIUM[0]} ]]; then
  declare -a allPremiumDevices=()
  for premiumDisk in ${PREMIUM[@]}; do
    allPremiumDevices+=("/dev/${premiumDisk}1")
  done
  vgcreate premium_vg ${allPremiumDevices[@]}
  lvcreate --name premium_lv -l 100%FREE premium_vg
  mkfs.xfs /dev/premium_vg/premium_lv
  mkdir /premium
  echo -e "/dev/premium_vg/premium_lv\t/premium\txfs\tdefaults\t0 0" >> /etc/fstab
  mount -a
  xfs_growfs -m 25% /premium
  chmod 777 /premium
fi
