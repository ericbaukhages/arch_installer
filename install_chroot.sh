#!/bin/bash

# copied from: https://github.com/Phantas0s/mouseless-book-companion/blob/8d7c41e76eeea69654755b7a2fe9410a57cf7005/part_III/04_installing_tools/arch_installer/install_chroot.sh

uefi=$(cat /var_uefi)
hd=$(cat /var_hd)

cat /comp > /etc/hostname && rm /comp

pacman --noconfirm -S dialog

pacman -S --noconfirm grub

if [ "$uefi" = 1 ]; then
    pacman -S --noconfirm efibootmgr
    grub-install --target=x86_64-efi \
        --bootloader-id=GRUB \
        --efi-directory=/boot/efi
else
    grub-install "$hd"
fi

grub-mkconfig -o /boot/grub/grub.cfg

# Set hardware clock from system clock
hwclock --systohc
# Don't forget to change "Europe/Berlin" with your own timezone!
# To list the timezones: `timedatectl list-timezones`
timedatectl set-timezone "America/New_York"

# Replace en_US.UTF-8 by whatever locale you want.
# You can run `cat /etc/locale.gen` to see all the locales available
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# No argument: ask for a username.
# One argument: use the username passed as argument.
function config_user() {
    if [ -z "$1" ]; then
        dialog --no-cancel --inputbox "Please enter your username." \
            10 60 2> name
    else
        echo "$1" > name
    fi

    dialog --no-cancel --passwordbox "Enter your password." \
        10 60 2> pass1
    dialog --no-cancel --passwordbox "Confirm your password." \
        10 60 2> pass2

    while [ "$(cat pass1)" != "$(cat pass2)" ]; do
        dialog --no-cancel --passwordbox \
            "Passwords do not match.\n\nEnter password again." \
            10 60 2> pass1
        dialog --no-cancel --passwordbox \
            "Retype your password." \
            10 60 2> pass2
    done

    name=$(cat name) && rm name
    pass1=$(cat pass1) && rm pass1 pass2

    # Create user if doesn't exist
    if [[ ! "$(id -u "$name" 2> /dev/null)" ]]; then
        dialog --infobox "Adding user $name..." 4 50
        useradd -m -g wheel -s /bin/bash "$name"
    fi

    # Add password to user
    echo "$name:$pass1" | chpasswd
}

dialog --title "root password" \
    --msgbox "It's time to add a password for the root user" \
    10 60
config_user root

dialog --title "Add User" \
    --msgbox "Let's create another user." \
    10 60
config_user

# Save your username for the next script.
echo "$name" > /tmp/user_name

# Ask to install all your apps / dotfiles.
dialog --title "Continue installation" --yesno \
    "Do you want to install all your apps and your dotfiles?" \
    10 60 \
    && curl https://raw.githubusercontent.com/ericbaukhages\
    /arch_installer/main/install_apps.sh > /tmp/install_apps.sh \
    && bash /tmp/install_apps.sh
