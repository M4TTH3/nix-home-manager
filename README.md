# Home Manager Setup

Standalone flake-based Home Manager for both Ubuntu and macOS, using Determinate Nix.

Configurations are keyed by **username** (`m4tth3` on Ubuntu, `matthew` on macOS). Home Manager automatically picks `homeConfigurations."$USER@$hostname"` then `"$USER"` from the flake in `~/.config/home-manager`, so a plain `home-manager switch` does the right thing on every machine — no `--flake .#name` needed.

## Files

- `flake.nix` — flake inputs and `homeConfigurations` outputs (one per username)
- `flake.lock` — commit for reproducibility
- `home.nix` — shared config for all machines (packages, programs, neovim, git behavior)
- `users/m4tth3.nix` — Ubuntu identity: git/jj user, signing key, allowed_signers
- `users/matthew.nix` — macOS/work identity, plus work-specific git/Go settings
- `nvim/` — inlined neovim config (linked to `~/.config/nvim` via `xdg.configFile`)

## Commands

```bash
# Apply changes after editing the config
home-manager switch

# Update package versions
nix flake update --flake ~/.config/home-manager
home-manager switch

# Rollback
home-manager generations
nix-collect-garbage -d   # remove old generations

# View what changed in home-manager since last switch
home-manager news
```

## Notes

- Don't change `home.stateVersion` after first install.
- Don't pin versions in `home.nix` — `flake.lock` handles that. Use per-project flakes (`nix develop`) for project-specific pins.
- `nodePackages.*` is removed — use top-level names (`prettier`, `eslint_d`).
- Use Home Manager for CLI tools and language runtimes; keep apt for system services and drivers.
- User nix settings go in `~/.config/nix/nix.conf` (Determinate manages `/etc/nix/nix.conf`).
- Machine-agnostic config goes in `home.nix` (with `pkgs.stdenv.isDarwin`/`isLinux` for platform differences); anything tied to an identity or a single machine goes in `users/<name>.nix`.

## Neovim

The neovim config lives in `./nvim` and is recursively linked to `~/.config/nvim` via `xdg.configFile`. Edit lua files freely — they're plain files in the repo, no rebuild needed for config-only changes.

LSP servers are installed by Nix (`home.packages` in `home.nix`), not Mason. nvim-lspconfig supplies each server's default config and `vim.lsp.enable` finds the binaries on PATH. Add neovim-specific Nix tools (e.g. compilation deps) to `programs.neovim.extraPackages` in `home.nix`.

Buffers auto-reload when an external tool (Claude Code, git, jj) rewrites a file on disk: `autoread` + a `checktime` autocmd in `nvim/lua/config/common.lua`, with tmux `focus-events on` set in `home.nix` so the `FocusGained` trigger works inside tmux.

## First-time install on a new machine

1. Install Determinate Nix:
   ```bash
   curl -fsSL https://install.determinate.systems/nix | sh -s -- install
   ```
   Restart the shell afterward so `nix` is on PATH.
2. Clone this repo to `~/.config/home-manager/`:
   ```bash
   git clone git@github.com:M4TTH3/nix-home-manager.git ~/.config/home-manager
   ```
3. Apply the config (auto-selects by username):
   ```bash
   nix run home-manager/master -- switch
   ```
   For a brand-new username, add a `users/<name>.nix` and an entry in `flake.nix` first.
