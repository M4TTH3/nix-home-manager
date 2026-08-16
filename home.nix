{ pkgs, lib, config, ... }:
let
  # fenix Rust toolchain: stable host tools + linux rust-std targets so macOS
  # can cross-compile to Linux (cargo-zigbuild + zig below do the linking).
  # rustfmt is nightly, pinned to firmware CI: rustfmt.toml uses unstable
  # options that stable ignores. Listed first so it shadows stable's rustfmt.
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
  # Identity (username, homeDirectory, git/jj user, signing keys) lives in
  # users/<name>.nix; this module is shared by every machine.
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
    (lib.lowPrio gotools) # lowPrio: gopls also ships `modernize`, let it win
    gopls # from Nix, built against our Go toolchain; Mason's gave false errors

    # Protobuf: compiler, buf (lint/format + LSP), Go codegen plugins
    protobuf
    buf
    protoc-gen-go
    protoc-gen-go-grpc
    grpcurl # curl for gRPC, uses server reflection

    python3
    jdk
    nodejs
    rustToolchain # fenix, from the `let` above; also provides rust-analyzer
    # Cross-linking for `cargo zigbuild --target x86_64-unknown-linux-gnu`
    cargo-zigbuild
    zig

    # LSP servers (Nix-managed, no Mason); nvim's vim.lsp.enable finds them on PATH
    lua-language-server               # lua_ls
    pyright                           # pyright
    typescript-language-server        # ts_ls
    bash-language-server              # bashls
    vscode-langservers-extracted      # jsonls, html, cssls (+ eslint/json)
    yaml-language-server              # yamlls
    dockerfile-language-server        # dockerls
    docker-compose-language-service   # docker_compose_language_service
    tailwindcss-language-server       # tailwindcss
    kotlin-language-server            # kotlin_language_server (replaces JetBrains kotlin_lsp)
    clang-tools                       # clangd (+ clang-format)
    jdt-language-server               # jdtls (Java) — wired in nvim/lua/plugins/java.lua
    starpls                           # starpls (Starlark/Bazel)
    # rust_analyzer comes from rustToolchain (same sysroot as rustc)

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
    # Linux-only: on macOS, Nix's clang has no SDK sysroot and would shadow
    # the working Xcode CLT clang, breaking cgo links.
    clang
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    # For crates linking `-liconv`: Nix clang can't see the macOS SDK, so
    # provide the lib ourselves (exposed via LIBRARY_PATH below).
    libiconv
  ];

  programs.home-manager.enable = true;

  programs.zsh = {
    enable = true;
    # Enabling programs.zsh makes ~/.zshrc source hm-session-vars.sh, so
    # home.sessionVariables reach interactive shells. Old file: ~/.zshrc.pre-hm.
    initContent = ''
      # Re-prepend nix bins: macOS path_helper puts /usr/bin first on every
      # login shell (incl. tmux panes), breaking the nvim alias etc.
      export PATH="$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$HOME/.local/bin:$HOME/.cargo/bin:$HOME/go/bin:$PATH"
      export PATH="$HOME/.opencode/bin:$PATH"
      # EDITOR=nvim defaults zsh to vi keymap, breaking Ctrl+R; keep emacs keymap
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

  # Link ./nvim to ~/.config/nvim. lazy-lock.json is excluded: lazy.nvim
  # writes to it, which fails on a read-only store symlink (see below).
  xdg.configFile."nvim" = {
    source = lib.cleanSourceWith {
      src = ./nvim;
      filter = path: _type: baseNameOf path != "lazy-lock.json";
    };
    recursive = true;
  };

  # Writable copy of lazy-lock.json; reset to the tracked version on each switch
  home.activation.installLazyLock = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run install -m 644 ${./nvim/lazy-lock.json} \
      ${config.xdg.configHome}/nvim/lazy-lock.json
  '';

  # user.name/email and the signing key are per-user (users/<name>.nix)
  programs.git = {
    enable = true;
    signing = {
      format = "ssh";
      signByDefault = true;
    };
    settings = {
      core.editor = "nvim";
      gpg.ssh.program =
        if pkgs.stdenv.isDarwin
        then "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
        else "/opt/1Password/op-ssh-sign";
      gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
    };
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      ui.editor = "nvim";
      ui.pager = ":builtin";
      # git-style markers so nvim conflict tooling works and files can be
      # edited directly (no jj resolve needed)
      ui.conflict-marker-style = "git";
      # `jj resolve` opens a real nvim diff
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

      # Pass focus reports through; nvim's FocusGained checktime needs this
      set -g focus-events on

      # Clipboard: OSC52 via set-clipboard (works over SSH) + copy-mode yanks
      # piped straight to the local clipboard tool
      set -g set-clipboard on
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi y send -X copy-pipe-and-cancel "${if pkgs.stdenv.isDarwin then "pbcopy" else "wl-copy"}"
      bind -T copy-mode-vi MouseDragEnd1Pane send -X copy-pipe-and-cancel "${if pkgs.stdenv.isDarwin then "pbcopy" else "wl-copy"}"
    '';
  };

  home.sessionVariables = {
    # 1Password's SSH agent (per-OS socket path). Needed as an env var:
    # only `ssh` honors IdentityAgent; git/ssh-add read SSH_AUTH_SOCK.
    SSH_AUTH_SOCK =
      if pkgs.stdenv.isDarwin
      then "${config.home.homeDirectory}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
      else "${config.home.homeDirectory}/.1password/agent.sock";
    # jdtls debug/test bundles for nvim/lua/plugins/java.lua (optional there)
    JDTLS_DEBUG_DIR = "${pkgs.vscode-extensions.vscjava.vscode-java-debug}/share/vscode/extensions/vscjava.vscode-java-debug/server";
    JDTLS_TEST_DIR = "${pkgs.vscode-extensions.vscjava.vscode-java-test}/share/vscode/extensions/vscjava.vscode-java-test/server";
  } // lib.optionalAttrs pkgs.stdenv.isDarwin {
    # Nix clang can't see the macOS SDK (cgo links fail on -lresolv);
    # pure-Go resolver is fine for our use cases
    CGO_ENABLED = "0";
    # Let the linker find Nix libs (e.g. libiconv) without the macOS SDK
    LIBRARY_PATH = "${config.home.homeDirectory}/.nix-profile/lib";
    # Pin cgo (when re-enabled) to Xcode CLT clang, which knows the SDK sysroot
    CC = "/usr/bin/clang";
    CXX = "/usr/bin/clang++";
  };
}
