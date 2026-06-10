# Arch Linux + Hyprland Setup

An opinionated bootstrap repository for turning a fresh Arch Linux installation into a Hyprland-based desktop and development workstation.

The installer updates the system, installs packages from the official repositories and the AUR, enables core services, applies a keyboard remap, changes the login shell to Zsh, and checks out a separate bare dotfiles repository into the user's home directory.

> [!WARNING]
> This is a personal setup, not a general-purpose Arch installer. Read [Personal defaults and side effects](#personal-defaults-and-side-effects) before running it. In particular, it installs `git@github.com:jairorua/dotfiles.git` by default and sets the keyboard layout to Spanish.

## What this repository contains

| File | Purpose |
| --- | --- |
| `install.sh` | Main package and system configuration installer. |
| `install_dotfiles.sh` | Installs a bare Git dotfiles repository with `$HOME` as its work tree. |
| `wallpaper1.jpg`, `wallpaper2.jpg` | Wallpapers supplied with the setup. The scripts do not copy or configure them automatically. |

The Hyprland, Waybar, Rofi, SwayNC, Ghostty, Neovim, tmux, Zsh, and related application configurations are **not stored in this repository**. They come from the dotfiles repository selected with `DOTFILES_REPO`.

## Software included

### Desktop and Hyprland

| Package | Reason |
| --- | --- |
| `hyprland` | Wayland tiling compositor and the main desktop session. |
| `hyprpaper` | Wallpaper daemon for Hyprland. |
| `hyprlock` | Hyprland-native screen locker. |
| `hypridle` | Idle management, such as locking the screen and turning displays off. |
| `waybar` | Status bar for workspaces, system state, and tray applications. |
| `rofi-wayland` | Wayland application launcher and menu. |
| `swaync` | Notification daemon and notification center. |
| `sddm` | Graphical login and session manager. It is installed but not enabled by the script. |
| `polkit-gnome` | Graphical authentication agent for privileged desktop actions. |
| `xdg-desktop-portal-hyprland`, `xdg-desktop-portal-gtk` | Desktop portals for screen sharing, file pickers, and sandboxed applications. |
| `qt5-wayland`, `qt6-wayland` | Native Wayland support for Qt applications. |
| `qt5ct`, `qt6ct`, `nwg-look` | Qt and GTK appearance configuration. |
| `hyprshot`, `grim`, `slurp`, `grimblast` | Full-screen, window, and region screenshot tools. |
| `hyprpicker` | On-screen color picker. |
| `wlogout` | Wayland logout, reboot, shutdown, and lock menu. |

### Desktop applications

| Package | Reason |
| --- | --- |
| `ghostty` | GPU-accelerated terminal emulator. |
| `brave-bin` | Brave web browser, installed from the AUR. |
| `thunar`, `thunar-archive-plugin` | Graphical file manager with archive integration. |
| `tumbler`, `ffmpegthumbnailer` | File and video thumbnails in Thunar. |
| `zathura`, `zathura-pdf-mupdf` | Keyboard-oriented PDF reader with the MuPDF backend. |
| `imv` | Minimal Wayland-friendly image viewer. |
| `vlc` | General-purpose video and audio player. |
| `obs-studio` | Screen recording and streaming. |
| `obsidian` | Markdown knowledge-base and note-taking application. |
| `signal-desktop` | Signal messaging client. |
| `spotify-launcher` | Downloads and launches the Spotify Linux client. |
| `pavucontrol`, `pamixer` | Graphical and command-line audio controls. |
| `blueman` | Graphical Bluetooth manager and tray applet. |
| `network-manager-applet` | NetworkManager tray applet. |
| `pcloud-drive` | pCloud desktop drive client, installed from the AUR. |
| `cryptomator` | Client-side encrypted vaults for cloud storage, installed from the AUR. |

### Audio, network, and system integration

| Package | Reason |
| --- | --- |
| `pipewire`, `pipewire-pulse`, `pipewire-jack`, `pipewire-alsa` | PipeWire audio with PulseAudio, JACK, and ALSA compatibility. |
| `wireplumber` | PipeWire session and policy manager. |
| `bluez`, `bluez-utils` | Bluetooth stack and command-line tools. |
| `openssh` | SSH client/server tools and Git-over-SSH support. |
| `ufw` | Firewall management. Installed, but no rules are added and the service is not enabled. |
| `tailscale` | Tailscale VPN client. Installed, but the service is not enabled and no account is connected. |
| `udisks2`, `gvfs` | Desktop mounting and access for removable disks and remote locations. |
| `xdg-user-dirs` | Creates standard directories such as Documents, Downloads, and Pictures. |
| `fuse2`, `fuse3` | Userspace filesystem support, used by AppImages and mounted applications. |
| `socat`, `lsof`, `pciutils` | Socket relay, open-file inspection, and PCI/GPU inspection tools. |

### Shell and command-line tools

| Package | Reason |
| --- | --- |
| `zsh` | Interactive shell; the installer attempts to make it the current user's default. |
| `starship` | Cross-shell prompt. |
| `tmux` | Terminal multiplexer; TPM is installed by the dotfiles script. |
| `neovim` | Terminal editor; the dotfiles script attempts a headless Lazy plugin sync. |
| `ripgrep`, `fd`, `fzf` | Fast text search, file search, and fuzzy selection. |
| `bat`, `eza`, `tree` | Improved file display and directory listing tools. |
| `tldr` | Concise command examples. |
| `btop` | Interactive system monitor. |
| `yazi` | Terminal file manager. |
| `zoxide` | Frecency-based directory navigation. |
| `wl-clipboard`, `cliphist` | Wayland clipboard commands and clipboard history. |
| `p7zip`, `unzip` | Archive extraction and creation. |
| `rsync`, `wget`, `curl` | File synchronization and downloads. |
| `reflector`, `pacman-contrib` | Arch mirror management and additional pacman utilities. |
| `git-delta` | Syntax-highlighted Git diff pager. |
| `opencode` | Terminal AI coding assistant. |

### Development tools

| Package | Reason |
| --- | --- |
| `base-devel`, `gcc`, `gdb` | Build toolchain, compiler, debugger, and prerequisites for AUR packages. |
| `go` | Go compiler and tooling. |
| `python`, `python-pip`, `uv`, `python-pynvim` | Python runtime, package tooling, and Neovim integration. |
| `nodejs`, `npm`, `pnpm`, `typescript` | JavaScript and TypeScript runtime and package tooling. |
| `nvm` | Per-user Node.js version manager, installed from the AUR. |
| `lua` | Lua runtime, commonly used by Neovim configuration. |
| `tree-sitter`, `tree-sitter-cli` | Parser tooling used by editors; the CLI is also installed globally with npm. |
| `meson`, `ninja`, `cmake` | Common native build systems. |
| `sqlite` | Embedded SQL database and command-line client. |

### Fonts and icons

| Package | Reason |
| --- | --- |
| `noto-fonts` | Broad Unicode text coverage. |
| `noto-fonts-cjk` | Chinese, Japanese, and Korean character coverage. |
| `noto-fonts-emoji` | Color emoji support. |
| `ttf-jetbrains-mono` | Monospaced programming font. |
| `ttf-jetbrains-mono-nerd` | JetBrains Mono patched with icons for Waybar, prompts, and Neovim. |
| `ttf-liberation` | Metric-compatible alternatives to common Microsoft fonts. |
| `ttf-dejavu` | General-purpose serif, sans-serif, and monospace fonts. |
| `ttf-font-awesome` | Icon glyphs used by desktop and status-bar configurations. |
| `papirus-icon-theme` | Desktop application and file icons. |

## Fresh Arch prerequisites

Start from a bootable Arch Linux system with:

- A non-root user in the `wheel` group.
- Working `sudo` access for that user.
- A working internet connection.
- `git` and `NetworkManager` installed.
- The kernel and graphics firmware/driver appropriate for the machine.

For example, during the base installation:

```bash
pacstrap -K /mnt base base-devel linux linux-firmware networkmanager git sudo
```

Complete the normal Arch installation first: generate `fstab`, configure time zone and locale, set up the bootloader, create the user, and allow the `wheel` group to use sudo. Refer to the [official Arch installation guide](https://wiki.archlinux.org/title/Installation_guide) for those steps.

After booting the installed system, make sure networking is available:

```bash
sudo systemctl enable --now NetworkManager
```

## Installation

Run the setup as the intended desktop user, **not** as root and not with `sudo ./install.sh`:

```bash
git clone https://github.com/jairorua/arch-hyprland-setup.git
cd arch-hyprland-setup
chmod +x install.sh install_dotfiles.sh
./install.sh
```

The script will:

1. Confirm that the operating system identifies itself as Arch Linux and that the user has sudo access.
2. Detect an NVIDIA GPU and optionally install `nvidia-dkms`, `nvidia-utils`, and `nvidia-settings`.
3. Build and install the `yay` AUR helper in `~/.cache/yay` if it is missing.
4. Run a full `pacman -Syu`, install all official packages, and install the AUR packages with `yay`.
5. Enable and start `bluetooth.service` and `NetworkManager.service`.
6. Set the keyboard layout/remap, add the user to desktop-related groups, install global npm integrations, set Zsh as the login shell, and create XDG user directories.
7. Run `install_dotfiles.sh` and attempt to install tmux and Neovim plugins.

Package installation uses `--noconfirm`, but the script may still ask for the sudo password, NVIDIA confirmation, a password for `chsh`, and confirmation when an existing dotfiles repository is found.

`hyprshot` appears in both the official-package and AUR lists. Once it has been installed from the official repository, yay should skip reinstalling it because the AUR command uses `--needed`.

### Use a different dotfiles repository

The default is `git@github.com:jairorua/dotfiles.git`. Override it for another bare-dotfiles-compatible repository:

```bash
DOTFILES_REPO=https://github.com/YOUR_USER/dotfiles.git ./install.sh
```

The dotfiles installer clones the repository as a bare repository at `~/.dotfiles` and checks it out with `$HOME` as the work tree. Existing files that Git reports as checkout conflicts are renamed with a `.backup.TIMESTAMP` suffix.

> [!CAUTION]
> If `~/.dotfiles` already exists and you approve the update prompt, the script runs `git reset --hard origin/main` (or `origin/master`) inside that bare repository. Commit or back up dotfile changes first.

The dotfiles setup can also be rerun independently:

```bash
DOTFILES_REPO=https://github.com/YOUR_USER/dotfiles.git ./install_dotfiles.sh
```

## Personal defaults and side effects

- The script runs a full system upgrade and installs every listed package without per-package confirmation.
- `localectl set-x11-keymap es "" "" ctrl:nocaps` selects the **Spanish keyboard layout** and maps Caps Lock to Ctrl. Edit `setup_keyboard()` in `install.sh` before running if that is not wanted.
- The user is added to `video`, `audio`, `lp`, `input`, `network`, and `storage`; group membership is applied after logging out or rebooting.
- `sudo npm install -g neovim tree-sitter-cli` installs global npm packages system-wide.
- The login shell is changed to Zsh with `chsh`.
- The AUR is community maintained. Review AUR package build files when using this outside a trusted personal setup.
- There is no rollback or uninstall script.

## After installation

Enable the graphical login manager if SDDM is desired:

```bash
sudo systemctl enable sddm
```

Then reboot:

```bash
reboot
```

At SDDM, select the Hyprland session. Without SDDM, log in on a TTY and run:

```bash
Hyprland
```

Useful first-run steps:

```bash
# Reload the installed Zsh configuration
exec zsh

# Install tmux plugins from inside tmux (default TPM binding)
# Press prefix, then Shift+I

# Inspect the bare dotfiles repository
dotfilesconfig status
```

The `dotfilesconfig` command must be defined by the selected dotfiles repository. If it is not, use the equivalent command directly:

```bash
git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" status
```

Optional services remain opt-in:

```bash
# Configure firewall rules before enabling the firewall
sudo ufw enable

# Connect this machine to Tailscale
sudo systemctl enable --now tailscaled
sudo tailscale up
```

For NVIDIA systems, follow the prompt printed by the installer to add `nvidia-drm.modeset=1` to the bootloader kernel command line, rebuild the GRUB configuration when applicable, and reboot. Confirm the instructions against the current [Hyprland NVIDIA documentation](https://wiki.hypr.land/Nvidia/) for the installed driver and boot setup.

## Re-running and troubleshooting

Most package operations are repeatable because pacman and yay use `--needed`. The installer is not fully idempotent: it can reset an existing dotfiles repository, create additional backup files, repeat user/group changes, and rerun plugin synchronization.

### `yay` installation fails

Remove its temporary build directory and rerun the installer:

```bash
rm -rf ~/.cache/yay
./install.sh
```

### Dotfiles SSH authentication fails

The dotfiles script automatically converts a GitHub SSH URL to HTTPS if the SSH clone fails. For a private repository, load the appropriate SSH key first:

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

### Hyprland starts without the expected desktop

Packages alone do not define key bindings, monitor layout, autostart commands, Waybar modules, or application themes. Verify that the selected dotfiles repository checked out the expected files under `~/.config/` and inspect `~/.config/hypr/hyprland.conf` first.

### Verification reports commands missing

The final check contains several command/package-name mismatches: it checks `dunst` although this setup installs SwayNC, `neovim` although Neovim's executable is `nvim`, and `hyprland` although the session executable is normally `Hyprland`. These missing-command marks can be false negatives and do not necessarily mean package installation failed. Confirm with `pacman -Q swaync neovim hyprland`.

## Scope

This repository configures the user-space desktop after Arch is installed. It does not partition disks, format filesystems, install or configure a bootloader, generate locale settings, create users, configure monitors, or choose GPU drivers other than the optional NVIDIA packages.

## License

No license file is currently included. Unless a license is added, normal copyright restrictions apply; the repository should not be described as MIT licensed.
