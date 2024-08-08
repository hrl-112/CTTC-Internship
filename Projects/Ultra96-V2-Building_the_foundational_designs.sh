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
sed '112 a packagegroup-petalinux-jupyter\ ' -i ~/Avnet_2022_2/petalinux/u96v2_sbc_base_2022_2/roject-spec/meta-avnet/recipes-core/images/petalinux-image-minimal.bbappend
cd ~/Avnet_2022_2/petalinux/u96v2_sbc_base_2022_2
petalinux-build

# Once the build has finished we will reprogram the SD card using BalenaEtcher
balena

# We will power off the Ultra and will insert the SD card with the new image and power on again
# Login as petalinux
petalinux

# Launch the jupyter server. CAUTION: Your IP might be different
jupyter-lab --ip 10.1.2.198 & 

# On the host we copy one of the links (where says: "Or copy and paste one of these URLs:") the previous command outputs 
# This will open JupyterLab. We click on "Python3 (ipykernel)", copy the following code:
import matplotlib.pyplot as plt
import cv2
import numpy as np
from IPython.display import display, Image
import ipywidgets as widgets
import threading
# Stop button
# ================
stopButton = widgets.ToggleButton(
    value=False,
    description='Stop',
    disabled=False,
    button_style='danger', # 'success', 'info', 'warning', 'danger' or ''
    tooltip='Description',
    icon='square' # (FontAwesome names without the `fa-` prefix)
)

# Display function
# ================
def view(button):
    cap = cv2.VideoCapture(0)
    display_handle=display(None, display_id=True)
    i = 0
    while True:
        _, frame = cap.read()
        frame = cv2.flip(frame, 1) # if your camera reverses your image
        _, frame = cv2.imencode('.jpeg', frame)
        display_handle.update(Image(data=frame.tobytes()))
        if stopButton.value==True:
            cap.release()
            display_handle.update(None)

# Run
# ================
display(stopButton)
thread = threading.Thread(target=view, args=(stopButton,))
thread.start()



# And click the "Run" button to execute the code
