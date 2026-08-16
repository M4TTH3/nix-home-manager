{ ... }:
let
  sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHVBIcjToRazH/oMS5QfTlmLyIBLB/FXZnVQRdWxSZ/w";
  email = "matthewau-yeung@hotmail.com";
in {
  home.username = "m4tth3";
  home.homeDirectory = "/home/m4tth3";

  programs.git = {
    signing.key = sshKey;
    settings = {
      user.name = "M4TTH3";
      user.email = email;
    };
  };

  programs.jujutsu.settings.user = {
    name = "M4TTH3";
    email = email;
  };

  home.file.".ssh/allowed_signers".text = "${email} ${sshKey}\n";
}
