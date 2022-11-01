si=0
set_server() {
    servers[$si]="$1"
    cmds[$si]="$2"
    targets[$si]="$3"
    hosts[$si]="$4"
    si=$(($si+1))
}

# set_server name cmd target(user@host) host
set_server '1.demo' 'ssh'                        'root@demo'        'demo'
set_server '2.demo' 'ssh -R 2489:127.0.0.1:2489' 'root@121.4.29.84' '121.4.29.84'

_list() {
    for ((i = 0; i < ${#servers[@]}; i++)); do
        _item=${servers[$i]}
        echo "${_item[@]}"
    done
}

_index() {
    for ((i = 0; i < ${#servers[@]}; i++)); do
        _item=${servers[$i]}
        [[ "$_item" == "$1" ]] && echo $i && break
    done
}
