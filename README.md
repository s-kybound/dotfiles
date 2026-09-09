# skybound linux rice + utils (09/09/26)
After several years of ricing linux, I will finally document my work here, and build a proper system to make setting up my userspace EASY to do in the future. currently this is a non/guix environment (`system-config.scm`, `home-config.scm`), with a NixOS twin for the work box in `.nixos/` (`/etc/nixos` symlinks there; `sudo nixos-rebuild switch` as usual).

User-level configs (`niri`, `foot`, `wireplumber`, ...) live in per-module dirs shared by both; dirs prefixed with `_` (`_shell`, `_nvim`, `_tmux`) are deprecated and not deployed; `home-config.scm` (guix home) and `.nixos/home.nix` (home-manager) deploy them on every rebuild.

## dependencies
- `foot` - nice and light
- `niri` - looks nice
- `noctalia` - ^
- `zsh` - For a nice terminal experience.
- `neovim` - I used to use Emacs, and couldn't handle coming back to default vim.
- `emacs` - sike. lets try both?
- `daikichi` + `cowsay` + `neofetch` - for fun terminal greetings.

