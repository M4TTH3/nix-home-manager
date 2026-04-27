{ pkgs, config, ... }: {
  home.username = "m4tth3";
  home.homeDirectory = "/home/m4tth3";
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    # Editor
    neovim

    # Core CLI
    ripgrep
    fd
    tree-sitter

    # Languages / runtimes
    go
    python3
    jdk
    nodejs
    clang
    clang-tools
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
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  home.file.".ssh/allowed_signers".text =
    "matthewau-yeung@hotmail.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHVBIcjToRazH/oMS5QfTlmLyIBLB/FXZnVQRdWxSZ/w\n";
}
