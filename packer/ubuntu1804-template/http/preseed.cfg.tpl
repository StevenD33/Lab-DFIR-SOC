# To see all available options execute this command once the install is done:
# sudo less /var/log/installer/cdebconf/questions.dat
# If you need information about an option use the command below (example for keymap):
# grep -A 4 "keyboard-configuration/xkb-keymap" /var/log/installer/cdebconf/templates.dat

# Use network mirror for package installation
# d-i apt-setup/use_mirror boolean true

# Automatic installation
d-i auto-install/enable boolean true

# "linux-server" is substituted by "linux-image-amd64"
# Possible options : "linux-image-amd64"(default) or "linux-image-rt-amd64"
d-i base-installer/kernel/override-image string linux-server

# Configure hardware clock
d-i clock-setup/utc boolean true
d-i clock-setup/utc-auto boolean true

# d-i console-setup/ask_detect boolean false

# d-i debconf/frontend select noninteractive

# Set OS locale
d-i debian-installer/language string en
d-i debian-installer/country string FR
d-i debian-installer/locale string en_US.UTF-8

# d-i debian-installer/framebuffer boolean false

# Reboot once the install is done
d-i finish-install/reboot_in_progress note

# Bootloader options
d-i grub-installer/only_debian boolean true
d-i grub-installer/with_other_os boolean true
d-i grub-installer/bootdev string /dev/sda

# Set the keyboard layout
d-i keyboard-configuration/xkb-keymap select fr(latin9)

# Configure http proxy if needed "http://[[user][:pass]@]host[:port]/"
d-i mirror/http/proxy string

# Set the hostname and DNS suffix
d-i netcfg/get_hostname string template-ubuntu
d-i netcfg/get_domain string localdomain

# Disk configuration
d-i partman-auto-lvm/guided_size string max
d-i partman-auto/choose_recipe select atomic
d-i partman-auto/method string lvm
d-i partman-lvm/confirm boolean true
d-i partman-lvm/confirm_nooverwrite boolean true
d-i partman-lvm/device_remove_lvm boolean true
d-i partman/choose_partition select finish
d-i partman/confirm boolean true
d-i partman/confirm_nooverwrite boolean true
d-i partman/confirm_write_new_label boolean true

# User configuration
d-i passwd/root-login boolean true
d-i passwd/root-password-again password Analyste
d-i passwd/root-password password Analyste
d-i passwd/user-fullname string analyste
d-i passwd/user-uid string 1000
d-i passwd/user-password password Analyste
d-i passwd/user-password-again password Analyste
d-i passwd/username string analyste

# Extra packages to be installed
d-i pkgsel/include string sudo openssh-server ntp curl nfs-common linux-headers-$(uname -r) build-essential perl dkms
d-i pkgsel/install-language-support boolean false

d-i pkgsel/install-language-support boolean false
d-i pkgsel/update-policy select none

# Whether to upgrade packages after debootstrap
d-i pkgsel/upgrade select full-upgrade

# Set timezone
d-i time/zone string Europe/Paris

# Allow weak user password
d-i user-setup/allow-password-weak boolean true

# Home folder encryption
d-i user-setup/encrypt-home boolean false

# Do not scan additional CDs
apt-cdrom-setup apt-setup/cdrom/set-first boolean false

# Use network mirror
apt-mirror-setup apt-setup/use_mirror boolean true

# Disable polularity contest
popularity-contest popularity-contest/participate boolean false

# Select base install
tasksel tasksel/first multiselect ubuntu-desktop
d-i pkgsel/include string ca-certificates openssh-server

# Setup passwordless sudo for packer user
d-i preseed/late_command string \
in-target sh -c 'echo "analyste ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/analyste ; chmod 0440 /etc/sudoers.d/analyste ;'
