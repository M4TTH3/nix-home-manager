# Home Manager Setup

Standalone flake-based Home Manager on Ubuntu (Determinate Nix).

## Files

- `flake.nix` — flake inputs and `homeConfigurations` outputs
- `flake.lock` — commit for reproducibility
- `home.nix` — main user config (packages, programs, neovim, git)
- `nvim/` — inlined neovim config (linked to `~/.config/nvim` via `xdg.configFile`)

## Commands

```bash
# Apply changes after editing home.nix
home-manager switch --flake ~/.config/home-manager#m4tth3

# Update package versions
nix flake update --flake ~/.config/home-manager
home-manager switch --flake ~/.config/home-manager#m4tth3

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

## Neovim

The neovim config lives in `./nvim` and is recursively linked to `~/.config/nvim` via `xdg.configFile`. Edit lua files freely — they're plain files in the repo, no rebuild needed for config-only changes.

LSP servers and tools are managed inside neovim by [Mason](https://github.com/mason-org/mason.nvim), not by Nix. Add neovim-specific Nix tools (e.g. compilation deps) to `programs.neovim.extraPackages` in `home.nix`.

## First-time install on a new machine

1. Install Determinate Nix.
2. Clone this repo to `~/.config/home-manager/`.
3. `nix run home-manager/master -- switch --flake ~/.config/home-manager#m4tth3`
