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
Now you have a bash where you can work like your are in "a normal bash" like before, e.g. you now call call "make", "make menuconfig" or any command you like. 

(if you don't checkout Freetz(-NG) to the current directory replace $PWD with the path to the checked out repository)

Here's a screencast where Freetz(-NG) is checked out and menuconfig and make are run in the container
<a href="http://pfichtner.github.io/pfichtner-freetz/checkout-on-host"><img src="https://pfichtner.github.io/pfichtner-freetz/asciinema-poster.png" /></a>

If you dont' want an interactive shell (bash) but run command directly you can pass them using "bash -c"
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
