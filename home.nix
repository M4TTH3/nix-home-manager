{ pkgs, lib, config, ... }: {
  # home.username and home.homeDirectory are set per-system in flake.nix
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    # Core CLI
    ripgrep
    fd
    tree-sitter
    just
    upx

    # Languages / runtimes
    gnumake
    go
    gotools
    python3
    jdk
    nodejs
    clang
    rustc
    cargo
    rustfmt
    clippy
    rust-analyzer
    # Nix's clang can't see the macOS SDK, so linking Rust binaries whose
    # crate tree pulls in `-liconv` (e.g. `cargo install rustlings`) fails
    # with "library not found for -liconv". Provide libiconv from Nix and
    # expose it via LIBRARY_PATH below. Same root cause as CGO_ENABLED=0.
    libiconv

    # Linters
    ruff
    golangci-lint
    eslint_d

    # Formatters
    stylua
    prettier
    google-java-format
    ktfmt
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    wl-clipboard
  ];

  programs.home-manager.enable = true;

  programs.zsh = {
    enable = true;
    # Preserves the one line that was in ~/.zshrc before home-manager took
    # over (`export PATH="$HOME/.local/bin:$PATH"`). Enabling programs.zsh
    # is what makes the generated ~/.zshrc source hm-session-vars.sh, so
    # entries in home.sessionVariables (CGO_ENABLED, SSH_AUTH_SOCK) actually
    # land in interactive shells. Old file is at ~/.zshrc.pre-hm.
    initContent = ''
      export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
      # EDITOR=nvim makes zsh default to vi keymap, which breaks Ctrl+R
      # (it becomes vi-redo). Force emacs keymap so reverse-i-search works
      # as before. Switch to `-v` if you ever want vi-style line editing.
      bindkey -e
    '';
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withRuby = false;
    withPython3 = false;
    extraPackages = with pkgs; [
      # Add neovim-specific tools here that aren't in home.packages
    ];
  };

  # Recursively links ./nvim to ~/.config/nvim, letting neovim find its config
  # without home-manager managing it. lazy-lock.json is excluded so it can be
  # installed as a writable copy below — lazy.nvim writes to it on :Lazy sync,
  # which would fail against a read-only Nix store symlink.
  xdg.configFile."nvim" = {
    source = lib.cleanSourceWith {
      src = ./nvim;
      filter = path: _type: baseNameOf path != "lazy-lock.json";
    };
    recursive = true;
  };

  # Install lazy-lock.json as a writable copy of the in-repo version. It gets
  # reset to the tracked version on each `home-manager switch`; in between,
  # lazy.nvim can update it freely.
  home.activation.installLazyLock = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run install -m 644 ${./nvim/lazy-lock.json} \
      ${config.xdg.configHome}/nvim/lazy-lock.json
  '';

  programs.git = {
    enable = true;
    signing = {
      format = "ssh";
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBEWBLlPF+seAP2qrRxBsH7AWmE/oFqgguOXpn3qkqMe matthew@matthews-MacBook-Pro-14-inch-M5";
      signByDefault = true;
    };
    settings = {
      user.name = "mauyeung";
      user.email = "mauyeung@atomicsemi.com";
      core.editor = "nvim";
      gpg.ssh.program =
        if pkgs.stdenv.isDarwin
        then "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
        else "/opt/1Password/op-ssh-sign";
      gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
      # Go's module fetcher hits private repos at https://git.a1s.dev/... and
      # can't prompt for credentials. Rewrite to SSH (port 1022, where Gitea's
      # SSH actually lives) so it uses the 1Password agent.
      url."ssh://git@git.a1s.dev:1022/".insteadOf = "https://git.a1s.dev/";
    };
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      user.name = "mauyeung";
      user.email = "mauyeung@atomicsemi.com";
      ui.editor = "nvim";
    };
  };

  home.sessionVariables = {
    # 1Password's SSH agent on macOS lives in its app group container, not
    # at the simpler ~/.1password/agent.sock path. ssh-add/git/etc. read
    # SSH_AUTH_SOCK directly (only `ssh` itself honors IdentityAgent from
    # ~/.ssh/config), so this env var needs the actual socket path.
    SSH_AUTH_SOCK = "${config.home.homeDirectory}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
    # Nix's clang can't see the macOS SDK, so cgo links fail looking for
    # `-lresolv`. Disable cgo for Go builds — pure-Go net resolver is fine
    # for our use cases (`go run`/`go build` of tools like golangci-lint).
    CGO_ENABLED = "0";
    # Skip the public Go module proxy for internal repos so Go fetches them
    # directly via git (which we've configured to use SSH above).
    GOPRIVATE = "git.a1s.dev";
    # Let the linker find Nix-provided libs (e.g. libiconv, added to
    # home.packages above) so `cargo build`/`cargo install` of crates that
    # link `-liconv` resolve them without needing the macOS SDK.
    LIBRARY_PATH = "${config.home.homeDirectory}/.nix-profile/lib";
    # Nix's rustc ships without the std source (no rust-src component), so
    # rust-analyzer can't resolve std types — no completions/hover on String,
    # Vec, etc. Point it at nixpkgs' rust library source so it can index std.
    RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
  };

  home.file.".ssh/allowed_signers".text =
    "matthewau-yeung@hotmail.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHVBIcjToRazH/oMS5QfTlmLyIBLB/FXZnVQRdWxSZ/w\n";
}
