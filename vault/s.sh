#!/bin/bash

ttl=720
user=$(echo $1|cut -d "@" -f1)
server=$(echo $1|cut -d "@" -f2)
os=$(uname -s| tr '[:upper:]' '[:lower:]')

# from https://github.com/stark/Color-Scripts/blob/master/color-scripts/alpha
initializeANSI()
{
    esc=""
    
    blackf="${esc}[30m";   redf="${esc}[31m";    greenf="${esc}[32m"
    yellowf="${esc}[33m"   bluef="${esc}[34m";   purplef="${esc}[35m"
    cyanf="${esc}[36m";    whitef="${esc}[37m"   whitef="${esc}[37m"
    
    blackb="${esc}[40m";   redb="${esc}[41m";    greenb="${esc}[42m"
    yellowb="${esc}[43m"   blueb="${esc}[44m";   purpleb="${esc}[45m"
    cyanb="${esc}[46m";    whiteb="${esc}[47m"
    
    boldon="${esc}[1m";    boldoff="${esc}[22m"
    italicson="${esc}[3m"; italicsoff="${esc}[23m"
    ulon="${esc}[4m";      uloff="${esc}[24m"
    invon="${esc}[7m";     invoff="${esc}[27m"
    
    reset="${esc}[0m"
}

initializeANSI

function sign_key {
    vault write -field=signed_key ssh/sign/$user public_key=@$HOME/.ssh/id_rsa.pub > $key
    chmod 600 $key
}

if [[ $user == $server ]]
then
    echo ${redf}SSH User : root${reset}
    user="root"
else
    echo ${greenf}SSH User : ${user}${reset}
fi

key="$HOME/.ssh/${user}@vault.pub"

vault token lookup > /dev/null 2>&1
if [[ ! $? -eq 0 ]]
then
    echo ${redf}Token missing or expired${reset}
    vault login -method=userpass username=remi > /dev/null
fi

if [[ ! $? -eq 0 ]]
then
    exit 1
fi

if test -f $key
then
    if [[ "$os" == "darwin" ]]
    then
        age=$(echo $((($(date +%s) - $(stat -t %s -f %m -- "$key"))/60)))
    else
        age=$((($(date +%s) - $(date +%s -r "$key")) / 60))
    fi
    if [[ $age -gt $ttl ]]
    then
        echo ${redf}SSH Key expired... Requesting new signature.${reset}
        sign_key
    else
        echo ${bluef}SSH Key age : $age minutes.${reset}
    fi
else
    echo ${redf}SSH Key not found... Requesting new signature.${reset}
    sign_key
fi

ssh -i $key $1
