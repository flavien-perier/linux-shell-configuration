#!/bin/sh
# Flavien PERIER <perier@flavien.io>
# Install Arch Linux base

set -e
set -x

SCRIPT_TITLE="Arch configuration"
INSTALL_DIR="/mnt"

loadkeys fr

HOSTNAME=$(whiptail --title "$SCRIPT_TITLE" --inputbox "Hostname" 10 50 3>&1 1>&2 2>&3)
USERNAME=$(whiptail --title "$SCRIPT_TITLE" --inputbox "Principal username" 10 50 3>&1 1>&2 2>&3)
DISK=$(whiptail --title "$SCRIPT_TITLE" --inputbox "Disk used for install" 10 50 3>&1 1>&2 2>&3)

parted --script $DISK mklabel gpt
parted --script $DISK mkpart primary 1MiB 501MiB
parted --script $DISK mkpart primary 501MiB 4501Mib
parted --script $DISK mkpart primary 4501Mib 100%

ip link
timedatectl set-ntp true

mkfs.fat -F32 ${DISK}1
mkswap ${DISK}2
mkfs.ext4 ${DISK}3

swapon ${DISK}2
mount ${DISK}3 $INSTALL_DIR

pacstrap $INSTALL_DIR base linux linux-firmware grub systemd dhcpcd sudo pacman flatpak

echo "$HOSTNAME" > $INSTALL_DIR/etc/hostname

# Local configuration
echo "fr_FR.UTF-8 UTF-8" > $INSTALL_DIR/etc/locale.gen
echo "LANG=fr_FR.UTF-8" > $INSTALL_DIR/etc/locale.conf
echo "KEYMAP=fr" > $INSTALL_DIR/etc/vconsole.conf
arch-chroot $INSTALL_DIR ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
arch-chroot $INSTALL_DIR hwclock --systohc
arch-chroot $INSTALL_DIR locale-gen

# Network configuration
cat << EOL > $INSTALL_DIR/etc/hosts
127.0.0.1 localhost
::1       localhost
EOL
cat << EOL > $INSTALL_DIR/etc/resolv.conf
nameserver 208.67.222.222
nameserver 208.67.220.220
nameserver 1.1.1.1
nameserver 1.0.0.1
nameserver 151.80.222.79
EOL
arch-chroot $INSTALL_DIR systemctl enable dhcpcd

# Fstab configuration
genfstab -U $INSTALL_DIR >> $INSTALL_DIR/etc/fstab

# Sudo configuration
echo "%sudo	ALL=(ALL:ALL) ALL" >> $INSTALL_DIR/etc/sudoers
arch-chroot $INSTALL_DIR groupadd sudo

# User configuration
arch-chroot $INSTALL_DIR useradd -m $USERNAME
arch-chroot $INSTALL_DIR usermod -a -G sudo $USERNAME
curl -s https://raw.githubusercontent.com/flavien-perier/linux-configuration/master/shell-configuration.sh \
    | arch-chroot $INSTALL_DIR bash -

# Grub installation
arch-chroot $INSTALL_DIR mkdir /boot/efi
arch-chroot $INSTALL_DIR mount ${DISK}1 /boot/efi
arch-chroot $INSTALL_DIR grub-install ${DISK} --target=i386-pc --root-directory=$INSTALL_DIR
arch-chroot $INSTALL_DIR grub-mkconfig -o /boot/grub/grub.cfg
