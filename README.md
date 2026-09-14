# dotfiles
## installation
```
sudo apt install bspwm rofi polybar picom sxhkd nm-applet feh starship thunar brightnessctl
git clone https://github.com/marwanto606/dotfiles.git
cd dotfiles
cp -r .config/* ~/.config/
mkdir -p ~/Pictures/wallpapers && cp -r wallpapers/* ~/Pictures/wallpapers
```
## starship init .zshrc
```
if [[ "$TERM" != "linux" ]]; then
    eval "$(starship init zsh)"
fi
```
## install mprisence for discord
`
install mprisence repo:
https://github.com/lazykern/mprisence
`
## chmod script
```
chmod +x ~/.config/bspwm/bspwmrc
chmod +x ~/.config/mprisence/mprisence.sh
chmod +x ~/.config/polybar/launch.sh
chmod +x ~/.config/rofi/powermenu.sh
```

![ricing cyber1](https://raw.githubusercontent.com/marwanto606/dotfiles/refs/heads/main/2026-09-14-12%3A25%3A08-screenshot.png)