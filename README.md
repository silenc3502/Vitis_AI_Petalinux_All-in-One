# Dockerfile for Vitis AI & PetaLinux All-in-One

This is a Vitis AI & PetaLinux All-in-One docker file for UltraScale MPSoC.  
You need to download petalinux 2019.2 and Vitis 2019.2 from Xilinx.  

I use Most Recent Notebook.  
It doesn't properly work on Ubuntu 16.04 & 18.04.  
So I use Ubuntu 20.04 and Docker for development FPGA.  

Use everything with Docker!  

## Preparation
```
Docker Tools
- You can install with apt-get
PetaLinux 2019.2
- https://www.xilinx.com/member/forms/download/xef.html?filename=petalinux-v2019.2-final-installer.run
Vitis A.I 2019.2
- https://www.xilinx.com/member/forms/download/xef-vitis.html?filename=Xilinx_Vitis_2019.2_1106_2127.tar.gz
AVNET Board Definition File
- You need Board Definition File for Vivado
- Download it to *.zip
- https://github.com/Avnet/bdf
Xilinx Run-Time(XRT)
- It's on the repo
- https://www.xilinx.com/bin/public/openDownload?filename=xrt_201920.2.3.1301_18.04-xrt.deb
Xilinx License File
- You can download or request it to Xilinx
- https://www.xilinx.com/getlicense
Finally Time
- You need many times for install Vitis Tools & PetaLinux
```

## How to accelerate download
```
# aria2c -m 10 -s 10 -x 10 -o petalinux-v2019.2-final-installer.run <petalinux link>
```

## Must Do it
```
$ python3 -m http.server

You have to do it to make local:8000 to package server
Start upon command with your preparation sets existance directory
```

## Building docker image
```
input $(USR) results of [ who -m | awk `{print $1}' ]

$ docker build --build-arg b_uid=`id -u $(USR)` --build-arg b_gid=`id -g $(USR)` --build-arg PETALINUX_INSTALLER=petalinux-v2019.2-final-installer.run --build-arg VITIS_TAR_HOST=<your IP Address>:8000 --build-arg VITIS_TAR_FILE=Xilinx_Vitis_2019.2_1106_2127 --build-arg VITIS_VERSION=2019.2 -t vitis_2019_2 .
```

## Run docker container
```
$ docker run -it -v <your directory>:/home/vivado/workshop vitis_2019_2
```

## Run docker container with Connectable UART
```
$ docker run -it --device=/dev/ttyUSB0:/dev/ttyUSB0 -v <your directory>:/home/vivado/workshop vitis_2019_2
```

## Run docker container with GUI
```
$ docker run -ti --rm -e DISPLAY=$DISPLAY --net="host" -v /tmp/.X11-unix:/tmp/.X11-unix -v $HOME/.Xauthority:/home/vivado/.Xauthority -v <your directory>:/home/vivado/workshop vitis_2019_2
```

## How to Know What Commands are Currently Running on Docker
```
$ docker ps --no-trunc
```
