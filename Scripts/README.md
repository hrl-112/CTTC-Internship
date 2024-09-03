## Open a serial port
| Command                                  | Description                                                                                                                                                                           |
| ---                                      | ---                                                                                                                                                                                   |
|`sudo dmesg`                              | We visualize all the devices that are available. Even though is a log file, this command is required to be executed before using the gtkterm to work properly. This seems to be a bug | 
|`sudo gtkterm -p /dev/ttyUSB1 -s 115200 &`| Then we open the serial port taking into consideration the number of ttyUSBx that we have seen doing the dmesg                                                                        |

## Install drivers for the JTAG cable
|          Command           | Description   |
|            ---             | --- |
|`cd ~/Xilinx/Vitis/2021.2/data/xicom/cable_drivers/lin64/install_script/install_drivers`| Once we have installed Vitis we go to this directory and execute the following commands:|
|`sudo ./setup_xilinx_ftdi`  | Setup for the FTDI            |
|`sudo ./install_digilent.sh`| Install the Digilent software |
|`sudo ./install_drivers`    | Install the drivers           |
|`sudo ./setup_pcusb`        | Setup for the USB usage       |

## Install NVIDIA driver
|          Command           | Description   |
|            ---             | --- |
|`ubuntu-drivers devices`    | In order to know what drivers are available we use this command. In our case, the output is what follows:|
                              == /sys/devices/pci0000:00/0000:00:01.0/0000:01:00.0 ==
                              modalias : pci:v000010DEd00001E93sv00001462sd000012BCbc03sc00i00
                              vendor   : NVIDIA Corporation
                              driver   : nvidia-driver-470-server - distro non-free
                              driver   : nvidia-driver-535-server - distro non-free
                              driver   : nvidia-driver-535-open - distro non-free
                              driver   : nvidia-driver-535-server-open - distro non-free recommended
                              driver   : nvidia-driver-470 - distro non-free
                              driver   : nvidia-driver-535 - distro non-free
                              driver   : nvidia-driver-450-server - distro non-free
                              driver   : xserver-xorg-video-nouveau - distro free builtin
`sudo apt install nvidia-driver-535-server-open` Finally, we install the recommended driver

## Create Python video USB
|          Command                                                             | Description                                                                                                    |
|            ---                                                               | ---                                                                                                            |  
|`echo "import cv2" > p.py`                                                    |We add the following commands to the created python script named "p" in order to be able to use the USB camera: |
|`echo "# Open the camera" >> p.py`                                            |                                                                                                                |
|`echo "cap = cv2.VideoCapture(0)" >> p.py`                                    |                                                                                                                |
|`echo "# Set the resolution" >> p.py`                                         |                                                                                                                |
|`echo "cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)" >> p.py`                       |                                                                                                                |
|`echo "cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)" >> p.py`                      |                                                                                                                |
|`echo "# Create a display window" >> p.py`                                    |                                                                                                                |
|`echo 'cv2.namedWindow("USB Cam Passthrough", cv2.WINDOW_NORMAL)' >> p.py`    |                                                                                                                |
|`echo "while True:" >> p.py`                                                  |                                                                                                                |
|`echo "    # Read a frame from the camera" >> p.py`                           |                                                                                                                |
|`echo "    ret, frame = cap.read()" >> p.py`                                  |                                                                                                                |
|`echo "    if ret:" >> p.py`                                                  |                                                                                                                |
|`echo "        # Display the frame in the window" >> p.py`                    |                                                                                                                |
|`echo '        cv2.imshow("USB Cam Passthrough", frame)' >> p.py`             |                                                                                                                |
|`echo "    # Check for key presses" >> p.py`                                  |                                                                                                                |
|`echo "    key = cv2.waitKey(1)" >> p.py`                                     |                                                                                                                |
|`echo "    if key == 27:   # Pressing the Esc key exits the program" >> p.py` |                                                                                                                |
|`echo "        break" >> p.py`                                                |                                                                                                                |
|`echo "# Release the camera and destroy the display window" >> p.py`          |                                                                                                                |
|`echo "cap.release()" >> p.py`                                                |                                                                                                                |
|`echo "cv2.destroyAllWindows()" >> p.py`                                      |                                                                                                                |

## Configure Ethernet static
|          Command                                             | Description                                                                                         |
|            ---                                               | ---                                                                                                 |
|`echo 'auto lo' >> /etc/network/interfaces`                   | In order to configure Ethernet in static mode we add the following commands to the"interfaces" file |
|`echo 'iface lo inet loopback' >> /etc/network/interfaces`    | The loopback network interface                                                                      |
|`echo '' >> /etc/network/interfaces`                          |                                                                                                     |
|`echo 'auto eth0' >> /etc/network/interfaces`                 | And the primary network interface                                                                   |
|`echo 'iface eth0 inet static' >> /etc/network/interfaces`    |                                                                                                     |
|`echo '    address 10.1.2.175' >> /etc/network/interfaces`    | Introduce the address to which we want to connect                                                   |
|`echo '    netmask 255.255.255.0' >> /etc/network/interfaces` | Introduce the netmask to which we want to connect                                                   |
|`echo '    gateway 10.1.2.1' >> /etc/network/interfaces`      | Introduce the gateway to which we want to connect                                                   |
|`sudo /etc/init.d/networking restart`                         | Finally we do a restart to apply the changes                                                        |

## Download and open BalenaEtcher from terminal
|          Command                                                                                         | Description                                         | 
|            ---                                                                                           | ---                                                 |
| `~Downloads`                                                                                             | We go to Downloads in order to install BalenaEtcher |
| `wget https://github.com/balena-io/etcher/releases/download/v1.19.21/balenaEtcher-linux-x64-1.19.21.zip` | Download the .zip file                              |
| `unzip balenaEtcher-linux-x64-1.19.21.zip`                                                               | Unzip the file                                      |
| `echo '~/Downloads/balenaEtcher-linux-x64-1.19.21/balenaEtcher-linux-x64/balena-etcher &' > ~/balena.sh` | Create a script to launch Balena                    | 
| `chmod +x ~/balena.sh`                                                                                   | Make the file created an executable                 |
| `export PATH=$PATH:~/`                                                                                   | Add home folder to PATH                             |
| `ln -s ~/balena.sh balena`                                                                               | Create a simbolic link called *balena*              |
| `balena`                                                                                                 | Open Balena from terminal                           |

## Create Package Groups
|          Command                                                                                         | Description                                         | 
|            ---                                                                                           | ---                                                 |
| `mkdir -p project-spec/meta-user/recipes-core/packagegroups`                                             | We create a directory                               |
| `echo '`                                                                                                      | Write the following in a .bb file:                  |
| `DESCRIPTION = "ULTRA96V2 ML inference app related packages"`                                              |    |
|`inherit packagegroup`                                                                                    |                                                            |
| `ULTRA96V2_ML_ACCEL_PACKAGES = " \` ||
| `      ap1302-ar1335-single-firmware \` ||
| `      dnf \` ||
| `      e2fsprogs-resize2fs \` ||
| `      parted \`||
| `      resize-part \`||
| `      packagegroup-petalinux-vitisai \` ||
| `      packagegroup-petalinux-vitisai-dev \` ||
| `      packagegroup-petalinux-gstreamer \` ||      
| `      cmake \`                                                                   ||
| `      libgcc \` ||
| `      gcc-symlinks \`                                                                       ||
| `      g++-symlinks \`                                                                           |              |
| `      binutils \`                                                                                ||
| `      xrt \`                                                                                    |                                                                    |
| `      xrt-dev \`                                                                                |                                                                    |
| `      zocl \`                                                                                   |                                                                    |
| `      opencl-clhpp-dev \`                                                                       |                                                                    |
| `      opencl-headers-dev \`                                                                     |                                                                    |
| `      packagegroup-petalinux-opencv \`                                                          |                                                                    |
| `      packagegroup-petalinux-opencv-dev \`                                                      |                                                                    |
| `      packagegroup-petalinux-v4lutils  \`                                                       |                                                                    |
| `      "`                                                                                        |                                                                    |
| `RDEPENDS_${PN} = "${ULTRA96V2_ML_ACCEL_PACKAGES}"`                                              |                                                                    |
| `' > project-spec/meta-user/recipes-core/packagegroups/packagegroup-ultra96v2-ml-accel.bb`       |                                                                    |
| `echo "CONFIG_packagegroup-ultra96v2-ml-accel" >> project-spec/meta-user/conf/user-rootfsconfig` | Add the custom packagegroup to the root file system configuration: |
| `echo "CONFIG_packagegroup-ultra96v2-ml-accel=y" >> project-spec/configs/rootfs_config`          |                                                                    |
