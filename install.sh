#!/bin/bash -ex

# helper variables/functions
DOTFILES="$HOME/.local/src/dotfiles"

# create dirs
mkdir -p $HOME/.config/{nvim,mpv}
sudo mkdir -p /etc/firefox/policies/
mkdir -p $HOME/.local/bin

# clean unwanted configs
rm -rf $HOME/.bash_profile

# install stuff
sudo pacman -S --noconfirm --needed $(cat packages.txt)
sudo systemctl enable gdm
sudo systemctl enable NetworkManager --now
if lspci | grep -i nvidia; then
    sudo pacman -S --noconfirm --needed $(cat packages-desktop.txt)
fi
flatpak install -y $(cat flatpaks.txt)
uv tool install spotdl

# symlink configs
ln -sf $DOTFILES/.bashrc $HOME/.bashrc && source $HOME/.bashrc
ln -sf $DOTFILES/.profile $HOME/.profile && source $HOME/.profile
ln -sf $DOTFILES/config/nvim/init.lua $HOME/.config/nvim/init.lua
ln -sf $DOTFILES/config/mpv/mpv.conf $HOME/.config/mpv/mpv.conf
ln -sf $DOTFILES/config/mpv/input.conf $HOME/.config/mpv/input.conf
# sudo ln -sf $DOTFILES/config/firefox/policies.json /etc/firefox/policies/policies.json
sudo cp $DOTFILES/config/firefox/policies.json /etc/firefox/policies/policies.json
sudo chmod 644 /etc/firefox/policies/policies.json
cp $DOTFILES/bin/pfetch $HOME/.local/bin/pfetch

# keybinds
gsettings set org.gnome.settings-daemon.plugins.media-keys volume-up "['<Alt><Shift>k']"
gsettings set org.gnome.settings-daemon.plugins.media-keys volume-down "['<Alt><Shift>j']"
gsettings set org.gnome.settings-daemon.plugins.media-keys volume-mute "['<Alt><Shift>m']"
gsettings set org.gnome.settings-daemon.plugins.media-keys play "['<Alt><Shift>space']"
gsettings set org.gnome.settings-daemon.plugins.media-keys next "['<Alt><Shift>l']"
gsettings set org.gnome.settings-daemon.plugins.media-keys previous "['<Alt><Shift>h']"
gsettings set org.gnome.settings-daemon.plugins.media-keys media "['<Alt>m']"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name 'Launch Terminal'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command 'ptyxis --new-window'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding '<Alt>Return'
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']"
gsettings set org.gnome.desktop.wm.keybindings switch-applications "[]"
gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Alt>Tab']"
gsettings set org.gnome.desktop.wm.keybindings close "['<Alt>Delete']"
gsettings set org.gnome.desktop.wm.keybindings toggle-maximized "['<Alt>f']"

# visuals
gsettings set org.gnome.desktop.interface enable-animations false
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.background picture-uri-dark "'file://$DOTFILES/share/wallpaper.png'"
git clone https://github.com/Karmenzind/monaco-nerd-fonts /tmp/monaco-nerd-fonts || true
sudo cp -r /tmp/monaco-nerd-fonts/fonts/ /usr/share/fonts/monaco-nerd-fonts
gsettings set org.gnome.desktop.interface monospace-font-name 'Monaco Nerd Font 11'
gsettings set org.gnome.shell favorite-apps "['org.gnome.Nautilus.desktop', 'firefox.desktop', 'org.gnome.Ptyxis.desktop']"

# terminal stuff
gsettings set org.gnome.Ptyxis.Profile:/org/gnome/Ptyxis/Profiles/profile0/ palette 'Dark Pastel'
gsettings set org.gnome.Ptyxis default-profile-uuid 'profile0'
gsettings set org.gnome.Ptyxis profile-uuids "['profile0']"
gsettings set org.gnome.Ptyxis restore-window-size false
gsettings set org.gnome.Ptyxis restore-session false

# firefox
firefox --headless &
sleep 1 && pkill -9 firefox
FF_PROFILE=$(find ~/.mozilla/firefox -maxdepth 1 -type d -name "*.default-release" | head -n 1)
cp $DOTFILES/config/firefox/user.js $FF_PROFILE/user.js
curl -s -o- https://raw.githubusercontent.com/rafaelmardojai/firefox-gnome-theme/master/scripts/install-by-curl.sh | bash
