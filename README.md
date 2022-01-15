[![Publish Docker image](https://github.com/pfichtner/pfichtner-freetz/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/pfichtner/pfichtner-freetz/actions/workflows/docker-publish.yml)
[![Docker Pulls](https://img.shields.io/docker/pulls/pfichtner/freetz.svg?maxAge=604800)](https://hub.docker.com/r/pfichtner/freetz/)

# pfichtner-freetz
This is my version of a [Freetz(-NG)](https://github.com/Freetz-NG/freetz-ng) build environment. With this I build various images (3270, 3370, 7570,7390, 7490, 7590) with various configs in a CI environment. 

To do this, I add the directory with the checked out repository as a volume into the container and then execute the build there: 
```
docker run --rm -v $PWD:/workspace pfichtner/freetz /bin/bash -c "make menuconfig && make"
```
(if you don't checkout Freetz(-NG) to the current directory replace $PWD with the path to the checked out repository)


Of course in my CI environment I don't want to do ```menuconfig``` since it's a fully automated build. I use ```oldconfig``` here: 
```
docker run --rm -v $PWD:/workspace pfichtner/freetz /bin/bash -c "make oldconfig && make"
```
