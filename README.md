[![Publish Docker image](https://github.com/pfichtner/pfichtner-freetz/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/pfichtner/pfichtner-freetz/actions/workflows/docker-publish.yml)

# pfichtner-freetz
This is my version of a [Freetz(-NG)](https://github.com/Freetz-NG/freetz-ng) build environment. With this I build various images (3270, 3370, W920V (7570) ,7390, 7490, 7590) with various configs in a CI environment. 

To do this, I add the directory with the checked out repository as a volume into the container and then execute the build there: 
```
docker run --rm -v $PWD:/workspace pfichtner/freetz /bin/bash -c make oldconfig && make
```
(if you don't checkout Freetz(-NG) to the current directory replace $PWD with the path to the checked out repository)
