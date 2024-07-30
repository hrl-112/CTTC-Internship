# This is the part of the project in which Vitis-AI is being used
# https://www.hackster.io/AlbertaBeef/ultra96-v2-adding-support-for-vitis-ai-3-0-704799
cd ~/Avnet_2022_2
git clone -b 2022.2 https://github.com/AlbertaBeef/avnet-vitis-platforms --recursive

source ~/Xilinx/Vitis/2022.2/settings64.sh
source ~/Xilinx/PetaLinux/2022.2/tool/settings.sh

cd ~/Avnet_2022_2/avnet-vitis-platforms/u96v2
make platform PFM=u96v2_sbc_base

# To check the result
platforminfo platforms/avnet_u96v2_sbc_base_2022_2/u96v2_sbc_base.xpfm

# Building the benchmark overlay
cd ~/Avnet_2022_2/avnet-vitis-platforms/u96v2
make overlay OVERLAY=benchmark
