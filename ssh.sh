#!/bin/bash

source ~/.ssh/servers.sh

_preview() {
    index=$(_index "$1")
    echo ${cmds[index]} ${targets[index]}
}

_ssh() {
    server=$(_list | fzf \
        --cycle \
        --header='请选择服务器(tab复制地址)' \
        --header-first \
        --bind "tab:execute(echo -n ${hosts[$(_index {})]} | lemonade copy; echo ${hosts[$(_index {})]} copied)+abort" \
        --preview="~/.ssh/ssh.sh preview {}" \
        --height=10 \
        --preview-window=bottom:1:wrap,border-up
    )
    [[ -z "$server" ]] && exit 0
    [[ -z "$(_index "$server")" ]] && echo $server && exit 0
    echo -e "${cmds[index]} ${targets[index]}\nconnecting..."
    exec $(_preview "$server")
}

case $1 in
    "") _ssh ;;
    preview) _preview "$2" ;;
    *) ssh $* ;;
esac
