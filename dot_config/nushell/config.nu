# 启动 ssh-agent 并保存其环境变量
if not (test -f ~/.ssh/agent-env) {
    ssh-agent | save -r ~/.ssh/agent-env
}

# 加载 ssh-agent 环境变量
source ~/.ssh/agent-env

# 添加 SSH 密钥到 ssh-agent
if not (contains $(ssh-add -l) ~/.ssh/id_rsa) {
    ssh-add ~/.ssh/id_github_Dararaaa
}

$env.TERM = "xterm-256color"
