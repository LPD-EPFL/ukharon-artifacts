# Use the absolute path
ROOT_DIR='~'

# Set ssh names of the machines
machine1=delta1
machine2=delta2
machine3=delta3
machine4=delta4
machine5=delta5
machine6=delta6
machine7=delta7
machine8=delta8

# Set fqdn names of the machines (use `hostname -f`)
machine1hostname=dcldelta1.epfl.ch
machine2hostname=dcldelta2.epfl.ch
machine3hostname=dcldelta3.epfl.ch
machine4hostname=dcldelta4.epfl.ch
machine5hostname=lpdquatro1.epfl.ch
machine6hostname=lpdquatro2.epfl.ch
machine7hostname=lpdquatro3.epfl.ch
machine8hostname=lpdquatro4.epfl.ch

REGISTRY_MACHINE=machine1

UKHARON_MCGROUP=ff12:601b:ffff::1:ff28:cf2a/0xc004
UKHARON_KERNELMCGROUP=ff12:401b:ffff::1/0xc004

UKHARON_HAVE_SUDO_ACCESS=true
UKHARON_SUDO_ASKS_PASS=true
UKHARON_SUDO_PASS=my_sudo_pass

UKHARON_CPUNODEBIND=0
UKHARON_CPUMEMBIND=0

# Comma-separated list (without spaces) of up to 6 cores for memory stressing.
# Select these cores on the same NUMA domain as `UKHARON_CPUNODEBIND`.
UKHARON_MEMSTRESS_CORES="16,18,20,22,28,30"

# Do not edit below this line
machine1dir=m1
machine2dir=m2
machine3dir=m3
machine4dir=m4
machine5dir=m5
machine6dir=m6
machine7dir=m7
machine8dir=m8

machine2ssh () {
    local m=$1
    echo "${!m}" 
}

machine2dir () {
    local m=$1
    local m_dir=${m}dir
    echo "${!m_dir}" 
}

machine2hostname () {
    local m=$1
    local m_hn=${m}hostname
    echo "${!m_hn}" 
}

clear_processes() {
    local sd=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    for i in {1..8}; do
        "$sd"/kill_tmux.sh machine$i
    done
}

reset_processes() {
    local sd=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

    clear_processes
    for i in {1..8}; do
        "$sd"/set_tmux.sh machine$i
    done
}

send_payload () {
    local payload=$1
    local sd=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    for i in {1..8}; do
        "$sd"/prepare_env.sh machine$i
        "$sd"/upload_payload.sh machine$i "$payload"
        "$sd"/deploy_payload.sh machine$i
    done
}

gather_results () {
    local destdir=$1
    local sd=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    for i in {1..8}; do
        "$sd"/gather_logs.sh machine$i "$destdir"
    done
}
