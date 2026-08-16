{ ... }:
let
  sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBEWBLlPF+seAP2qrRxBsH7AWmE/oFqgguOXpn3qkqMe matthew@matthews-MacBook-Pro-14-inch-M5";
  email = "mauyeung@atomicsemi.com";
in {
  home.username = "matthew";
  home.homeDirectory = "/Users/matthew";

  programs.git = {
    signing.key = sshKey;
    settings = {
      user.name = "mauyeung";
      user.email = email;
      # Go fetches private repos over https and can't prompt for credentials;
      # rewrite to SSH (Gitea's SSH is on port 1022) to use the 1Password agent
      url."ssh://git@git.a1s.dev:1022/".insteadOf = "https://git.a1s.dev/";
    };
  };

  programs.jujutsu.settings.user = {
    name = "mauyeung";
    email = email;
  };

  # Skip the public Go module proxy for internal repos (fetched via git above)
  home.sessionVariables.GOPRIVATE = "git.a1s.dev";

  home.file.".ssh/allowed_signers".text = "${email} ${sshKey}\n";
}
