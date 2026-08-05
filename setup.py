#!/usr/bin/env python3
from util import HOME, sh, cap, ok, cfg

sh("sudo -v")

# helper variables
DOTFILES = HOME + "/.local/src/dotfiles"

# create dirs
sh("mkdir -p $HOME/.local/share/icons")

# clean unwanted configs
sh('mv -n "$HOME/.bash_profile" "$HOME/.bash_profile.bak" || true')
sh('mv -n "$HOME/.bashrc" "$HOME/.bashrc.bak" || true')

# load config
distro = cap('grep "^ID=" /etc/os-release | cut -d= -f2').strip('"')
config = cfg("config.json")
packages = config["packages"]
is_desktop = ok("lspci | grep -i nvidia")

# install packages
distro_packages = " ".join(
    pkg
    for p in packages
    if distro in p and (not p.get("desktop") or is_desktop)
    for pkg in ([p[distro]] if isinstance(p[distro], str) else p[distro])
)
flatpaks = " ".join(p["flatpak"] for p in packages if "flatpak" in p)

if distro == "arch":
    sh(r'sudo sed -i "/\[multilib\]/,/Include/ s/^#//" /etc/pacman.conf')
    sh(f"sudo pacman -Syyu --noconfirm --needed {distro_packages}")
    sh("sudo pacman -R --noconfirm epiphany || true")
    sh("sudo pkgfile --update")
elif distro == "fedora":
    sh("flatpak remote-delete fedora --force || true")
    sh(f"sudo dnf install -y {distro_packages}")

sh("flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo")
sh(f"flatpak install -y {flatpaks}")

# python/uv tools
tools = [p["uv"] for p in packages if "uv" in p]
for tool in tools:
    sh(f"uv tool install {tool}")

sh("sudo systemctl enable gdm")
sh("sudo systemctl enable NetworkManager --now")

# symlink configs
for link in config["links"]:
    src = DOTFILES + "/" + link["src"]
    dst = link["dst"].replace("~", HOME)
    if link.get("sudo"):
        sh(f'sudo mkdir -p $(dirname "{dst}")')
        sh(f"sudo ln -sf {src} {dst}")
    else:
        sh(f'mkdir -p $(dirname "{dst}")')
        sh(f"ln -sf {src} {dst}")
sh("sudo chmod 644 /etc/firefox/policies/policies.json")

# gsettings
for schema, settings in config["gsettings"].items():
    for key, val in settings.items():
        sh(f'gsettings set {schema} {key} "{val}"')

# mime stuff
for mimetype, app in config["associations"].items():
    sh(f"xdg-mime default {app} {mimetype}")

# this seems to be broken right now
# for ext in config["extensions"]:
#     sh(f"""gdbus call --session --dest org.gnome.Shell.Extensions --object-path /org/gnome/Shell/Extensions --method org.gnome.Shell.Extensions.InstallRemoteExtension "{ext}" """)

# custom keybindings
keybindings = config["keybindings"]
for i, kb in enumerate(keybindings):
    path = f"org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom{i}/"
    sh(f'gsettings set {path} name "{kb["name"]}"')
    sh(f'gsettings set {path} command "{kb["command"]}"')
    sh(f'gsettings set {path} binding "{kb["binding"]}"')
kb_paths = "[" + ", ".join(
    f"'/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom{i}/'"
    for i in range(len(keybindings))
) + "]"
sh(f'gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "{kb_paths}"')

# caps lock -> escape
sh("gsettings set org.gnome.desktop.input-sources xkb-options \"['caps:escape']\"")

# visuals
sh("git clone https://github.com/Karmenzind/monaco-nerd-fonts /tmp/monaco-nerd-fonts || true")
sh("sudo cp -r /tmp/monaco-nerd-fonts/fonts/ /usr/share/fonts/monaco-nerd-fonts")
sh("sudo fc-cache -fv > /dev/null")
if distro != "fedora":
    sh('wget -O $HOME/.local/share/icons/org.gnome.Console.svg "https://gitlab.gnome.org/GNOME/console/-/raw/main/data/org.gnome.Console.svg?ref_type=heads&inline=false"')
    sh("sudo sed -i 's/Icon=org.gnome.Ptyxis/Icon=org.gnome.Console/' /usr/share/applications/org.gnome.Ptyxis.desktop")
    sh("sudo sed -i 's/Name=Ptyxis/Name=Terminal/' /usr/share/applications/org.gnome.Ptyxis.desktop")

# set monitor scale
monitor = cap("gdctl show | awk '/Monitor /{print $2; exit}'")
res = cap("gdctl show | grep -A1 'Current mode' | grep -oE '[0-9]+x[0-9]+' | head -n1")
mode = cap(f"gdctl show --modes | grep -oE '{res}@[0-9.]+' | sort -t@ -k2 -rn | head -n1")
print(mode)
width = int(res.split('x')[0])
scale = 2 if width >= 3840 else 1.2
sh(f"gdctl set --persistent --logical-monitor --primary --monitor {monitor} --mode {mode} --scale {scale}")

# firefox
sh("timeout 1s firefox --headless 2>/dev/null || true")
FF_PROFILE = cap('find $HOME/.config/mozilla/firefox -maxdepth 1 -type d -name "*.default-release" | head -n 1')
print("FF_PROFILE:", FF_PROFILE)
sh("curl -s -o- https://raw.githubusercontent.com/rafaelmardojai/firefox-gnome-theme/master/scripts/install-by-curl.sh | bash")
if FF_PROFILE:
    sh(f"cp {DOTFILES}/config/firefox/user.js {FF_PROFILE}/user.js")
    sh(f"mkdir -p {FF_PROFILE}/chrome")
    sh(f"cp {DOTFILES}/config/firefox/userChrome.css {FF_PROFILE}/chrome/userChrome.css")

# clean random junk
sh("sudo rm -f /usr/share/applications/{avahi-discover,bssh,bvnc,qvidcap,qv4l2,*openjdk,electron*}.desktop")
