# How to open a serial port from terminal.
sudo su
gtkterm -p /dev/ttyUSB1 -s 115200 &

# Here is a tip for using the gtktrem when debbuging:
# Once the gtkterm is open before doing anything, resize the window. 
# For short messages there is no problem but when this is not the case the gtkterm gets bugged and you can barely see what you are writing, personal experience.
