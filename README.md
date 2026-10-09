# dotfiles
## installation
```
sudo apt update
sudo apt install bspwm rofi polybar picom sxhkd network-manager-applet feh starship thunar brightnessctl xfce4-notifyd scrot htop pavucontrol gsimplecal simplescreenrecorder kitty
git clone https://github.com/marwanto606/dotfiles.git
cd dotfiles
cp -r .config/* ~/.config/
mkdir -p ~/Pictures/wallpapers && cp -r wallpapers/* ~/Pictures/wallpapers
```
## install snixembed
```
# snixembed untuk abdm di polybar systemtray
sudo apt update
sudo apt install libdbusmenu-gtk3-4 libayatana-appindicator3-1
mkdir -p ~/.local/bin
cp -r .local/bin/snixembed ~/.local/bin/
chmod +x ~/.local/bin/snixembed
```
## starship init .zshrc
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
## install icon and cache
```
sudo apt install -y papirus-icon-theme
sudo gtk-update-icon-cache -f /usr/share/icons/Papirus
sudo gtk-update-icon-cache -f /usr/share/icons/Papirus-Dark
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
chmod +x ~/.config/bspwm/scripts/*
chmod +x ~/.config/mprisence/mprisence.sh
chmod +x ~/.config/polybar/launch.sh
chmod +x ~/.config/rofi/powermenu.sh
```

![ricing cyber1](https://raw.githubusercontent.com/marwanto606/dotfiles/refs/heads/main/2026-10-04-10-52-40-screenshot.png)