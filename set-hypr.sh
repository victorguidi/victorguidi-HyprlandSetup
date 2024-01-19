#!/bin/bash

# Credits to SolDoesTech - https://www.youtube.com/@SolDoesTech ... I just changed a few things that I prefer
# IMPORTANT - This script is meant to run on a clean fresh Arch install on physical hardware

# Define the software that would be installed
#Need some prep work
prep_stage=(
	qt5-wayland
	qt5ct
	qt6-wayland
	qt6ct
	qt5-svg
	qt5-quickcontrols2
	qt5-graphicaleffects
	gtk3
	polkit-gnome
	pipewire
	wireplumber
	jq
	wl-clipboard
	cliphist
	python-requests
	pacman-contrib
)

#software for nvidia GPU only
nvidia_stage=(
	linux-lts-headers
	nvidia-dkms
	nvidia-settings
	libva
	libva-nvidia-driver-git
)

#the main packages
install_stage=(
	kitty
	mako
	waybar
	swww
	swaylock-effects
	rofi
	wofi
	wlogout
	xdg-desktop-portal-hyprland
	swappy
	grim
	slurp
	thunar
	btop
	mpv
	pamixer
	flatpak
	chromium
	pass
	task
	fd
	ripgrep
	exa
	zoxide
	bat
	fzf
	tokei
	keychain
	hyperfine
	tealdeer
	dmidecode
	dnsutils
	ncdu
	procs
	grex
	tealdeer
	hyperfine
	tokei
	gparted
	ntfs-3g
	ranger
	hyperfine
	grex
	xorg-xhost
	timeshift
	pavucontrol
	brightnessctl
	bluez
	bluez-utils
	blueman
	network-manager-applet
	gvfs
	thunar-archive-plugin
	file-roller
	zsh
	neofetch
	nmap
	inetutils
	papirus-icon-theme
	ttf-jetbrains-mono-nerd
	noto-fonts-cjk
	noto-fonts-emoji
	lxappearance
	tcpdump
	netcat
	traceroute
	ufw
	xdg-desktop-portal-gtk
	man-db
	xfce4-settings
	nwg-look-bin
	sddm
	hyprpicker-git
	## Back wm stuff in case of emergency
	awesome
	arandr
	xclip
	rofi-greenclip
	feh
	autorandr
	scrot
	picom
)

#software for Virtualization
virt_stage=(
	qemu-desktop
	virt-manager
	dnsmasq
	iptables-nft
)

#software for developers
developer_stage=(
	zellij
	lazygit
	docker
	docker-rootless-extras
	docker-buildx
	docker-compose
	ansible-core
	ansible
	git-lfs
	grype-bin
	syft
	sshpass
)

SKIP=true

for str in ${myArray[@]}; do
	echo $str
done

# set some colors
CNT="[\e[1;36mNOTE\e[0m]"
COK="[\e[1;32mOK\e[0m]"
CER="[\e[1;31mERROR\e[0m]"
CAT="[\e[1;37mATTENTION\e[0m]"
CWR="[\e[1;35mWARNING\e[0m]"
CAC="[\e[1;33mACTION\e[0m]"
INSTLOG="install.log"

######
# functions go here

# function that would show a progress bar to the user
show_progress() {
	while ps | grep $1 &>/dev/null; do
		echo -n "."
		sleep 2
	done
	echo -en "Done!\n"
	sleep 2
}

# function that will test for a package and if not found it will attempt to install it
install_software() {
	# First lets see if the package is there
	if yay -Q $1 &>>/dev/null; then
		echo -e "$COK - $1 is already installed."
	else
		# no package found so installing
		echo -en "$CNT - Now installing $1 ."
		yay -S --noconfirm $1 &>>$INSTLOG &
		show_progress $!
		# test to make sure package installed
		if yay -Q $1 &>>/dev/null; then
			echo -e "\e[1A\e[K$COK - $1 was installed."
		else
			# if this is hit then a package is missing, exit to review log
			echo -e "\e[1A\e[K$CER - $1 install had failed, please check the install.log"
			exit
		fi
	fi
}

# clear the screen
clear

# set some expectations for the user
echo -e "$CNT - You are about to execute a script that would attempt to setup Hyprland.
Please note that Hyprland is still in Beta."
sleep 1

# attempt to discover if this is a VM or not
echo -e "$CNT - Checking for Physical or VM..."
ISVM=$(hostnamectl | grep Chassis)
echo -e "Using $ISVM"
if [[ $ISVM == *"vm"* ]]; then
	echo -e "$CWR - Please note that VMs are not fully supported and if you try to run this on
    a Virtual Machine there is a high chance this will fail."
	sleep 1
fi

# let the user know that we will use sudo
echo -e "$CNT - This script will run some commands that require sudo. You will be prompted to enter your password.
If you are worried about entering your password then you may want to review the content of the script."
sleep 1

# give the user an option to exit out
read -rep $'[\e[1;33mACTION\e[0m] - Would you like to continue with the install (y,n) ' CONTINST
if [[ $CONTINST == "Y" || $CONTINST == "y" ]]; then
	echo -e "$CNT - Setup starting..."
	sudo touch /tmp/hyprv.tmp
else
	echo -e "$CNT - This script will now exit, no changes were made to your system."
	exit
fi

# find the Nvidia GPU
if lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq nvidia; then
	ISNVIDIA=true
else
	ISNVIDIA=false
fi

### Disable wifi powersave mode ###
read -rep $'[\e[1;33mACTION\e[0m] - Would you like to disable WiFi powersave? (y,n) ' WIFI
if [[ $WIFI == "Y" || $WIFI == "y" ]]; then
	LOC="/etc/NetworkManager/conf.d/wifi-powersave.conf"
	echo -e "$CNT - The following file has been created $LOC.\n"
	echo -e "[connection]\nwifi.powersave = 2" | sudo tee -a $LOC &>>$INSTLOG
	echo -en "$CNT - Restarting NetworkManager service, Please wait."
	sleep 2
	sudo systemctl restart NetworkManager &>>$INSTLOG

	#wait for services to restore (looking at you DNS)
	for i in {1..6}; do
		echo -n "."
		sleep 1
	done
	echo -en "Done!\n"
	sleep 2
	echo -e "\e[1A\e[K$COK - NetworkManager restart completed."
fi

#### Check for package manager ####
if [ ! -f /sbin/yay ]; then
	echo -en "$CNT - Configuering yay."
	git clone https://aur.archlinux.org/yay.git &>>$INSTLOG
	cd yay
	makepkg -si --noconfirm &>>../$INSTLOG &
	show_progress $!
	if [ -f /sbin/yay ]; then
		echo -e "\e[1A\e[K$COK - yay configured"
		cd ..

		# update the yay database
		echo -en "$CNT - Updating yay."
		yay -Suy --noconfirm &>>$INSTLOG &
		show_progress $!
		echo -e "\e[1A\e[K$COK - yay updated."
	else
		# if this is hit then a package is missing, exit to review log
		echo -e "\e[1A\e[K$CER - yay install failed, please check the install.log"
		exit
	fi
fi

### Install all of the above pacakges ####
read -rep $'[\e[1;33mACTION\e[0m] - Would you like to install the packages? (y,n) ' INST
if [[ $INST == "Y" || $INST == "y" ]]; then

	# Prep Stage - Bunch of needed items
	echo -e "$CNT - Prep Stage - Installing needed components, this may take a while..."
	for SOFTWR in ${prep_stage[@]}; do
		install_software $SOFTWR
	done

	# Setup Nvidia if it was found
	if [[ "$ISNVIDIA" == true ]]; then
		echo -e "$CNT - Nvidia GPU support setup stage, this may take a while..."
		for SOFTWR in ${nvidia_stage[@]}; do
			install_software $SOFTWR
		done

		# update config
		sudo sed -i 's/MODULES=()/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
		sudo mkinitcpio --config /etc/mkinitcpio.conf --generate /boot/initramfs-custom.img
		echo -e "options nvidia-drm modeset=1" | sudo tee -a /etc/modprobe.d/nvidia.conf &>>$INSTLOG
	fi

	# Install the correct hyprland version
	echo -e "$CNT - Installing Hyprland, this may take a while..."
	if [[ "$ISNVIDIA" == true ]]; then
		#check for hyprland and remove it so the -nvidia package can be installed
		if yay -Q hyprland &>>/dev/null; then
			yay -R --noconfirm hyprland &>>$INSTLOG &
		fi
		install_software hyprland-nvidia
	else
		install_software hyprland
	fi

	# Stage 1 - main components
	echo -e "$CNT - Installing main components, this may take a while..."
	for SOFTWR in ${install_stage[@]}; do
		install_software $SOFTWR
	done

	echo -e "$CNT - Installing dev components, this may take a while..."
	for SOFTWR in ${developer_stage[@]}; do
		install_software $SOFTWR
	done

	echo -e "$CNT - Installing ASDF for environment management"
	git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.13.1

	echo -e "$CNT - Enabling docker"
	systemctl --user enable --now docker.socket
	systemctl --user enable --now docker.service
	sudo sed -E -i 's/:[0-9]+:/:165536:/; s/:[0-9]+:/:65536:/' /etc/subuid
	sudo sed -E -i 's/:[0-9]+:/:165536:/; s/:[0-9]+:/:65536:/' /etc/subgid

	# VM stuff
	echo -e "$CNT - Configuring VM stuff (You must have KVM enabled and I assume you are using a AMD CPU, else it wont work :)"
	sudo gpasswd -a $(whoami) kvm
	echo -e "modprobe kvm_amd" | sudo tee -a /etc/modules-load.d/kvm.conf &>>$INSTLOG
	yay -S --needed qemu-desktop virt-manager dnsmasq iptables-nft
	sudo systemctl enable --now libvirtd
	sudo virsh net-autostart default
	sudo usermod -aG libvirt $USER

	# Start the bluetooth service
	echo -e "$CNT - Starting the Bluetooth Service..."
	sudo systemctl enable --now bluetooth.service &>>$INSTLOG
	sleep 2

	# Enable the sddm login manager service
	echo -e "$CNT - Enabling the SDDM Service..."
	sudo systemctl enable sddm &>>$INSTLOG
	sleep 2

	# Clean out other portals
	echo -e "$CNT - Cleaning out conflicting xdg portals..."
	yay -R --noconfirm xdg-desktop-portal-gnome xdg-desktop-portal-gtk &>>$INSTLOG
fi

### Copy Config Files ###
read -rep $'[\e[1;33mACTION\e[0m] - Would you like to copy config files? (y,n) ' CFG
if [[ $CFG == "Y" || $CFG == "y" ]]; then
	echo -e "$CNT - Copying config files..."

	# copy the configs, scripts and other to directory and zshrc
	cp -R ./configs/* ~/.config/
	cp -R ./.scripts/ ~/
	cp -R ./.bgimages/ ~/
	cp ./.zshrc ~/

	# Install Oh-my-zsd Better to do manually
	# sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	# sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
	#
	# # Adding auto completion and syntax-highlighting
	# git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
	# git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
	#
	# source $HOME/.zshrc

	# Better to do manually
	# Install Nodejs for nvim configuration and because you will probably need one day
	# asdf plugin add nodejs
	# asdf install nodejs latest
	# asdf global nodejs latest

	# add the Nvidia env file to the config (if needed)
	if [[ "$ISNVIDIA" == true ]]; then
		echo -e "\nsource = ~/.config/hypr/env_var_nvidia.conf" >>~/.config/hypr/hyprland.conf
	fi

	# Copy the SDDM theme
	echo -e "$CNT - Setting up the login screen."
	sudo cp -R ./configs/Extras/sdt /usr/share/sddm/themes/
	sudo chown -R $USER:$USER /usr/share/sddm/themes/sdt
	sudo mkdir /etc/sddm.conf.d
	echo -e "[Theme]\nCurrent=sdt" | sudo tee -a /etc/sddm.conf.d/10-theme.conf &>>$INSTLOG
	WLDIR=/usr/share/wayland-sessions
	if [ -d "$WLDIR" ]; then
		echo -e "$COK - $WLDIR found"
	else
		echo -e "$CWR - $WLDIR NOT found, creating..."
		sudo mkdir $WLDIR
	fi

	# stage the .desktop file
	sudo cp ./configs/Extras/hyprland.desktop /usr/share/wayland-sessions/

	# setup the first look and feel as dark
	xfconf-query -c xsettings -p /Net/ThemeName -s "Adwaita-dark"
	xfconf-query -c xsettings -p /Net/IconThemeName -s "Papirus-Dark"
	gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
	gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"
fi

echo -e "$CNT - Cleaning logs from timeshift backups"
sudo chattr +C /var/log
sudo chattr +C $HOME/.local/share/docker
sudo chattr +C /var/lib/libvirt

### Script is done ###
echo -e "$CNT - Script had completed!"
echo -e "Quick Reminders on Reminders.md"
if [[ "$ISNVIDIA" == true ]]; then
	echo -e "$CAT - Since we attempted to setup an Nvidia GPU the script will now end and you should reboot.
    Please type 'reboot' at the prompt and hit Enter when ready."
	exit
fi

read -rep $'[\e[1;33mACTION\e[0m] - Would you like to start Hyprland now? (y,n) ' HYP
if [[ $HYP == "Y" || $HYP == "y" ]]; then
	exec sudo systemctl start sddm &>>$INSTLOG
else
	exit
fi
