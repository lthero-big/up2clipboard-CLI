#!/bin/bash

# File variables
CONFIG_FILE="config.txt"

# ANSI color codes
GREEN="\033[0;32m"
RED="\033[0;31m"
BLUE="\033[0;34m"
RESET="\033[0m"

# Read configuration from a simple text file
BIN_DIR="/usr/local/bin/"
BIN_UPT_NAME=$(grep '^bin_upt_name=' $CONFIG_FILE | cut -d'=' -f2)
BIN_UPF_NAME=$(grep '^bin_upf_name=' $CONFIG_FILE | cut -d'=' -f2)
BIN_UPT="${BIN_DIR}${BIN_UPT_NAME}"
BIN_UPF="${BIN_DIR}${BIN_UPF_NAME}"
upload_url=$(grep '^upload_url=' $CONFIG_FILE | cut -d'=' -f2)

echo -e "${GREEN}Configuration loaded:${RESET} BIN_UPT_NAME=${BLUE}$BIN_UPT_NAME${RESET}, BIN_UPF_NAME=${BLUE}$BIN_UPF_NAME${RESET}, UPLOAD_URL=${BLUE}$upload_url${RESET}"


# Python script file names
UPLOAD_TEXT="upload_text.py"
UPLOAD_FILE="upload_file.py"

# ANSI color codes
GREEN="\033[0;32m"
RED="\033[0;31m"
BLUE="\033[0;34m"
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


echo "=========Replacing URL in Scripts========="
url_pattern='https?://[-A-Za-z0-9+&@#/%?=~_|!:,.;]*[-A-Za-z0-9+&@#/%=~_|]'
# Replace the URL line in both upload_text.py and upload_file.py
sed -i "s|^[ \t]*upload_url =.*|    upload_url = '${upload_url}'|" "$UPLOAD_TEXT"
sed -i "s|^[ \t]*upload_url =.*|    upload_url = '${upload_url}'|" "$UPLOAD_FILE"

# Function to verify if the replacement was successful
verify_url_replacement() {
    local file=$1
    local expected_url=$2

    if grep -qE "^[ \t]*upload_url = '${expected_url}'" "$file"; then
        echo -e "${GREEN}URL successfully replaced in${RESET} ${BLUE}${file}.${RESET}"
    else
        echo -e "${RED}Failed to replace URL in${RESET} ${BLUE}${file}. Exiting.${RESET}"
        exit 1
    fi
}

# Verify replacement for both files
verify_url_replacement "$UPLOAD_TEXT" "${upload_url}"
verify_url_replacement "$UPLOAD_FILE" "${upload_url}"

echo "=========Setting Execution Permissions========="
# Grant execution permissions to the scripts
if sudo chmod +x "$UPLOAD_TEXT" && sudo chmod +x "$UPLOAD_FILE"; then
    echo -e "${GREEN}Execution permissions set for${RESET} ${BLUE}${UPLOAD_TEXT} and ${UPLOAD_FILE}.${RESET}"
else
    echo -e "${RED}Failed to set execution permissions. Exiting.${RESET}"
    exit 1
fi

echo "=========Copying Scripts to /usr/local/bin========="
# Copy the scripts to /usr/local/bin and rename
if sudo cp "$UPLOAD_TEXT" "$BIN_UPT" && sudo cp "$UPLOAD_FILE" "$BIN_UPF"; then
    echo -e "${GREEN}Scripts copied and renamed to${RESET} ${BLUE}${BIN_UPT} and ${BIN_UPF}.${RESET}"
else
    echo -e "${RED}Failed to copy or rename scripts. Exiting.${RESET}"
    exit 1
fi

echo "=========Setting Shebang for Scripts========="
# Set the correct Python interpreter path
PYTHON_PATH=$(which python3)
if sudo sed -i "1i #!${PYTHON_PATH}" "$BIN_UPT" && sudo sed -i "1i #!${PYTHON_PATH}" "$BIN_UPF"; then
    echo -e "${GREEN}Shebang set correctly in${RESET} ${BLUE}${BIN_UPT} and ${BIN_UPF}.${RESET}"
else
    echo -e "${RED}Failed to set shebang for the scripts. Exiting.${RESET}"
    exit 1
fi

echo "=========Installation Complete========="
# Output “Installation Complete” in green and reset color
echo -e "${GREEN}Installation Complete. Scripts${RESET} ${BLUE}'${BIN_UPF_NAME}' and '${BIN_UPT_NAME}'${RESET}${GREEN} are now available globally.${RESET}"

# Display usage examples
echo "Usage examples:"
echo "1. To upload text:"
echo -e "   ${BLUE}${BIN_UPT_NAME} 'Here is some text' --room RoomName${RESET}"
echo "   ${BIN_UPT_NAME} --room 'RoomName' 'Here is some text'"
echo "   echo 'Sample text' | ${BIN_UPT_NAME} --room RoomName"
echo "   cat notes.txt | ${BIN_UPT_NAME}"
echo ""
echo "2. To upload files:"
echo -e "   ${BLUE}${BIN_UPF_NAME} somefile.txt --room RoomName${RESET}"
echo "   ${BIN_UPF_NAME} --room 'RoomName' somefile.txt"
echo "   ${BIN_UPF_NAME} --room RoomName file*"
echo ""
echo "Remember to run these commands in a shell where the environment variable PATH includes ${BIN_DIR} if you installed the scripts there."
