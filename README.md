# MATLAB/singularity docker image for OS X

The goal is to create a docker image that can be run on OS X for the following purposes:
  - Test a MATLAB, SPM, FSL analysis pipeline
  - Compile a MATLAB pipeline into a standalone executable
  - Create a singularity image for an analysis pipeline

The image contains
  - MATLAB R2019b
  - MATLAB Compiled Runtime for 2019b
  - Singularity 3.4.1
  
## Prerequisites

### Obtain the installation ISOs for MATLAB R2019b

1. See https://www.mathworks.com/help/install/ug/download-only.html. For VUIIS members, see https://sharepoint-ext.app.vumc.org/research/VUIIS/IT/IT%20Wiki/Home.aspx (login required). The Linux version is required, and note that several parts of the scripts are specific to R2019b.
2. Rename the ISO file as `R2019b_Linux.iso` if it is not already and place it in some directory.
3. Edit the file `build.sh` to place the name of the directory containing the MATLAB install ISO on the `MATLAB_ISO_DIR=` line.

### Obtain a MATLAB license file and file installation key:
See https://www.mathworks.com/matlabcentral/answers/259627-how-do-i-activate-matlab-without-an-internet-connection

1. Save the license file in the build directory as `license.lic`. This is used at runtime.

2. Rename the file `installer_input.txt.template` to `installer_input.txt` and add the file installation key on the `fileInstallationKey=` line.

3. The desired MAC address of the container must be specified in `build.sh` on the `MAC=` line.

## Building the image

The entire process is performed by `build.sh`. MATLAB is installed but not activated, so the license file is not included in the resulting image.

- A docker image with everything except MATLAB proper is built from the Dockerfile `mcrsing.Dockerfile`.

- The MATLAB installation files on the install ISOs are extracted to a docker volume.

- A new container is created and the MATLAB noninteractive installation process is run.

- The new container is committed as an image.

- The docker volume with MATLAB install files (matiso2019b) is no longer needed, but isn't automatically deleted in case it might be useful later. It can be manually removed with `docker volume rm matiso2019b` to save disk space.

## Running the image

The MATLAB license file must be mounted when the image is run. This and a workaround for X11 on OS X (`xhost + 127.0.0.1`) are accomplished in `run.sh`.

