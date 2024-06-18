#!/bin/sh
# Flavien PERIER <perier@flavien.io>
# Install Arch Linux base

set -e

SCRIPT_TITLE="Arch configuration"

loadkeys fr

HOSTNAME=$(whiptail --title "$SCRIPT_TITLE" -inputbox "Hostname" 3>&1 1>&2 2>&3)
HOSTNAME=$(whiptail --title "$SCRIPT_TITLE" -inputbox "Principal username" 3>&1 1>&2 2>&3)
HOSTNAME=$(whiptail --title "$SCRIPT_TITLE" -inputbox "Used disk" 3>&1 1>&2 2>&3)

parted --script $DISK mklabel msdos
parted --script $DISK mkpart primary 1 524288KB
parted --script $DISK mkpart primary 524288KB 4718592KB
parted --script $DISK mkpart primary 4608KB 100%

ip link
timedatectl set-ntp true

mkfs.fat -F32 ${DISK}1
mkswap ${DISK}2
mkfs.ext4 ${DISK}3

swapon ${DISK}2
mount ${DISK}3 /mnt

pacstrap /mnt base linux linux-firmware grub systemd dhcpcd sudo pacman flatpak

genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt

echo "$HOSTNAME" > /etc/hostname

# Grub installation
mkdir /boot/efi
mount ${DISK}1 /boot/efi
grub-install ${DISK} --target=i386-pc --root-directory=/mnt
grub-mkconfig -o /boot/grub/grub.cfg

# Tools configuration
echo "%sudo	ALL=(ALL:ALL) ALL" >> /etc/sudoers
groupadd sudo

# Local configuration
ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
hwclock --systohc
echo "fr_FR.UTF-8 UTF-8" > /etc/locale.gen
echo "LANG=fr_FR.UTF-8" > /etc/locale.conf
echo "KEYMAP=fr" > /etc/vconsole.conf
locale-gen

# Network configuration
cat << EOL > /etc/hosts
127.0.0.1 localhost
::1       localhost
EOL
cat << EOL > /etc/resolv.conf
nameserver 208.67.222.222
nameserver 208.67.220.220
nameserver 1.1.1.1
nameserver 1.0.0.1
nameserver 151.80.222.79
EOL
systemctl enable dhcpcd

# User configuration
passwd
useradd -m $USERNAME
usermod -a -G sudo $USERNAME
passwd $USERNAME
curl -s https://raw.githubusercontent.com/flavien-perier/linux-shell-configuration/master/linux-shell-configuration.sh | bash -

shutdown -r now