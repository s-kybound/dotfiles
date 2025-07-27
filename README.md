# skybound linux rice + utils (13/07/25)
After several years of ricing linux, I will finally document my work here, and build a proper system to make setting up my userspace EASY to do in the future. currently this is a Fedora Linux KDE spin environment.

## dependencies
- `KDE` - I use KDE because it keeps important settings like wireless network and keyboard close to me. I find it far easier at the moment to leave handling systems like that to a fully-fledged DE at the moment, though that might change in the future. It also serves as an excellent fallback if my rice ever fails.
- `kitty` - I use the default hyprland terminal.
- `hyprland` - Experimenting.
- `slurp` - For screenshots.
- `grim` - ^
- `wl-copy` - ^
- `wl-paste` - ^
- `swaylock` - For locking screen.
- `bash` - I want to change to zsh in the near future, but this works well for me.
- `stow` - To quickly symlink everything here to their spots. How did I discover this so late?
- `make` - To handle the nice makefile I have defined here.
- `wofi` - Faster than `rofi` in my experience and able to list flatpak/snap packages.

## how to use
If adding another item here, 

1. create a new stow module, naming it `<MODULE>` and storing the paths of what we want to take, pretending `<MODULE>` is `~`
1. use `make preview-add MODULE=<MODULE>` to verify the actions that will be taken, followed by `make add MODULE=<MODULE>`

If updating another item already in a module, use `make refresh MODULE=<MODULE>` or `make refreshall`.

Otherwise please use `make help` for other useful commands!
