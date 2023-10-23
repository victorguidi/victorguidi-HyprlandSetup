Check that all for the VM is working:
- sudo nvim /etc/libvirt/libvirtd.conf (Check if the socket groups ate uncommented)
- sudo nvim /etc/modules-load.d/kvm.conf (Check if the modprob is correct to the cpu)

Check if docker rootless is working:
  - Add this to your .zshrc or .bashrc -> export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock
  - Check if the socket was enabled else (systemctl --user enable --now docker.service and socket)
  - sudo nvim /etc/subuid -> change to [USER]:165536:65536
  - sudo nvim /etc/subgid -> change to [USER]:165536:65536

Finish configuring ASDF:
- Add this to your .zshrc or .bashrc -> . "$HOME/.asdf/asdf.sh"

Install a browser from flatpack after reboot
  - flatpak install flathub com.brave.Browser


important to do otherwise btrfs will take snapshots of this too: 
 - sudo chattr +C /var/log
 - sudo chattr +C /var/lib/docker
 - sudo chattr +C /var/lib/libvirt

When configuring the Zsh shell:
  - git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
  - git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

When configuring timeshift:
  - yay -S grub-btrfs timeshift-autosnap inotify-tools
  - sudo systemctl edit --full grub-btrfsd
  - sudo systemctl enable --now grub-btrfsd

