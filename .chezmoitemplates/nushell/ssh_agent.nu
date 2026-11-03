
if (which ssh-agent | is-not-empty) {
    do --env {
        let ssh_agent_file = (
            $nu.temp-path | path join $"ssh-agent-($env.USER? | default $env.USERNAME).nuon"
        )

        if ($ssh_agent_file | path exists) {
            let ssh_agent_env = open $ssh_agent_file
            let pid = ($ssh_agent_env | get "SSH_AGENT_PID")

            {{- if eq .chezmoi.os "windows" }}
            let process_exists = (^tasklist | lines | find $"($pid)" | is-not-empty)
            {{- else }}
            let process_exists = (^ps -p $pid | lines | length) > 1
            {{- end }}
            if $process_exists {
                load-env $ssh_agent_env
                return
            }
            rm -f $ssh_agent_file
        }

        let ssh_agent_env = (
            ^ssh-agent -c
                | lines
                | first 2
                | parse "setenv {name} {value};"
                | transpose --header-row
                | into record
        )
        load-env $ssh_agent_env
        $ssh_agent_env | save --force $ssh_agent_file
    }
}
