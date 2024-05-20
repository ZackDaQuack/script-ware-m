#!/bin/bash

print_color() {
  timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo -e "\033[${1}m${timestamp} - ${2}\033[0m"
}

print_error() {
  print_color "31" "ERROR: $1"
}


# Kill existing instances of Script Ware M
pids=$(pgrep -f "Script Ware M \(revived edition\)")
if [ -z "$pids" ]; then
  print_color "32" "SW-M already closed!"
else
    while IFS= read -r pid; do
        print_color "33" "Terminating SW-M instance with pid: $pid"
        kill "$pid"
    done <<< "$pids"
    print_color "32" "SW-M closed!"
fi

cd ~
cd /Applications


# Download and verify jq
print_color "34" "Installing jq..."
curl -s "https://raw.githubusercontent.com/ZackDaQuack/script-ware-m/main/jq" -o "./jq"
hash=$(shasum -a 256 jq | awk '{print $1}')
if [[ "$hash" == "4155822bbf5ea90f5c79cf254665975eb4274d426d0709770c21774de5407443" ]]; then
  print_color "32" "Installed jq"
else
  print_error "jq file hash mismatch. Terminating installation. Please report this error!"
  exit 1
fi
chmod +x ./jq


# Check for updates
print_color "34" "Checking for updates..."

release_json=$(curl -s "https://api.github.com/repos/ZackDaQuack/script-ware-m/releases/latest")
version=$(echo "$release_json" | ./jq -r '.name')
download_url=$(echo "$release_json" | ./jq -r '.assets[] | select(.name | endswith(".zip")) | .browser_download_url')
release_notes=$(echo "$release_json" | ./jq -r '.body')


if [ -z "$download_url" ]; then
  print_error "Could not find download URL for the latest release."
  exit 1
fi


# Download and update
print_color "32" "Quack! SW-M update located! Downloading version $version..."

curl -L "${download_url}" -o "scriptware-update.zip"

print_color "32" "Updating SW-M..."

rm -rf "/Applications/Script Ware M (revived edition).app"
unzip -qq "scriptware-update.zip"

rm "scriptware-update.zip"
rm ./jq

print_color "32" "SW-M updated!"
print_color "34" "Release Notes: $release_notes"

exit 0
