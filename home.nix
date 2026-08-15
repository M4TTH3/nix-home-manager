{ pkgs, lib, config, ... }:
let
  # Rust toolchain from fenix (overlay added in flake.nix): the host stable
  # toolchain (rustc/cargo/clippy/rustfmt/rust-src) plus the rust-std for
  # x86_64-unknown-linux-gnu so we can cross-compile to Linux from macOS.
  # The cross link step is handled by cargo-zigbuild + zig (in home.packages):
  # build with `cargo zigbuild --target x86_64-unknown-linux-gnu`.
  #
  # rustfmt comes from the nightly firmware CI pins (scripts/rustfmt.sh):
  # the repo's rustfmt.toml uses unstable options that stable rustfmt
  # silently ignores. Listed first so it shadows the stable rustfmt.
  rustfmtNightly = (pkgs.fenix.toolchainOf {
    channel = "nightly";
    date = "2025-01-15";
    sha256 = "sha256-2/hhs9ae5XwTZYumAmDwo98D8T91ouZWQJlUWlhI0ZY=";
  }).rustfmt;
  rustToolchain = pkgs.fenix.combine [
    rustfmtNightly
    pkgs.fenix.stable.toolchain
    pkgs.fenix.targets.x86_64-unknown-linux-gnu.stable.rust-std
    pkgs.fenix.targets.aarch64-unknown-linux-gnu.stable.rust-std
  ];
in {
  # home.username and home.homeDirectory are set per-system in flake.nix
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    # Core CLI
    ripgrep
    fd
    tree-sitter
    just
    upx
    minio-client # `mc` CLI for S3/minio

    jjui

    # Languages / runtimes
    gnumake
    go
    # gopls and gotools both ship a `modernize` binary; lower gotools' priority
    # so gopls wins the collision in the profile.
    (lib.lowPrio gotools)
    gopls # from Nix so it's built against the Go toolchain; Mason's caused false errors

    # Protobuf: protoc compiler, buf (lint/format/codegen + LSP via `buf beta lsp`),
    # and the Go codegen plugins. Rust uses prost/tonic via build.rs (just needs protoc).
    protobuf
    buf
    protoc-gen-go
    protoc-gen-go-grpc
    grpcurl # curl for gRPC, uses server reflection

    python3
    jdk
    nodejs
    # Rust: fenix toolchain (defined in the `let` above) carries rustc, cargo,
    # rustfmt, clippy, rust-src, rust-analyzer, and the linux-gnu cross std.
    # Now that Mason is gone, nvim's rust_analyzer resolves to this one on PATH.
    rustToolchain
    # Cross-compile to Linux: zig is the cross linker/C-compiler, cargo-zigbuild
    # wires it into cargo (`cargo zigbuild --target x86_64-unknown-linux-gnu`).
    cargo-zigbuild
    zig
    # Nix's clang can't see the macOS SDK, so linking Rust binaries whose
    # crate tree pulls in `-liconv` (e.g. `cargo install rustlings`) fails
    # with "library not found for -liconv". Provide libiconv from Nix and
    # expose it via LIBRARY_PATH below. Same root cause as CGO_ENABLED=0.
    libiconv

    # LSP servers (managed by Nix, not Mason). nvim's native vim.lsp.enable
    # finds these on PATH; nvim-lspconfig still supplies their default cmd/root.
    lua-language-server               # lua_ls
    pyright                           # pyright
    typescript-language-server        # ts_ls
    bash-language-server              # bashls
    vscode-langservers-extracted      # jsonls, html, cssls (+ eslint/json)
    yaml-language-server              # yamlls
    dockerfile-language-server-nodejs # dockerls
    docker-compose-language-service   # docker_compose_language_service
    tailwindcss-language-server       # tailwindcss
    kotlin-language-server            # kotlin_language_server (replaces JetBrains kotlin_lsp)
    clang-tools                       # clangd (+ clang-format)
    jdt-language-server               # jdtls (Java) — wired in nvim/lua/plugins/java.lua
    starpls                           # starpls (Starlark/Bazel)
    # rust_analyzer is NOT listed here: it ships inside the fenix rustToolchain
    # above (same sysroot as rustc, so std-source discovery just works).


    # Linters
    ruff
    golangci-lint
    eslint_d

    # Formatters
    stylua
    prettier
    google-java-format
    ktfmt
    bazel
    bazel-buildtools # buildifier (BUILD/bzl formatter) + buildozer
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    wl-clipboard
    # macOS gets clang from /usr/bin (Xcode CLT); Nix's clang is unwrapped and
    # has no SDK sysroot, so it shadows the working one and breaks cgo links.
    clang
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
      # Re-prepend nix profile bins. macOS /etc/zprofile runs path_helper on
      # every login shell, which reorders PATH to put /usr/bin first. The
      # nix-daemon.sh fix in /etc/zshrc is guarded by __ETC_PROFILE_NIX_SOURCED
      # and skips re-prepending when that var is inherited (e.g. tmux panes,
      # which run a *second* login shell under the Ghostty one). Without this,
      # `vim` in tmux resolves to /usr/bin/vim instead of the nvim alias.
      export PATH="$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$HOME/.local/bin:$HOME/.cargo/bin:$HOME/go/bin:$PATH"
      export PATH="$HOME/.opencode/bin:$PATH"
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
      ui.pager = ":builtin";
      # git-style diff3 markers so nvim conflict plugins/highlighting work,
      # and conflicted files can be edited directly (no jj resolve needed)
      ui.conflict-marker-style = "git";
      # `jj resolve` opens a real nvim diff instead of a bare buffer
      ui.merge-editor = "vimdiff";
      merge-tools.vimdiff.program = "nvim";
      snapshot.auto-track = "none()";
    };
  };

  programs.tmux = {
    enable = true;
    mouse = true;
    keyMode = "vi";
    baseIndex = 1; # windows/panes start at 1, not 0
    historyLimit = 50000;
    escapeTime = 10; # don't delay <Esc> in nvim
    terminal = "tmux-256color";
    extraConfig = ''
      # Truecolor: Ghostty advertises RGB; let tmux pass it through.
      set -as terminal-features ",*:RGB"

      # Clipboard. Two complementary paths so copy works locally and over SSH:
      #  1. set-clipboard on -> tmux emits OSC52, which Ghostty writes to the
      #     system clipboard (works even on a remote host).
      #  2. copy-mode yanks also pipe straight to the local clipboard tool.
      set -g set-clipboard on
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi y send -X copy-pipe-and-cancel "${if pkgs.stdenv.isDarwin then "pbcopy" else "wl-copy"}"
      bind -T copy-mode-vi MouseDragEnd1Pane send -X copy-pipe-and-cancel "${if pkgs.stdenv.isDarwin then "pbcopy" else "wl-copy"}"
    '';
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
    # jdtls debug/test bundles (Nix-provided VSCode extensions), consumed by
    # nvim/lua/plugins/java.lua. java.lua skips gracefully if these are unset.
    JDTLS_DEBUG_DIR = "${pkgs.vscode-extensions.vscjava.vscode-java-debug}/share/vscode/extensions/vscjava.vscode-java-debug/server";
    JDTLS_TEST_DIR = "${pkgs.vscode-extensions.vscjava.vscode-java-test}/share/vscode/extensions/vscjava.vscode-java-test/server";
  } // lib.optionalAttrs pkgs.stdenv.isDarwin {
    # Pin cgo to the Xcode CLT compiler, which knows the macOS SDK sysroot.
    # Without this, anything needing CGO_ENABLED=1 fails at link on -lresolv.
    CC = "/usr/bin/clang";
    CXX = "/usr/bin/clang++";
  };

  home.file.".ssh/allowed_signers".text =
    "matthewau-yeung@hotmail.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHVBIcjToRazH/oMS5QfTlmLyIBLB/FXZnVQRdWxSZ/w\n";
}
