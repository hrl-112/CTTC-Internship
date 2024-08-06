# This is the way to compile models for using the DPU of the Ultra96-V2
# This script is based on the tutorial *Creating a Custom Kria App* by *albertabeef (Mario Bergeron)*
# https://community.element14.com/technologies/fpga-group/b/blog/posts/kv260-vvas-sms-2021-1-blog
# Take note that this script is the continuation of the previous projects in order to put into practice the DPU
# Here is the link to see what dockers from xilinx vitis-ai are available:
# https://hub.docker.com/r/xilinx/vitis-ai/tags

sudo apt  install docker.io

cd ~/Avnet_2022_2/
git clone -b 3.0 https://github.com/Xilinx/Vitis-AI.git

cd ~/Avnet_2022_2/Vitis-AI/model_zoo

wget https://raw.githubusercontent.com/Avnet/vitis/2021.1/app/zoo/compile_modelzoo.sh 

sed 's/vitis_ai_library\/models/models.b2304/' -i ~/Avnet_2022_2/Vitis-AI/model_zoo/compile_modelzoo.sh 

sed 's/..\/cache\/AI-Model-Zoo-v1.4/cache/' -i ~/Avnet_2022_2/Vitis-AI/model_zoo/compile_modelzoo.sh

cp ~/Avnet_2022_2/avnet-vitis-platforms/u96v2/overlays/examples/benchmark/binary_container_1/sd_card/arch.json ~/Avnet_2022_2/Vitis-AI/model_zoo

mkdir -p cache
mkdir -p models.b2304

mv model-list model-list-backup
mkdir model-list
cd model-list

cp -r ../model-list-backup/pt_face-mask-detection_512_512_0.67G_3.0 .

cd ~/Avnet_2022_2/Vitis-AI
sudo ./docker_run.sh xilinx/vitis-ai:latest

cd model_zoo/
source ./compile_modelzoo.sh

# We get out from docker
exit

cd models.b2304

# Once the model is compile we pass it to the Ultra:
# CAUTION: Note that the root@xx.x.x.xxx might be different for you
scp -rp face_mask_detection_pt/ root@10.1.2.198:/usr/share/vitis_ai_library/models/

