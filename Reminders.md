Check that all for the VM is working:
- sudo nvim /etc/libvirt/libvirtd.conf (Check if the socket groups ate uncommented)
- sudo nvim /etc/modules-load.d/kvm.conf (Check if the modprob is correct to the cpu)

Check if docker rootless is working:
  - Add this to your .zshrc or .bashrc -> export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock
- Check if the socket was enabled else (systemctl --user enable --now docker.service and socket)

Finish configuring ASDF:
- Add this to your .zshrc or .bashrc -> . "$HOME/.asdf/asdf.sh"

Install a browser from flatpack after reboot
  - flatpak install flathub com.brave.Browser


import to do: 
 sudo chattr +C /var/log
 sudo chattr +C /var/lib/docker
 sudo chattr +C /var/lib/libvirt

When configuring timeshift
yay -S grub-btrfs timeshift-autosnap inotify-tools
sudo systemctl edit --full grub-btrfsd
sudo systemctl enable --now grub-btrfsd

