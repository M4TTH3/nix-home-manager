{ pkgs, config, ... }: {
  home.username = "m4tth3";
  home.homeDirectory = "/home/m4tth3";
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    # Core CLI
    ripgrep
    fd
    tree-sitter
    wl-clipboard

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

    # Linters
    ruff
    golangci-lint
    eslint_d

    # Formatters
    stylua
    prettier
    google-java-format
    ktfmt
  ];

  programs.home-manager.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    extraPackages = with pkgs; [
      # Add neovim-specific tools here that aren't in home.packages
    ];
  };

  # Recursively links ./nvim (git submodule: github.com/M4TTH3/nvim-config)
  # to ~/.config/nvim, letting neovim find its config without home-manager managing it
  xdg.configFile."nvim" = {
    source = ./nvim;
    recursive = true;
  };

  programs.git = {
    enable = true;
    signing = {
      format = "ssh";
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHVBIcjToRazH/oMS5QfTlmLyIBLB/FXZnVQRdWxSZ/w";
      signByDefault = true;
    };
    settings = {
      user.name = "M4TTH3";
      user.email = "matthewau-yeung@hotmail.com";
      core.editor = "nvim";
      gpg.ssh.program = "/opt/1Password/op-ssh-sign";
      gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
    };
  };

  home.sessionVariables = {
    SSH_AUTH_SOCK = "${config.home.homeDirectory}/.1password/agent.sock";
  };

  home.file.".ssh/allowed_signers".text =
    "matthewau-yeung@hotmail.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHVBIcjToRazH/oMS5QfTlmLyIBLB/FXZnVQRdWxSZ/w\n";
}
