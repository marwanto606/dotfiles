# dotfiles
## installation
```
sudo apt update
sudo apt install bspwm rofi polybar picom sxhkd network-manager-applet feh starship thunar brightnessctl xfce4-notifyd scrot htop pavucontrol gsimplecal simplescreenrecorder kitty betterlockscreen vnstat
sudo apt install x11-utils xdotool playerctl
git clone https://github.com/marwanto606/dotfiles.git
cd dotfiles
cp -r .config/* ~/.config/
mkdir -p ~/Pictures/wallpapers && cp -r wallpapers/* ~/Pictures/wallpapers
betterlockscreen -u ~/Pictures/wallpapers/
sudo systemctl enable --now vnstat
```
## install snixembed
```
# snixembed untuk abdm di polybar systemtray
sudo apt update
sudo apt install libdbusmenu-gtk3-4 libayatana-appindicator3-1
mkdir -p ~/.local/bin
cp -r .local/bin/* ~/.local/bin/
chmod +x ~/.local/bin/snixembed
chmod +x ~/.local/bin/rxfetch
```

## fix xfce4-notifyd yang tiba-tiba tidak jalan
```
# Buat symlink xfce4-notifyd
ln -s /usr/lib/x86_64-linux-gnu/xfce4/notifyd/xfce4-notifyd ~/.local/bin/xfce4-notifyd
```
## install zsh, autosuggestions, syntax highlighting for shell
```
sudo apt install zsh zsh-autosuggestions zsh-syntax-highlighting -y
chsh -s $(which zsh)
# sample .zshrc on repo copy to ~/.zshrc
# logout and login again
```
## sample starship init .zshrc
```
if [[ "$TERM" != "linux" ]]; then
    eval "$(starship init zsh)"
fi
```
## install zed
```
curl -f https://zed.dev/install.sh | sh
```
## install aimp
`
The native version of AIMP for Linux is currently in the beta stage, you can download the .deb file from https://aimp.ru/?do=download&os=linux or install the application aimp_6.00.3083~beta6-1_amd64.deb, which remains compatible with bspwm.
`
```
sudo apt install ./aimp_6.00.3083\~beta6-1_amd64.deb
```

## install mprisence for discord
`
install mprisence in the repository: https://github.com/lazykern/mprisence
`
## disable starup mprisence
```
systemctl --user disable mprisence.service
systemctl --user stop mprisence.service
```
## install fonts
```
sudo apt update
sudo apt install fonts-jetbrains-mono fonts-font-awesome
mkdir -p ~/.local/share/fonts
cp -r fonts/* ~/.local/share/fonts/
fc-cache -fv
```
`If the Font Awesome version obtained via 'apt' is outdated, you must install it manually by downloading Font Awesome 6 from https://github.com/FortAwesome/Font-Awesome/releases/tag/6.7.2`
## install icon and cache (old config icon)
```
sudo apt install -y papirus-icon-theme
sudo gtk-update-icon-cache -f /usr/share/icons/Papirus
sudo gtk-update-icon-cache -f /usr/share/icons/Papirus-Dark
```
## install icon and gtk theme 
```
# Layan gtk theme
git clone --depth=1 https://github.com/vinceliuice/Layan-gtk-theme
cd Layan-gtk-theme
./install.sh

# WhiteSur icon theme
git clone --depth=1 https://github.com/vinceliuice/WhiteSur-icon-theme
cd WhiteSur-icon-theme
./install.sh -a -b
```
## rofi reload cache
```
rofi -show drun -drun-reload-desktop-cache
```
## cursor
```
mkdir -p ~/.icons
cp -r .icons/* ~/.icons/
cd ~/.icons
tar -xvf Future-cyan-cursors.tar.gz
```

## chmod script
```
chmod +x ~/.config/bspwm/bspwmrc
chmod +x ~/.config/bspwm/external_rules
chmod +x ~/.config/bspwm/scripts/*.sh
chmod +x ~/.config/mprisence/mprisence.sh
chmod +x ~/.config/polybar/launch.sh
chmod +x ~/.config/polybar/scripts/*.sh
chmod +x ~/.config/rofi/*.sh
```
## install glava
```
chmod +x glava.sh
# to install glava
./glava.sh install

# to copy example config glava
glava --copy-config

# to copy my dotfiles glava config
cp -r .config/glava/* ~/.config/glava/

# to change glava resolution, it is also available at bspwmrc, just uncomment it on this code 
#if echo "$WIDTH" | grep -Eq '^[0-9]+$' && echo "$HEIGHT" | grep -Eq '^[0-9]+$'; then 
#    sed -i "s/#request setgeometry .*/#request setgeometry 0 0 $WIDTH $HEIGHT/" "$HOME/.config/glava/rc.glsl" 
#fi

# to uninstall glava
./glava.sh uninstall
```
## install unimatrix
```
curl -L https://raw.githubusercontent.com/will8211/unimatrix/master/unimatrix.py -o ~/.local/bin/unimatrix
chmod a+rx ~/.local/bin/unimatrix

# sample my command
unimatrix -b -s 96 -l cCgGkmnopPrRsS -a -o -f -c magenta
```

## live wallpaper mp4 mpv + xwinwrap
```
# install mpv
sudo apt install mpv

#install xwinwrap
# 1. Pastikan folder ~/.local/bin sudah ada
mkdir -p ~/.local/bin

# 2. Download binary xwinwrap (versi rilis yang stabil & umum digunakan)
curl -L -o ~/.local/bin/xwinwrap https://github.com/mmhobi7/xwinwrap/releases/download/v0.9/xwinwrap

# 3. Beri izin eksekusi (chmod +x)
chmod +x ~/.local/bin/xwinwrap

# add 'live' on script execute workspace-wallpaper.sh on bspwmrc
# ~/.config /bspwm/scripts/workspace-wallpaper.sh live &
```

![ricing cyber1](https://raw.githubusercontent.com/marwanto606/dotfiles/refs/heads/main/2026-10-16-10-08-31-screenshot.png)
