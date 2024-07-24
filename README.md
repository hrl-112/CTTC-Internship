# CTTC-Internship
This repository will contain all the important stuff that has been done during the stay in CTTC.

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
