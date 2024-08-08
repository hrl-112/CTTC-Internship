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

# Final SD card image on: ~/Avnet_2022_2/petalinux/projects/u96v2_sbc_base_2022_2/images/linux/rootfs.wic

# Copy image on SD card with BalenaEtcher
balena

# Once we have power on the Ultra we login as "root" and we will have to configure our Internet connection

# Then we will have to create a python script (you can find it on "Scripts" folder) in the root directory and execute the following:
python3 py.y

# Now we will do a tiny modification:
sed '112 a packagegroup-petalinux-jupyter \' -i ~/Avnet_2022_2/petalinux/u96v2_sbc_base_2022_2/roject-spec/meta-avnet/recipes-core/images/petalinux-image-minimal.bbappend
