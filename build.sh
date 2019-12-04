#/bin/sh

# First build a docker image with the MATLAB Compiled Runtime. Automatic install 
# is straightforward for this.
echo Building docker
docker build -f dockermatlab.Dockerfile -t mcrsing .

# We will create a docker volume with the MATLAB install file, starting with 
# the distributed ISO. MATLAB_ISO_DIR on the host should contain the file 
#     R2019b_Linux.iso
MATLAB_ISO_DIR=~/Downloads

# Create a container with the MATLAB install ISO mounted, and copy the install
# files from there to a newly created volume matiso2019b. This requires privileged 
# mode but is handy because not specific to the host OS.
echo Creating Matlab install volume
files=`docker run --rm -i -v=matiso2019b:/matiso2019b mcrsing ls /matiso2019b`
if [ "$files" == "" ] ; then
    docker run -it --rm --name tmp --privileged \
        --mount type=volume,src=matiso2019b,dst=/matiso2019b \
        --mount type=bind,src=${MATLAB_ISO_DIR},dst=/MATLAB_ISO \
	    mcrsing /bin/bash -c "\
        mkdir -p /mnt/disk1 && \
        mount -t iso9660 -o loop /MATLAB_ISO/R2019b_Linux.iso /mnt/disk1 && \
        cp -R /mnt/disk1/* /matiso2019b && \
	    chmod -R +w /matiso2019b "
fi

# Check that the files are in our volume now
echo Checking volume
docker run -it --rm -v=matiso2019b:/matiso2019b mcrsing ls /matiso2019b


# New container where we will install matlab. Run the MATLAB install.
# https://www.mathworks.com/matlabcentral/answers/259627-how-do-i-activate-matlab-without-an-internet-connection
# Keep the license file on the host and mount at run, instead of installing it 
# in the container/image.
MAC=02:42:ac:11:00:02
SMAC=`echo $MAC | tr -d \:`
INST=`pwd`/installer_input.txt
docker run -it --name matsing_${SMAC} \
    --mount type=volume,src=matiso2019b,dst=/matiso2019b \
    --mount type=bind,src=${INST},dst=/tmp/installer_input.txt \
    --mac-address $MAC \
	mcrsing /bin/bash -c "\
    /matiso2019b/install -inputFile /tmp/installer_input.txt && \
	MATLAB=`grep destinationFolder installer_input.txt | \
      awk -F \= '$1=="destinationFolder" {print $2}'` "

# Commit the container and save a backup
docker commit matsing_${SMAC} matsing_${SMAC}
docker save matsing_${SMAC} -o matsing_${SMAC}_docker.tar
