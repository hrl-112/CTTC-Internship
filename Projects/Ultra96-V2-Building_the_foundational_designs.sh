# This is the first part of a project made by Mario Bergeron
# https://www.hackster.io/AlbertaBeef/ultra96-v2-building-the-foundational-designs-e4315f#toc-introduction-0
cd ~
mkdir -p Avnet_2022_2
cd ~/Avnet_2022_2
git clone https://github.com/Avnet/bdf
git clone -b 2022.2 https://github.com/Avnet/hdl
git clone -b 2022.2 https://github.com/Avnet/petalinux

source ~/Xilinx/Vitis/2022.2/settings64.sh
source ~/Xilinx/PetaLinux/2022.2/tool/settings.sh

cd ~/Avnet_2022_2/petalinux/
scripts/make_u96v2_sbc_base.sh

balena
