#!/bin/bash

source ~/.ssh/servers.sh

_preview1() {
    index=$(_index "$1")
    echo ${targets[index]}
}

_preview2() {
    index=$(_index "$1")
    target="$2"
    [ "$target" = "从本地到远程" ] && echo "scp -r [SOURCE] ${targets[index]}:~"
    [ "$target" = "从远程到本地" ] && echo "scp -r ${targets[index]}:[SOURCE] ."
}

_scp() {
    # 默认fzfopt
    fzfopt='--cycle --header-first --preview-window=bottom:1:wrap,border-up'

    # 选择服务器
    server=$(_list | fzf $fzfopt --header=请选择服务器 --preview="~/.ssh/scp.sh preview1 {}")
    [[ -z "$server" ]] && exit 0

    # 选择方向
    target=$(echo -e "从本地到远程\n从远程到本地" | fzf $fzfopt --header=请选择操作 --preview="~/.ssh/scp.sh preview2 $server {}" --height=7)
    [[ -z "$target" ]] && exit 0

    # 选择文件 PS: 1.sed '/^$/d' 去除空行 2.跳板机无法使用ssh ls指令
    [ "$target" = "从本地到远程" ] && _source=$(ls | fzf $fzfopt --print-query --header=请选择要上传的文件 --preview="cat {}" --height=10 | sed '/^$/d' | sed -n '$p')
    [ "$target" = "从远程到本地" ] && _source=$(ssh $(_preview1 $server) "ls" | fzf $fzfopt --print-query --header=请选择要下载的文件 --height=10 | sed '/^$/d' | sed -n '$p')
    [[ -z "$_source" ]] && exit 0

    # 组装命令
    [ "$target" = "从本地到远程" ] && _cmd="scp -r ${_source/'~'/$HOME} $(_preview1 $server):~"
    [ "$target" = "从远程到本地" ] && _cmd="scp -r $(_preview1 $server):$_source ."

    # 选择操作
    option=$(echo -e "复制命令\n执行命令" | fzf $fzfopt --header=请选择操作 --preview="echo $_cmd" --height=7)
    [[ -z "$option" ]] && exit 0

    # 执行
    [ "$option" = "复制命令" ] && echo -n $_cmd | lemonade copy && echo 'copied'
    [ "$option" = "执行命令" ] && echo 开始执行: $_cmd && eval $_cmd
}

case $1 in
    '') _scp ;;
    preview1) _preview1 "$2" ;;
    preview2) _preview2 "$2" "$3" ;;
    *) scp $* ;;
esac
