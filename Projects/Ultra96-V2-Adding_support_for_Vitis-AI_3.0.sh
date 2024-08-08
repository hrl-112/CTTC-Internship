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

# File modified (you will need to download the .dtsi file or copy the content on another file)(CAUTION: Your path is going to be different, you need to change it. 
# The first patch is what you need to change) 
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

# Actualizar fichero 'rootfs_config'

file_conf=~/Avnet_2022_2/petalinux/projects/u96v2_sbc_base_2022_2/project-spec/configs/rootfs_config


echo 'CONFIG_xmutil=y' >> $file_conf
# echo 'CONFIG_vitis-ai-library=y' >> $file_conf
# echo 'CONFIG_vitis-ai-library-dev=y' >> $file_conf

# Actualizamos fichero 'interfaces' para configurar eth0
cp -f ~/Documentos/Hector/interfaces ~/Avnet_2022_2/petalinux/projects/u96v2_sbc_base_2022_2/project-spec/configs/init-ifupdown/interfaces

# NO CLONAMOS VITIS_AI, ON TARGET INSTALAREMOS EL PACKAGE
# We start by cloning the Vitis-AI 3.0 repository:
# cd ~/Avnet_2022_2
# git clone -b 3.0 https://github.com/Xilinx/Vitis-AI.git

# Then we copy the yocto recipes for Vitis-AI 3.0:
# cd ~/Avnet_2022_2/petalinux/projects/u96v2_sbc_base_2022_2
# cp -r ~/Avnet_2022_2/Vitis-AI/src/vai_petalinux_recipes/recipes-vitis-ai project-spec/meta-user/.

# For our Vitis implementation, we need to remove one file, the vart_3.0_vivado.bb recipe.
# rm project-spec/meta-user/recipes-vitis-ai/vart/vart_3.0_vivado.bb

# We can now rebuild the petalinux project:
petalinux-build -x mrproper
petalinux-build

# Copiar con BalenaEtcher en SD Card ~/Avnet_2022_2/petalinux/projects/u96v2_sbc_base_2022_2/images/linux/rootfs.wic





# Iniciamos la ultra

# Probamos aplicaión facedetect
cd Vitis-AI/examples/vai_library/samples/yolov4

./test_video_yolov4 face_mask_detection_pt 0

# Salida aplicación
[  393.255613] xhci-hcd xhci-hcd.1.auto: ERROR Transfer event TRB DMA ptr not part of current TD ep_index 2 comp_code 1
[ WARN:0] global /usr/src/debug/opencv/4.5.2-r0/git/modules/videoio/src/cap_gstreamer.cpp (1081) open OpenCV | GStreamer warning: Cannot query video position: status=0, value=-1, duration=-1
WARNING: Logging before InitGoogleLogging() is written to STDERR
I0805 07:30:48.212615  1009 demo.hpp:752] DPU model size=512x512
terminate called after throwing an instance of 'cv::Exception'
  what():  OpenCV(4.5.2) /usr/src/debug/opencv/4.5.2-r0/git/modules/highgui/src/window_gtk.cpp:624: error: (-2:Unspecified error) Can't initialize GTK backend in function 'cvInitSystem'

Aborted



# Ejecutar en la ULTRA96V2
touch ~/.Xauthority

# Ejecutar en el host
ssh -Y root@10.1.2.198

# Una vez conectada la placa ejecuta lo siguiente
root@u96v2-sbc-2022-2:

cd Vitis-AI/examples/vai_library/samples/yolov4
./test_video_yolov4 face_mask_detection_pt 0

























xmutil loadapp avnet-u96v2-benchmark
echo 'firmware: /lib/firmware/xilinx/avnet-u96v2-benchmark/avnet-u96v2-benchmark.xclbin' > /etc/vart.conf


# DENTRO DE LA ULTRA

git clone -b 3.0 https://github.com/Xilinx/Vitis-AI.git

cd Vitis-AI/examples/vai_library/samples/yolov4



sh build.sh 

# control + z por si se queda colgado 

 ./test_jpeg_yolov4 face_mask_detection_pt sample_face_mask.jpg

# RESUTADO TEST SIN MODELOS

 ./test_jpeg_yolov4 face_mask_detection_pt sample_face_mask.jpg 
WARNING: Logging before InitGoogleLogging() is written to STDERR
F0802 09:46:41.164902  1188 configurable_dpu_task_imp.cpp:108] [UNILOG][FATAL][VAILIB_DPU_TASK_NOT_FIND][Model files not find!] cannot find model <face_mask_detection_pt> after checking following dir:
	.
	.
	/usr/share/vitis_ai_library/models
	/usr/share/vitis_ai_library/.models
*** Check failure stack trace: ***
Aborted

# Copiamos el modelo que tenemos en ~/Documentos/Hector/models/
HOST> scp -r ~/Documentos/Hector/models/face_mask_detection_pt root@10.1.2.198:/usr/share/vitis_ai_library/models

cd Vitis-AI/examples/vai_library/samples/yolov4
 ./test_jpeg_yolov4 face_mask_detection_pt sample_face_mask.jpg

# Salida comando
WARNING: Logging before InitGoogleLogging() is written to STDERR
F0802 10:56:03.555461  1420 demo.hpp:1186] Check failed: !images[index].empty() cannot read image from sample_face_mask.jpgles/yolov4#
*** Check failure stack trace: ***
Aborted

# Copiamos imagen desde el host descargada de AMD link XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
HOST> scp -r ~/Documentos/Hector/sample_face_mask.jpg root@10.1.2.198:/home/root/Vitis-AI/examples/vai_library/samples/yolov4

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


# Ejecutar en la ULTRA96V2
touch ~/.Xauthority

# Ejecutar en el host
ssh -Y root@10.1.2.198

# Una vez conectada la placa ejecuta lo siguiente
root@u96v2-sbc-2022-2:

cd Vitis-AI/examples/vai_library/samples/yolov4
./test_video_yolov4 face_mask_detection_pt 0

# Salida del comando
[ WARN:0] global /usr/src/debug/opencv/4.5.2-r0/git/modules/videoio/src/cap_gstreamer.cpp (1081) open OpenCV | GStreamer warning: Cannot query video position: status=0, value=-1, duration=-1
XRT build version: 2.14.0
Build hash: 43926231f7183688add2dccfd391b36a1f000bea
Build date: 2022-10-07 05:12:02
Git branch: 2022.2
PID: 1467
UID: 0
[Fri Aug  2 11:06:06 2024 GMT]
HOST: 
EXE: /home/root/Vitis-AI/examples/vai_library/samples/yolov4/test_video_yolov4
[XRT] ERROR: unable to issue xclExecBuf
WARNING: Logging before InitGoogleLogging() is written to STDERR
F0802 11:06:06.442256  1467 xrt_bin_stream.cpp:159] [UNILOG][FATAL][VART_LOAD_XCLBIN_FAIL][Bitstream download failed!] 
*** Check failure stack trace: ***
Aborted


xmutil listapps
                     Accelerator          Accel_type                            Base           Base_type      #slots(PL+AIE)         Active_slot

           avnet-u96v2-benchmark            XRT_FLAT           avnet-u96v2-benchmark            XRT_FLAT               (0+0)                  -1

xmutil loadapp avnet-u96v2-benchmark
avnet-u96v2-benchmark: load Error: -1


























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






# Ejecutar en la ULTRA96V2
touch ~/.Xauthority

# Ejecutar en el host
ssh -Y root@10.1.2.198

# Una vez conectada la placa ejecuta lo siguiente
root@u96v2-sbc-2022-2:

cd Vitis-AI/examples/vai_library/samples/yolov4
./test_video_yolov4 face_mask_detection_pt 0

# Salida del comando anterior
[ WARN:0] global /usr/src/debug/opencv/4.5.2-r0/git/modules/videoio/src/cap_gstreamer.cpp (1081) open OpenCV | GStreamer warning: Cannot query video position: status=0, value=-1, duration=-1
WARNING: Logging before InitGoogleLogging() is written to STDERR
I0731 06:04:12.194324   761 demo.hpp:752] DPU model size=512x512
terminate called after throwing an instance of 'cv::Exception'
  what():  OpenCV(4.5.2) /usr/src/debug/opencv/4.5.2-r0/git/modules/highgui/src/window_gtk.cpp:624: error: (-2:Unspecified error) Can't initialize GTK backend in function 'cvInitSystem'

Aborted


# La salida de la detección se muestra en el monitor del host


#CONTENIDO DE LA CARPETA /usr/share/vitis_ai_library/models/face_mask_detection_pt:
drwxr-xr-x   2 root root    4096 May 10  2023 .
drwxr-xr-x 145 root root   12288 May 10  2023 ..
-rw-r--r--   1 root root     559 May 10  2023 face_mask_detection_pt.prototxt
-rw-r--r--   1 root root 1357572 May 10  2023 face_mask_detection_pt.xmodel
-rw-r--r--   1 root root      33 May 10  2023 md5sum.txt
-rw-r--r--   1 root root     264 May 10  2023 meta.json


"lib": "libvart-dpu-runner.so",
    "filename": "face_mask_detection_pt.xmodel",
    "kernel": [
        "subgraph_Darknet__Darknet_FeatureConcat_module_list__ModuleList_118__Cat_cat__input_228"
    ],
    "target": "DPUCZDX8G_ISA1_B2304_0101000016010405
