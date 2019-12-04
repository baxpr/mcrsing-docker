#!/bin/sh
#
# After the mcrsing image is built, here is how to run it.
#
# To get a license file:
# https://www.mathworks.com/matlabcentral/answers/259627-how-do-i-activate-matlab-without-an-internet-connection
#
# Alternatively, activate MATLAB manually inside the container (specify root user):
#   /usr/local/MATLAB/R2019b/bin/activate_matlab.sh

# We can specify a particular MAC address
MAC=02:42:ac:11:00:02
SMAC=`echo $MAC | tr -d \:`

# We can bind a license file
LIC=`pwd`/license.lic

# Working directory to transfer files between container and host. Before calling
# this script, can set to a fully qualified path like
#    export WORKDIR=/path/to/wherever
if [ "${WORKDIR}" == "" ] ; then 
	WORKDIR=`pwd`
fi

# Set up X11
xhost + 127.0.0.1

# Make the container and get a shell
docker run -it --rm \
    -e DISPLAY=host.docker.internal:0 \
    --mount type=bind,src=${LIC},dst=/usr/local/MATLAB/R2019b/licenses/license.lic \
    --mount type=bind,src=${WORKDIR},dst=/workdir \
    --mac-address $MAC \
    mcrsing_${SMAC} bash

# Clean up X11
xhost - 127.0.0.1

