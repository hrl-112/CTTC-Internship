# Creating a Vitis-AI GStreamer Plugin for the Ultra96-V2
# This project is made by *Tom Simpson*
# https://www.hackster.io/dsp2/creating-a-vitis-ai-gstreamer-plugin-for-the-ultra96-v2-616a79

# ********************************************************************
# Part 1: Project setup
# ********************************************************************

# First of all, we install GStreamer
sudo apt-get -y install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-gtk3 gstreamer1.0-qt5 gstreamer1.0-pulseaudio

# Create a project directory of your choosing (i.e. ~/gst_plugin_tutorial) and create an environment variable that points to that location.

mkdir ~/gst_plugin_tutorial
export GST_PROJ_DIR=~/gst_plugin_tutorial

# Clone this tutorial's repository from the Avnet GitLab server

cd $GST_PROJ_DIR
git clone https://xterra2.avnet.com/xilinx/ml/vai-gst-plugin-tutorial


# ********************************************************************
# Part 2: Setting up the Linux host cross-compilation environment
# ********************************************************************

# Download and extract the common PetaLinux SDK

wget https://www.xilinx.com/bin/public/openDownload?filename=sdk-2020.1.0.0.sh -O sdk-2020.1.0.0.sh 
sh -x sdk-2020.1.0.0.sh -d ~/petalinux_sdk_2020.1 -y

# Create an environment variable that points to the cross-compilation target root file system.

export SYSROOT=~/petalinux_sdk_2020.1/sysroots/aarch64-xilinx-linux

# Source the cross-compilation environment setup script

unset LD_LIBRARY_PATH
source $SYSROOT/../../environment-setup-aarch64-xilinx-linux

# Download the Vitis-AI package

wget https://www.xilinx.com/bin/public/openDownload?filename=vitis_ai_2020.1-r1.2.0.tar.gz -O vitis_ai_2020.1-r1.2.0.tar.gz

# Install the Vitis-AI package in the cross-compilation environment

tar -xvzf vitis_ai_2020.1-r1.2.0.tar.gz -C $SYSROOT

# ********************************************************************
# Part 3: Creating and cross-compiling the GStreamer plugin
# ********************************************************************

# Clone the GStreamer plugins-bad repository

git clone https://github.com/GStreamer/gst-plugins-bad.git

# Create the face detection plugin from the video filter template

mkdir -p vaifacedetect 
cd vaifacedetect
../gst-plugins-bad/tools/gst-element-maker vaifacedetect videofilter
rm *.so *.o
mv gstvaifacedetect.c gstvaifacedetect.cpp

# The following command will delete the lines of code that set the transform_frame function in the class_init() function.

sed -i '/video_filter_class->transform_frame = /d' gstvaifacedetect.cpp

# Add the OpenCV and Vitis-AI-Library header files to gstvaifacedetect.cpp

sed '41 a /* OpenCV header files */' -i gstvaifacedetect.cpp
sed '42 a #include <opencv2/core.hpp>' -i gstvaifacedetect.cpp
sed '43 a #include <opencv2/opencv.hpp>' -i gstvaifacedetect.cpp
sed '44 a #include <opencv2/highgui.hpp>' -i gstvaifacedetect.cpp
sed '45 a #include <opencv2/imgproc.hpp>' -i gstvaifacedetect.cpp
sed '46 a \\' -i gstvaifacedetect.cpp

sed '47 a /* Vitis-AI-Library specific header files */' -i gstvaifacedetect.cpp
sed '48 a #include <vitis/ai/facedetect.hpp>' -i gstvaifacedetect.cpp
sed '49 a \\' -i gstvaifacedetect.cpp

sed 's/I420, Y444, Y42B, UYVY, RGBA/BGR/' -i gstvaifacedetect.cpp

sed 's/gst_caps_from_string (VIDEO_SRC_CAPS)/gst_caps_from_string (VIDEO_SRC_CAPS ", width = (int) [1, 640], height = (int) [1, 360]")/' -i gstvaifacedetect.cpp
sed 's/gst_caps_from_string (VIDEO_SINK_CAPS)/gst_caps_from_string (VIDEO_SINK_CAPS ", width = (int) [1, 640], height = (int) [1, 360]")/' -i gstvaifacedetect.cpp
sed 's/"FIXME Long name", "Generic", "FIXME Description"/"Face detection using the Vitis-AI-Library", "Video Filter", "Face Detection"/' -i gstvaifacedetect.cpp

sed '232 a  \\  /* Create face detection object */\n  thread_local auto face = vitis::ai::FaceDetect::create("densebox_640_360");\n\n  /* Setup an OpenCV Mat with the frame data */\n  cv::Mat img(360, 640, CV_8UC3, GST_VIDEO_FRAME_PLANE_DATA(frame, 0));\n\n  /* Perform face detection */\n  auto results = face->run(img);\n\n  /* Draw bounding boxes */\n  for (auto &box : results.rects)\n  {\n    int xmin = box.x * img.cols;\n    int ymin = box.y * img.rows;\n    int xmax = xmin + (box.width * img.cols);\n    int ymax = ymin + (box.height * img.rows);\n\n    xmin = std::min(std::max(xmin, 0), img.cols);\n    xmax = std::min(std::max(xmax, 0), img.cols);\n    ymin = std::min(std::max(ymin, 0), img.rows);\n    ymax = std::min(std::max(ymax, 0), img.rows);\n\n    cv::rectangle(img, cv::Point(xmin, ymin), cv::Point(xmax, ymax), cv::Scalar(0, 255, 0), 2, 1, 0);\n  }' -i gstvaifacedetect.cpp

sed 's/#define VERSION "0.0.FIXME"/#define VERSION "0.0.0"/' -i gstvaifacedetect.cpp
sed 's/#define PACKAGE "FIXME_package"/#define PACKAGE "vaifacedetect"/' -i gstvaifacedetect.cpp
sed 's/#define PACKAGE_NAME "FIXME_package_name"/#define PACKAGE_NAME "GStreamer Xilinx Vitis-AI-Library"/' -i gstvaifacedetect.cpp
sed 's/FIXME.org/xilinx.com/' -i gstvaifacedetect.cpp
sed 's/"FIXME plugin description",/"Face detection using the Xilinx Vitis-AI-Library",/' -i gstvaifacedetect.cpp

# Compile the plugin using the make file provided in the Avnet GitLab repo cloned in Part 1

sudo apt-get -y install gcc-aarch64-linux-gnu
sudo apt-get -y install g++-aarch64-linux-gnu

cd $GST_PROJ_DIR/vaifacedetect
make -f $GST_PROJ_DIR/vai-gst-plugin-tutorial/solution/vaifacedetect/Makefile

# CAUTION: The steps end here due to from this point is required an image which has been made considering the use of Wi-Fi.
# And because of Ultra was made between the period of time in which Ultras had their Wi-Fi chip defective, when you run the image on Ultra a message saying that Wi-Fi was searched but not found
# is displayed and do not let you to continue. If it is not your case you can follow the last steps:

# From host:
cd $GST_PROJ_DIR
scp vaifacedetect/libgstvaifacedetect.so root@$TARGET_IP:/usr/lib/gstreamer-1.0/.

wget https://raw.githubusercontent.com/Xilinx/Vitis_Embedded_Platform_Source/2019.2/Xilinx_Official_Platforms/zcu104_dpu/petalinux/project-spec/meta-user/recipes-ai/dpuclk/files/dpu_clk -O ~/dpu_clk.py
python3 ~/dpu_clk.py 50

export DISPLAY=:0.0
xrandr --output DP-1 --mode 640x480

gst-launch-1.0 -v \
  v4l2src device=/dev/video0 ! \
  video/x-raw, width=640, height=360, format=YUY2, framerate=30/1 ! \
  queue ! \
  videoconvert ! \
  video/x-raw, format=BGR ! \
  queue ! \
  vaifacedetect ! \
  queue ! \
  videoconvert ! \
  fpsdisplaysink sync=false text-overlay=false fullscreen-overlay=true

