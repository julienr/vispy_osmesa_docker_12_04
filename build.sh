#!/bin/bash
IMAGE="osmesa_12_04"
OUTDIR="$PWD/_out"
ARCHIVENAME="osmesa.tar.bz2"
#sudo docker build -t="jrebetez/vispy_osmesa_builder_12_04:latest" .
sudo docker build -t=$IMAGE .

# Build archive of /opt/osmesa_llvmpipe
mkdir -p $OUTDIR
sudo docker run --rm -it -v $OUTDIR:/mnt/out:rw $IMAGE \
    tar -cvjf /mnt/out/$ARCHIVENAME -C /opt/osmesa_llvmpipe .

echo "Archive created as $OUTDIR/$ARCHIVENAME"
