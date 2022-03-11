[![Publish Docker image](https://github.com/pfichtner/pfichtner-freetz/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/pfichtner/pfichtner-freetz/actions/workflows/docker-publish.yml)
[![Docker Pulls](https://img.shields.io/docker/pulls/pfichtner/freetz.svg?maxAge=604800)](https://hub.docker.com/r/pfichtner/freetz/)

# pfichtner-freetz
This is my version of a [Freetz(-NG)](https://github.com/Freetz-NG/freetz-ng) build environment. With this I am running builds to create various images (3270, 3370, 7570,7390, 7490, 7590) with various configs in a CI environment. 

To do this, "cd" into the directory with the checked out [Freetz(-NG)-repository](https://github.com/Freetz-NG/freetz-ng) and use the current directory ($PWD) as volume for the container and then execute the build there. Here comes the complete workflow:  
```
umask 0022 # needed fot the following clone
git clone https://github.com/Freetz-NG/freetz-ng.git
docker run --rm -it -v $PWD:/workspace pfichtner/freetz"
```
**Now you have a shell (bash) where you can work like your are in "a normal bash" like before, e.g. you now call call `make` then `make menuconfig` or any other command you like.** If you want to leave this shell, just type `exit` as usual. 

(if you don't checkout Freetz(-NG) to the current directory replace $PWD with the path to the checked out repository)

Here's a screencast where Freetz(-NG) is checked out and menuconfig and make are run in the container
<a href="http://pfichtner.github.io/pfichtner-freetz/checkout-on-host"><img src="https://pfichtner.github.io/pfichtner-freetz/asciinema-poster.png" /></a>

If you dont' want an interactive shell (bash) but run command directly you can pass them using `bash -c`
```
docker run --rm -it -v $PWD:/workspace pfichtner/freetz /bin/bash -c "make menuconfig && make"
```

If you don't want or can't clone the Freetz(-NG) repository using your local machine you can do this also using inside docker container (but having the files outside of the container thus the machine you are running docker on)
```
mkdir ~/some-empty-directory-for-freetz
docker run --rm -v ~/some-empty-directory-for-freetz:/workspace pfichtner/freetz \
  /bin/bash -c "git clone https://github.com/Freetz-NG/freetz-ng.git . && make menuconfig && make"
```
And here's a screencast for this

<a href="http://pfichtner.github.io/pfichtner-freetz/checkout-in-container"><img src="https://pfichtner.github.io/pfichtner-freetz/asciinema-poster.png" /></a>

Of course in a CI environment you don't want to do ```menuconfig``` since it's a fully automated build. That's where I am using ```oldconfig```: 
```
docker run --rm -v $PWD:/workspace pfichtner/freetz /bin/bash -c "make oldconfig && make"
```

## Some hints if you're new to docker
- You can use docker on most linux/unix systems (and many other systems like Windows, too)
- Docker should be installable via the package manager (dkpg/apt, rpm, yum, ...) of your distribution
- When installig docker initially on your machine, the user you want to use docker for has to be member of the docker group ("docker" on ubuntu, could differ in other distros), so add the user to the "docker" group
- If you start a image (better said container) the first time, the image is pulled from the remote docker repository ("dockerhub"). This could take a while but after that the image is cached on you machine and has not to be downloaded again
- If you want to update an image that already was downloaded you can use `docker pull <imagenamw`> to check for a newer image and update it
