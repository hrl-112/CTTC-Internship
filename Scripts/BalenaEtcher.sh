# How to download and open BalenaEtcher from the terminal
# We go to Downloads and we install BalenaEtcher
~Downloads
wget https://github.com/balena-io/etcher/releases/download/v1.19.21/balenaEtcher-linux-x64-1.19.21.zip
unzip balenaEtcher-linux-x64-1.19.21.zip

# Then we create a script to launch BalenaEtcher
echo '~/Downloads/balenaEtcher-linux-x64-1.19.21/balenaEtcher-linux-x64/balena-etcher &' > ~/balena.sh
# We make it an executable 
chmod +x ~/balena.sh

# Add home folder to PATH
export PATH=$PATH:~/

# Create a simbolic link
ln -s ~/balena.sh balena

# To open BalenaEtcher from terminal:
balena

# IMPORTANT: From now on it is only required to write "balena" on the terminal in order to open BalenaEtcher
