#!/bin/bash

# ANSI color codes
GREEN="\033[0;32m"
RED="\033[0;31m"
RESET="\033[0m"

echo "=========Checking for pip3 Installation========="
# Check and install pip3
if ! command -v pip3 &> /dev/null; then
    echo "pip3 could not be found, attempting to install."
    sudo apt-get update && sudo apt-get -y install python3-pip
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to install pip3, exiting.${RESET}"
        exit 1
    fi
else
    echo -e "${GREEN}pip3 is already installed.${RESET}"
fi

echo "=========Checking for tqdm Installation========="
# Check and install tqdm while redirecting warnings and errors
if ! pip3 list 2>&1 | grep -q tqdm; then
    echo "tqdm is not installed, attempting to install."
    pip3 install tqdm 2>&1
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to install tqdm, exiting.${RESET}"
        exit 1
    fi
else
    echo -e "${GREEN}tqdm is already installed.${RESET}"
fi

echo "=========Reading Configuration========="
# Read URL from config.txt
upload_url=$(cat config.txt)
echo -e "${GREEN}URL read from config.txt: $upload_url${RESET}"

echo "=========Replacing URL in Scripts========="
# Replace the URL in both upload_text.py and upload_file.py
url_pattern='https?://[-A-Za-z0-9+&@#/%?=~_|!:,.;]*[-A-Za-z0-9+&@#/%=~_|]'
sed -i "s#$url_pattern#${upload_url}#g" upload_text.py
sed -i "s#$url_pattern#${upload_url}#g" upload_file.py
echo -e "${GREEN}URL replaced in upload_text.py and upload_file.py.${RESET}"

echo "=========Setting Execution Permissions========="
# Grant execution permissions to the scripts
sudo chmod +x upload_text.py
sudo chmod +x upload_file.py
echo -e "${GREEN}Execution permissions set for upload_text.py and upload_file.py.${RESET}"

echo "=========Copying Scripts to /usr/local/bin========="
# Copy the scripts to /usr/local/bin and rename
sudo cp upload_text.py /usr/local/bin/upt
sudo cp upload_file.py /usr/local/bin/upf
echo -e "${GREEN}Scripts copied and renamed to /usr/local/bin/upt and /usr/local/bin/upf.${RESET}"

echo "=========Setting Shebang for Scripts========="
# Set the correct Python interpreter path
PYTHON_PATH=$(which python3)
sudo sed -i "1i #!${PYTHON_PATH}" /usr/local/bin/upt
sudo sed -i "1i #!${PYTHON_PATH}" /usr/local/bin/upf
echo -e "${GREEN}Shebang set correctly in /usr/local/bin/upt and /usr/local/bin/upf.${RESET}"

echo "=========Installation Complete========="
# Output “Installation Complete” in green and reset color
echo -e "${GREEN}Installation Complete. Scripts 'upf' and 'upt' are now available globally.${RESET}"

# Display usage examples
echo "Usage examples:"
echo "1. To upload text:"
echo "   upt 'Here is some text' --room RoomName"
echo "   upt --room 'RoomName' 'Here is some text'"
echo "   echo 'Sample text' | upt --room RoomName"
echo "   cat notes.txt | upt"
echo ""
echo "2. To upload files:"
echo "   upf somefile.txt --room RoomName"
echo "   upf --room 'RoomName' somefile.txt"
echo "   upf --room RoomName file*"
echo ""
echo "Remember to run these commands in a shell where the environment variable PATH includes /usr/local/bin if you installed the scripts there."
