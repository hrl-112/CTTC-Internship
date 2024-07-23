# CTTC-Internship
This repository will contain all the important stuff that has been done during the stay in CTTC.

## Open a serial port
| Command                                  | Description                                                                                                   |
| ---                                      | ---                                                                                                           |
|`sudo dmesg`                              | We visualize all the devices that are available                                                               |  
|`sudo gtkterm -p /dev/ttyUSB1 -s 115200 &`| Then we open the serial port taking into consideration the number of ttyUSBx that we have seen doing the dmesg|

## Install drivers for the JTAG cable
|          Command           | Description   |
|            ---             | --- |
|`cd ~/Xilinx/Vitis/2021.2/data/xicom/cable_drivers/lin64/install_script/install_drivers`| Once we have installed Vitis we go to this directory and execute the following commands:|
|`sudo ./setup_xilinx_ftdi`  | Setup for the FTDI            |
|`sudo ./install_digilent.sh`| Install the Digilent software |
|`sudo ./install_drivers`    | Install the drivers           |
|`sudo ./setup_pcusb`        | Setup for the USB usage       |
