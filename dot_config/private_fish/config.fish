eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv) # For Linux

# 将rbw-enhanced 加入环境变量
set -x PATH $HOME/.cargo/bin $HOME/rbw/target/release $PATH
set -x SSH_AUTH_SOCK $XDG_RUNTIME_DIR/rbw/ssh-agent-socket
if status is-interactive
  starship init fish | source

  # Commands to run in interactive sessions can go here
end
