#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "${DIR}/setup/utils.sh"

DIR_DICT="logstash/pipeline/dictionaries/"
HOST_DICT="$DIR_DICT/host_org.yml"
GEO_DICT="$DIR_DICT/geo.yml"

DICTIONARIES+=("$HOST_DICT" "$GEO_DICT")

function fortigate_config() {
    default_fgt_model='100D'
    default_city='Toronto'
    default_isocode="CA"
    default_country='Canada'
    default_continent='North America'
    default_coordinates='54.6988294,-113.7113432'


    while true; 
    do
        read -p "Automatically get IP, Hostname and the Serial Number of the Fortigate? [Requires syslog to be configure] (y/n) " CHOICE
        case $CHOICE in
            y|Y)
                echo "Attempting to autopopulate few variables..."
                read -d '' fgt_ip fgt_hostname fgt_sn <<EOF
                $(ip route | grep default | sed -e "s/^.*via.//" -e "s/.dev.*//")
                $(sudo tcpdump -i $(ip route | grep default | sed -e "s/^.*dev.//" -e "s/.proto.*//") port 5514 -c 1 -vvAs0 2>&1 | sed -n 's/.*devname=//p;s/.*devid=//p' | cut -d ' ' -f 1 | tr -d '"')        
EOF
                echo "Fortigate IP address: $fgt_ip"
                echo "Fortigate Hostname: $fgt_hostname"
                echo "Fortigate Serial Numer: $fgt_sn"
                read -p "Were the results accurate (y/n)? "
                if [[ ! $REPLY =~ ^[Yy]$ ]];
                then
                    echo "Please run the setup again."
                fi
                break
                ;;
            n|N)
                read -p "Enter the Fortigate IP address: " fgt_ip
                read -p "Enter the Fortigate Hostname: " fgt_hostname
                read -p "Enter the Fortigate Serial Numer: " fgt_sn
                break
                ;;
        *)
            echo "Unknown choice."
            continue
            ;;
        esac
    done
    
    read -p "Enter the Fortigate model (Default: $default_fgt_model): " fgt_model
    read -p "Enter the Fortigate Version (e.g 6.2.2): " fgt_ver
    read -p "Enter the Client Name: " client_name
    read -p "Enter the city of the client's location (Default: $default_city): " client_city
    read -p "Enter the country of the client's location (Default: $default_country): " client_country
    read -p "Enter the country of the client's location (Default: $default_isocode): " client_isocode
    read -p "Enter the continent of the client's location (Default: $default_continent): " client_continent
    read -p "Enter the coordinates of the client's location (Default: $default_coordinates): " client_coordinates

    fgt_model=${fgt_model:-$default_fgt_model}
    client_city=${client_city:-$default_city}
    client_country=${client_country:-$default_country}
    client_isocode=${client_isocode:-$default_isocode}
    client_continent=${client_continent:-$default_continent}
    client_coordinates=${client_coordinates:-$default_coordinates}

    c=()
    for i in ${!DICTIONARIES[@]};
    do
        file=${DICTIONARIES[$i]}
        if [[ $(file_exist $file) ]]; then
            echo "The file '${file##*/}' exists."
            
            read -p "Create a backup and replace the file with new content (y/n)? "
            if [[ $REPLY =~ ^[Yy]$ ]];
            then
                mv "${DICTIONARIES[$i]}" "${DICTIONARIES[$i]}.bak"
                if [ "${file##*/}" == "host_org.yml" ]; then
                    echo #TODO:
                elif [ "${file##*/}" == "geo.yml" ]; then
                    out="\"$fgt_hostname,$client_city,$client_continent,$client_isocode,$client_country,$client_coordinates,,,,America/Toronto,,,,,,,,v$fgt_ver,,,\""
                fi
                    cat > ${DICTIONARIES[$i]} <<- EOF
"$fgt_ip": $out 
EOF
            fi
        fi
    done
    echo ${c[@]}
#    cat > ./logstash/pipeline/dictionaries/test.yml <<- EOF
#here is some config for version $version which should
#also reference this path $path
#EOF
}

# DESC: Usage help
# ARGS: None
# OUTS: None
function script_usage() {
    cat << EOF
Usage:
     -h|--help                  Displays this help
     -c|--config                Configure Fortigate parameters

    -nc|--no-colour             Disables colour output
     -v|--verbose               Displays verbose output

    -cr|--cron                  Run silently unless we encounter an error
EOF
}

# DESC: Parameter parser
# ARGS: $@ (optional): Arguments provided to the script
# OUTS: Variables indicating command-line parameters and options
function parse_params() {
    local param
    if [ -z "$*" ]; then script_usage; fi

    while [[ $# -gt 0 ]]; do
        param="$1"
        shift
        case $param in
            -h | --help)
                script_usage
                exit 0
                ;;
            -c | --config)
                fortigate_config
                ;;
            -v | --verbose)
                verbose=true
                ;;
            -nc | --no-colour)
                no_colour=true
                ;;
            -cr | --cron)
                cron=true
                ;;
            *)
                script_usage
                script_exit "Invalid parameter was provided: $param" 1
                ;;
        esac
    done
}

# DESC: Main control flow
# ARGS: $@ (optional): Arguments provided to the script
# OUTS: None
function main() {
    trap script_trap_err ERR
    trap script_trap_exit EXIT

    script_init "$@"
    parse_params "$@"
    cron_init
    colour_init
    #lock_init system
}

# Make it rain
main "$@"