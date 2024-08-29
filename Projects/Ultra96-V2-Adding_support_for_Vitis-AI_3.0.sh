# This is the part of the project in which Vitis-AI is being used
# https://www.hackster.io/AlbertaBeef/ultra96-v2-adding-support-for-vitis-ai-3-0-704799
# CAUTION: In this script there is 2 ways to arrive to the result. The fast way in which it is only required to download the final image, insert it on SD card using BalenaEtcher 
# and executing a few commands to see the result. And the slow way in which you create that image by yourself. We will do the slow way first:

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

cd ~/Avnet_2022_2/petalinux/projects/u96v2_sbc_base_2022_2
mkdir -p firmware/avnet_u96v2_benchmark
cp ../../../avnet-vitis-platforms/u96v2/overlays/examples/benchmark/binary_container_1/sd_card/u96v2_sbc_base_wrapper.bit firmware/avnet_u96v2_benchmark/avnet_u96v2_benchmark.bit
cp ../../../avnet-vitis-platforms/u96v2/overlays/examples/benchmark/binary_container_1/sd_card/dpu.xclbin firmware/avnet_u96v2_benchmark/avnet_u96v2_benchmark.xclbin
echo '{ "shell_type":"XRT_FLAT", "num_slots":1 }' > firmware/avnet_u96v2_benchmark/shell.json 

# File modified (you will need to download the .dtsi file or copy the content shown on the respective project from Mario Bergeron in another file)(CAUTION: Your path is going to be different, you need to change it. 
# The first path is what you need to change) 
cp -f ~/Documents/Hector/avnet_u96v2_benchmark.dtsi firmware/avnet_u96v2_benchmark/avnet_u96v2_benchmark.dtsi

# Change to directory projects petalinux 'u96v2_sbc_base_2022_2'
cd ~/Avnet_2022_2/petalinux/projects/u96v2_sbc_base_2022_2

# We can now create our firmware overlay, as follows:
petalinux-create -t apps \
                  --template fpgamanager -n avnet-u96v2-benchmark \
                  --enable \
                  --srcuri "firmware/avnet_u96v2_benchmark/avnet_u96v2_benchmark.bit \
                            firmware/avnet_u96v2_benchmark/avnet_u96v2_benchmark.xclbin \
                            firmware/avnet_u96v2_benchmark/avnet_u96v2_benchmark.dtsi \
                            firmware/avnet_u96v2_benchmark/shell.json" \
                  --force
                  
# This will have created new entries in the user-rootfsconfig and rootfs_config configuration files. Add the "vitis-ai-library-*" packages to these, as follows:
file_conf=~/Avnet_2022_2/petalinux/projects/u96v2_sbc_base_2022_2/project-spec/meta-user/conf/user-rootfsconfig

echo 'CONFIG_xmutil' >> $file_conf
# echo 'CONFIG_vitis-ai-library' >> $file_conf
# echo 'CONFIG_vitis-ai-library-dev' >> $file_conf
# echo 'CONFIG_vitis-ai-library-dbg' >> $file_conf

# Upload file 'rootfs_config':
file_conf=~/Avnet_2022_2/petalinux/projects/u96v2_sbc_base_2022_2/project-spec/configs/rootfs_config

echo 'CONFIG_xmutil=y' >> $file_conf
echo 'CONFIG_imagefeature-package-management=y' >> $file_conf
echo 'CONFIG_dnf=y' >> $file_conf
# echo 'CONFIG_vitis-ai-library=y' >> $file_conf
# echo 'CONFIG_vitis-ai-library-dev=y' >> $file_conf

# Modify file Kconfig.syshw
# sed '337 a config SUBSYSTEM_ETHERNET_PSU_ETHERNET_3_SELECT\n\tbool "psu_ethernet_3"'         -i ~/Avnet_2022_2/petalinux/projects/u96v2_sbc_base_2022_2/build/misc/config/Kconfig.syshw
# sed '344 a config SUBSYSTEM_ETHERNET_PSU_ETHERNET_3_MAC_PATTERN\n\tstring "Template for randomised MAC address"\n\tdefault "00:0a:35:00:??:??"\n\tdepends on SUBSYSTEM_ETHERNET_PSU_ETHERNET_3_SELECT && SUBSYSTEM_ETHERNET_PSU_ETHERNET_3_MAC_AUTO\n\thelp\n\t  Pattern for generating random MAC addresses - question mark\n\t  characters will be replaced by random hex digits\n\nconfig SUBSYSTEM_ETHERNET_PSU_ETHERNET_3_MAC\n\tstring "Ethernet MAC address"\n\tdefault "00:0a:35:00:22:01"\n\tdepends on SUBSYSTEM_ETHERNET_PSU_ETHERNET_3_SELECT && !SUBSYSTEM_ETHERNET_PSU_ETHERNET_3_MAC_AUTO\n\thelp\n\t  To read MAC from ROM/EEPROM set this value to ff:ff:ff:ff:ff:ff\n\nconfig SUBSYSTEM_ETHERNET_PSU_ETHERNET_3_USE_DHCP\n\tbool "Obtain IP address automatically"\n\tdefault y\n\tdepends on SUBSYSTEM_ETHERNET_PSU_ETHERNET_3_SELECT\n\thelp\n\t  Set this option if you would like your SUBSYSTEM to use DHCP for\n\t  obtaining an IP address.\n\nconfig SUBSYSTEM_ETHERNET_PSU_ETHERNET_3_IP_ADDRESS\n\tstring "Static IP address"\n\tdefault "192.168.0.10"\n\tdepends on SUBSYSTEM_ETHERNET_PSU_ETHERNET_3_SELECT && !SUBSYSTEM_ETHERNET_PSU_ETHERNET_3_USE_DHCP\n\thelp\n\t  The IP address of your main network interface when static network\n\t  address assignment is used.\n\nconfig SUBSYSTEM_ETHERNET_PSU_ETHERNET_3_IP_NETMASK\n\tstring "Static IP netmask"\n\tdefault "255.255.255.0"\n\tdepends on SUBSYSTEM_ETHERNET_PSU_ETHERNET_3_SELECT && !SUBSYSTEM_ETHERNET_PSU_ETHERNET_3_USE_DHCP\n\thelp\n\t  Default netmask when static network address assignment is used.\n\nconfig SUBSYSTEM_ETHERNET_PSU_ETHERNET_3_IP_GATEWAY\n\tstring "Static IP gateway"\n\tdefault "192.168.0.1"\n\tdepends on SUBSYSTEM_ETHERNET_PSU_ETHERNET_3_SELECT && !SUBSYSTEM_ETHERNET_PSU_ETHERNET_3_USE_DHCP\n\thelp\n\t  Default gateway when static network address assignment is used.' -i ~/Avnet_2022_2/petalinux/projects/u96v2_sbc_base_2022_2/build/misc/config/Kconfig.syshw

# We start by cloning the Vitis-AI 3.0 repository:
# cd ~/Avnet_2022_2
# git clone -b 3.0 https://github.com/Xilinx/Vitis-AI.git

# Then we copy the yocto recipes for Vitis-AI 3.0:
# cd ~/Avnet_2022_2/petalinux/projects/u96v2_sbc_base_2022_2
# cp -r ~/Avnet_2022_2/Vitis-AI/src/vai_petalinux_recipes/recipes-vitis-ai project-spec/meta-user/.

# For our Vitis implementation, we need to remove one file, the vart_3.0_vivado.bb recipe.
# rm project-spec/meta-user/recipes-vitis-ai/vart/vart_3.0_vivado.bb

# We create a packagegroup
cd ~/Avnet_2022_2/petalinux/projects/u96v2_sbc_base_2022_2/
mkdir -p project-spec/meta-user/recipes-core/packagegroups

echo '
DESCRIPTION = "ULTRA96V2 ML inference app related packages"

inherit packagegroup

ULTRA96V2_ML_ACCEL_PACKAGES = " \
      ap1302-ar1335-single-firmware \
      dnf \
      e2fsprogs-resize2fs \
      parted \
      resize-part \
      packagegroup-petalinux-vitisai \
      packagegroup-petalinux-vitisai-dev \
      packagegroup-petalinux-gstreamer \      
      cmake \
      libgcc \
      gcc-symlinks \
      g++-symlinks \
      binutils \
      xrt \
      xrt-dev \
      zocl \
      opencl-clhpp-dev \
      opencl-headers-dev \
      packagegroup-petalinux-opencv \
      packagegroup-petalinux-opencv-dev \
      packagegroup-petalinux-v4lutils  \
      "
RDEPENDS_${PN} = "${ULTRA96V2_ML_ACCEL_PACKAGES}"

' > project-spec/meta-user/recipes-core/packagegroups/packagegroup-ultra96v2-ml-accel.bb


# Add the custom packagegroup to the root file system configuration
echo "CONFIG_packagegroup-ultra96v2-ml-accel" >> project-spec/meta-user/conf/user-rootfsconfig
echo "CONFIG_packagegroup-ultra96v2-ml-accel=y" >> project-spec/configs/rootfs_config

# We can now rebuild the petalinux project:
petalinux-build -x mrproper
petalinux-build

# Copy with BalenaEtcher on SD Card ~/Avnet_2022_2/petalinux/projects/u96v2_sbc_base_2022_2/images/linux/rootfs.wic

# Initialize ultra
# We try out the application facedetect
cd Vitis-AI/examples/vai_library/samples/yolov4

./test_video_yolov4 face_mask_detection_pt 0

# Output:
# [  393.255613] xhci-hcd xhci-hcd.1.auto: ERROR Transfer event TRB DMA ptr not part of current TD ep_index 2 comp_code 1
# [ WARN:0] global /usr/src/debug/opencv/4.5.2-r0/git/modules/videoio/src/cap_gstreamer.cpp (1081) open OpenCV | GStreamer warning: Cannot query video position: status=0, value=-1, duration=-1
# WARNING: Logging before InitGoogleLogging() is written to STDERR
# I0805 07:30:48.212615  1009 demo.hpp:752] DPU model size=512x512
# terminate called after throwing an instance of 'cv::Exception'
#   what():  OpenCV(4.5.2) /usr/src/debug/opencv/4.5.2-r0/git/modules/highgui/src/window_gtk.cpp:624: error: (-2:Unspecified error) Can't initialize GTK backend in function 'cvInitSystem'
# Aborted


# Execute on ULTRA96V2
touch ~/.Xauthority

# Execute on host
ssh -Y root@10.1.2.198

# Once the board is connected, execute:
cd Vitis-AI/examples/vai_library/samples/yolov4
./test_video_yolov4 face_mask_detection_pt 0

xmutil loadapp avnet-u96v2-benchmark
echo 'firmware: /lib/firmware/xilinx/avnet-u96v2-benchmark/avnet-u96v2-benchmark.xclbin' > /etc/vart.conf


# On the ULTRA:
git clone -b 3.0 https://github.com/Xilinx/Vitis-AI.git
cd Vitis-AI/examples/vai_library/samples/yolov4
sh build.sh 
./test_jpeg_yolov4 face_mask_detection_pt sample_face_mask.jpg

# Result test without models
# WARNING: Logging before InitGoogleLogging() is written to STDERR
# F0802 09:46:41.164902  1188 configurable_dpu_task_imp.cpp:108] [UNILOG][FATAL][VAILIB_DPU_TASK_NOT_FIND][Model files not find!] cannot find model <face_mask_detection_pt> after checking following dir:
# 	.
# 	.
# 	/usr/share/vitis_ai_library/models
# 	/usr/share/vitis_ai_library/.models
# *** Check failure stack trace: ***
# Aborted

# We copy the models that we have on ~/Documentos/Hector/models/
# Execute from host:
scp -r ~/Documentos/Hector/models/face_mask_detection_pt root@10.1.2.198:/usr/share/vitis_ai_library/models

cd Vitis-AI/examples/vai_library/samples/yolov4
./test_jpeg_yolov4 face_mask_detection_pt sample_face_mask.jpg

# Output command:
# WARNING: Logging before InitGoogleLogging() is written to STDERR
# F0802 10:56:03.555461  1420 demo.hpp:1186] Check failed: !images[index].empty() cannot read image from sample_face_mask.jpgles/yolov4#
# *** Check failure stack trace: ***
# Aborted

# Copiamos imagen desde el host descargada de AMD link XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
scp -r ~/Documentos/Hector/sample_face_mask.jpg root@10.1.2.198:/home/root/Vitis-AI/examples/vai_library/samples/yolov4

# Salida comando
WARNING: Logging before InitGoogleLogging() is written to STDERR
I0802 11:01:50.582168  1430 demo.hpp:1193] batch: 0     image: sample_face_mask.jpg
I0802 11:01:50.582520  1430 process_result.hpp:44] RESULT: 0	353.533	122.676	583.533	436.967	0.914165

# Probamos la cámara USB
cd Vitis-AI/examples/vai_library/samples/yolov4
./test_video_yolov4 face_mask_detection_pt 0

# Salida comando
[ WARN:0] global /usr/src/debug/opencv/4.5.2-r0/git/modules/videoio/src/cap_gstreamer.cpp (1081) open OpenCV | GStreamer warning: Cannot query video position: status=0, value=-1, duration=-1
WARNING: Logging before InitGoogleLogging() is written to STDERR
I0802 11:03:48.466337  1438 demo.hpp:752] DPU model size=512x512
W0802 11:03:58.494212  1450 xrt_cu.cpp:212] cu timeout! device_core_idx 0  handle=0xaaaaeea57460 ENV_PARAM(XLNX_DPU_TIMEOUT) 10000 state 1 ERT_CMD_STATE_COMPLETED 4 ms 10010  bo=1 is_done 0 
I0802 11:03:58.494403  1450 xrt_cu.cpp:112] Total: 10010898us	ToDriver: 18446737326431555us	ToCU: 0us	Complete: 0us	Done: 6757288894us
F0802 11:03:58.494525  1450 dpu_control_xrt_edge.cpp:191] dpu timeout! core_idx = 0
 LSTART 0  LEND 0  CSTART 0  CEND 0  SSTART 0  SEND 0  MSTART 0  MEND 0  CYCLE_L 2002181266  CYCLE_H 0 
*** Check failure stack trace: ***
Aborted


# FAST WAY:
# Ejecutar en la ULTRA96V2
touch ~/.Xauthority

# Ejecutar en el host
ssh -Y root@10.1.2.198

# Una vez conectada la placa ejecuta lo siguiente
root@u96v2-sbc-2022-2:

cd Vitis-AI/examples/vai_library/samples/yolov4
./test_video_yolov4 face_mask_detection_pt 0






# Iniciar SD Card en Ultra96V2 y ejecutar

cd Vitis-AI/examples/vai_library/samples/yolov4
./test_video_yolov4 face_mask_detection_pt 0

# Salida del comando anterior
[ WARN:0] global /usr/src/debug/opencv/4.5.2-r0/git/modules/videoio/src/cap_gstreamer.cpp (1081) open OpenCV | GStreamer warning: Cannot query video position: status=0, value=-1, duration=-1
WARNING: Logging before InitGoogleLogging() is written to STDERR
I0731 06:04:12.194324   761 demo.hpp:752] DPU model size=512x512
terminate called after throwing an instance of 'cv::Exception'
  what():  OpenCV(4.5.2) /usr/src/debug/opencv/4.5.2-r0/git/modules/highgui/src/window_gtk.cpp:624: error: (-2:Unspecified error) Can't initialize GTK backend in function 'cvInitSystem'

Aborted


# IMAGEN CON EL MODELO B2304!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#avnet-u96v2_sbc-v2022.2-2023-05-10.img

# Copiar la carpeta 'models' dedes el host a la Ultra96V2
scp -r ~/Documentos/Hector/models root@10.1.2.198:/usr/share/vitis_ai_library/






# Execute on ULTRA96V2
touch ~/.Xauthority

# Ejecutar en el host
ssh -Y root@10.1.2.198

# Una vez conectada la placa ejecuta lo siguiente
root@u96v2-sbc-2022-2:

cd Vitis-AI/examples/vai_library/samples/yolov4
./test_video_yolov4 face_mask_detection_pt 0

# Output command:
# [ WARN:0] global /usr/src/debug/opencv/4.5.2-r0/git/modules/videoio/src/cap_gstreamer.cpp (1081) open OpenCV | GStreamer warning: Cannot query video position: status=0, value=-1, duration=-1
# WARNING: Logging before InitGoogleLogging() is written to STDERR
# I0731 06:04:12.194324   761 demo.hpp:752] DPU model size=512x512
# terminate called after throwing an instance of 'cv::Exception'
#  what():  OpenCV(4.5.2) /usr/src/debug/opencv/4.5.2-r0/git/modules/highgui/src/window_gtk.cpp:624: error: (-2:Unspecified error) Can't initialize GTK backend in function 'cvInitSystem'

# The output of the detection is shown on the host monitor


