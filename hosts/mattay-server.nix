# Headless server: no 1Password. Sign commits with the laptop's 1Password
# key via SSH agent forwarding (`ForwardAgent yes` for this host on the
# laptop) instead of op-ssh-sign.
{ lib, ... }: {
  # Stock ssh-keygen signs through whatever agent SSH_AUTH_SOCK points at
  programs.git.settings.gpg.ssh.program = lib.mkForce "ssh-keygen";

  # Keep sshd's forwarded agent socket instead of the missing 1Password one
  home.sessionVariables.SSH_AUTH_SOCK = lib.mkForce "$SSH_AUTH_SOCK";
}
