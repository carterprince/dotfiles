#!/bin/bash -ex

# helper variables/functions
DOTFILES="$HOME/.local/src/dotfiles"

# create dirs
mkdir -p $HOME/.config/{nvim,mpv}
sudo mkdir -p /etc/firefox/policies/
mkdir -p $HOME/.local/bin

# clean unwanted configs
mv $HOME/.bash_profile $HOME/.bash_profile.bak || true
mv $HOME/.bashrc $HOME/.bashrc.bak || true

# install stuff
sudo pacman -Syyu --noconfirm --needed $(cat $DOTFILES/packages.txt)
sudo pacman -R --noconfirm epiphany || true
sudo systemctl enable gdm
sudo systemctl enable NetworkManager --now
if lspci | grep -i nvidia; then
    sudo pacman -S --noconfirm --needed $(cat $DOTFILES/packages-desktop.txt)
fi
flatpak install -y $(cat $DOTFILES/flatpaks.txt)
uv tool install spotdl

# symlink configs
ln -sf $DOTFILES/.bashrc $HOME/.bashrc
ln -sf $DOTFILES/.profile $HOME/.profile
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
# sudo fc-cache -fv
gsettings set org.gnome.desktop.interface monospace-font-name 'Monaco Nerd Font 11'
gsettings set org.gnome.shell favorite-apps "['org.gnome.Nautilus.desktop', 'firefox.desktop', 'org.gnome.Ptyxis.desktop']"

# terminal
gsettings set org.gnome.Ptyxis.Profile:/org/gnome/Ptyxis/Profiles/profile0/ palette 'Dark Pastel'
gsettings set org.gnome.Ptyxis default-profile-uuid 'profile0'
gsettings set org.gnome.Ptyxis profile-uuids "['profile0']"
gsettings set org.gnome.Ptyxis restore-window-size false
gsettings set org.gnome.Ptyxis restore-session false
mkdir -p $HOME/.local/share/icons/
wget -O $HOME/.local/share/icons/org.gnome.Console.svg "https://gitlab.gnome.org/GNOME/console/-/raw/main/data/org.gnome.Console.svg?ref_type=heads&inline=false"
sudo sed -i 's/Icon=org.gnome.Ptyxis/Icon=org.gnome.Console/' /usr/share/applications/org.gnome.Ptyxis.desktop
sudo sed -i 's/Name=Ptyxis/Name=Terminal/' /usr/share/applications/org.gnome.Ptyxis.desktop

# music player
flatpak run --command='gsettings' com.github.neithern.g4music set com.github.neithern.g4music blur-mode 0
flatpak run --command='gsettings' com.github.neithern.g4music set com.github.neithern.g4music gapless-playback false
flatpak run --command='gsettings' com.github.neithern.g4music set com.github.neithern.g4music rotate-cover false
flatpak run --command='gsettings' com.github.neithern.g4music set com.github.neithern.g4music show-peak false
flatpak run --command='gsettings' com.github.neithern.g4music set com.github.neithern.g4music sort-mode 5
flatpak run --command='gsettings' com.github.neithern.g4music set com.github.neithern.g4music rotate-cover false
# flatpak run --command='gsettings' com.github.neithern.g4music set com.github.neithern.g4music pitch-correction false
# flatpak run --command='gsettings' com.github.neithern.g4music set com.github.neithern.g4music playback-speed 1.10

# firefox
timeout 1s firefox --headless 2>/dev/null || true
FF_PROFILE=$(find $HOME/.mozilla/firefox -maxdepth 1 -type d -name "*.default-release" | head -n 1)
curl -s -o- https://raw.githubusercontent.com/rafaelmardojai/firefox-gnome-theme/master/scripts/install-by-curl.sh | bash
cp $DOTFILES/config/firefox/user.js $FF_PROFILE/user.js
