# We create a directory
mkdir -p project-spec/meta-user/recipes-core/packagegroups

# And write the following in a .bb file:
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
