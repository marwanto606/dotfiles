# dotfiles
## installation
```
sudo apt update
sudo apt install bspwm rofi polybar picom sxhkd nm-applet feh starship thunar brightnessctl xfce4-notifyd scrot htop pavucontrol gsimplecal
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
## install aimp
`
The native Linux version of AIMP is currently in the beta stage, you can download the .deb file at https://aimp.ru/?do=download&os=linux
`
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

## chmod script
```
chmod +x ~/.config/bspwm/bspwmrc
chmod +x ~/.config/bspwm/scripts/*
chmod +x ~/.config/mprisence/mprisence.sh
chmod +x ~/.config/polybar/launch.sh
chmod +x ~/.config/rofi/powermenu.sh
```

![ricing cyber1](https://raw.githubusercontent.com/marwanto606/dotfiles/refs/heads/main/2026-09-14-12%3A25%3A08-screenshot.png)