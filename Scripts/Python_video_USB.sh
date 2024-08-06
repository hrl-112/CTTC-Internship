## How to create a Python video using USB
## We just need to add the following to the Python script
echo "import cv2" > p.py
echo "# Open the camera" >> p.py
echo "cap = cv2.VideoCapture(0)" >> p.py
echo "# Set the resolution" >> p.py
echo "cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)" >> p.py
echo "cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)" >> p.py
echo "# Create a display window" >> p.py
echo 'cv2.namedWindow("USB Cam Passthrough", cv2.WINDOW_NORMAL)' >> p.py
echo "while True:" >> p.py
echo "    # Read a frame from the camera" >> p.py
echo "    ret, frame = cap.read()" >> p.py
echo "    if ret:" >> p.py
echo "        # Display the frame in the window" >> p.py
echo '        cv2.imshow("USB Cam Passthrough", frame)' >> p.py
echo "    # Check for key presses" >> p.py
echo "    key = cv2.waitKey(1)" >> p.py
echo "    if key == 27:   # Pressing the Esc key exits the program" >> p.py
echo "        break" >> p.py
echo "# Release the camera and destroy the display window" >> p.py
echo "cap.release()" >> p.py
echo "cv2.destroyAllWindows()" >> p.py
