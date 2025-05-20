[![Publish Docker image](https://github.com/pfichtner/pfichtner-freetz/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/pfichtner/pfichtner-freetz/actions/workflows/docker-publish.yml)
[![Docker Image Version](https://img.shields.io/docker/v/pfichtner/freetz)](https://hub.docker.com/r/pfichtner/freetz/)
[![Docker Image Size](https://img.shields.io/docker/image-size/pfichtner/freetz)](https://hub.docker.com/r/pfichtner/freetz/)
[![Docker Pulls](https://img.shields.io/docker/pulls/pfichtner/freetz.svg?maxAge=604800)](https://hub.docker.com/r/pfichtner/freetz/)

# pfichtner-freetz
This is my version of a [Freetz(-NG)](https://github.com/Freetz-NG/freetz-ng) build environment. With this I am running builds to create various images (3270, 3370, 7570,7390, 7490, 7590) with various configs in a CI environment. 

## When and why to use it? 
- You don't want to mess up your linux system with all those prerequisites needed to build Freetz(-NG)
- You're using Windows: the easiest way to get a Freetz(-NG) build environment is by using the Docker image with WSL2.
- You don't wan't to download a full featured virtual machine image (which if there are new prerequisites you have them to integrate on your own which perhaps was the reason you started using the virtual machine image)
- The virtual machine image generates to much overhead (RAM/CPU/...)
- You need (love) fast startup times (milliseconds compared to seconds/minutes)

## How to use it? 
##### You could checkout inside a separate named volume (e.g. "freetz-workspace")
With this approach the files are not stored inside the "pfichtner/freetz build container" but a separate volume: 
```
# start docker container (will start /bin/bash)
docker run --rm -it -v freetz-workspace:/workspace pfichtner/freetz
# clone (checkout) the remote repo into the current directory (only needed once/the first time)
git clone https://github.com/Freetz-NG/freetz-ng.git
```

##### You could checkout inside the pfichtner/freetz container 
But if you delete the container (e.g. when updating to a newer version of it) you'll lose everything you put meanwhile in this container e.g. configs, (intermediate) build results! 
The first time start looks like: 
```
# start docker container (will start /bin/bash)
docker run -it pfichtner/freetz
# clone (checkout) the remote repo into the current directory (only needed once/the first time)
git clone https://github.com/Freetz-NG/freetz-ng.git
```

After exiting the container the container is stopped. You can resume it via ```docker start -i <containerid>``` (you can determine the containerid by executing ```docker ps -a```)

##### You could mount a directory on the host system to use inside the container
So all files checked out and generated during the build resides on the host system. 

To do this, "cd" into the directory with the checked out [Freetz(-NG)-repository](https://github.com/Freetz-NG/freetz-ng) and use the current directory ($PWD) as volume for the container and then execute the build there. Here comes the complete workflow:  
```
# necessary for the following clone
umask 0022
# clone (checkout) the remote repo
git clone https://github.com/Freetz-NG/freetz-ng.git
# cd into the cloned repo
cd freetz-ng
# start docker container (will start /bin/bash)
docker run --rm -it -v $PWD:/workspace pfichtner/freetz
```
(if you don't checkout Freetz(-NG) to the current directory replace $PWD with the path to the checked out repository)
Please note that the filesystem where Freetz(-NG) has been checked out has to be case-sensitive! 

**In all three cases you'll get a shell (bash) where you can work like your are in "a normal bash" like before, e.g. you now call call `make` then `make menuconfig` or any other command you like.** If you want to leave this shell, just type `exit` as usual. 


### Docker command/options explained
```docker run``` start a new container

```--rm``` remove (purge) that container after it terminates

```-it``` run in interactive mode/run in terminal mode

```-v $PWD:/workspace``` mount the current working directory of the host as /workspace inside the container

```-v a-volume-name:/workspace``` use the existing "a-volume-name"-volume or create it if it does not exist and use it as /workspace inside the container

```pfichtner/freetz``` the image to create the container from

## Environment variables
You can pass the following environment variables (using docker's ```-e``` parameters)
- ```BUILD_USER```  the username of the non-root user the entrypoint will switch to
- ```BUILD_USER_UID``` the uid of the ```BUILD_USER```. This should be the UID of your current user so that all files are read/write using the same UID that the user started the container. So ```-e BUILD_USER_UID=$(id -u)``` is a good option. 
- ```USE_UID_FROM``` Instead of passing in the UID the docker container uses the UID this file/directory belongs to
- ```BUILD_USER_HOME``` the home directory of the ```BUILD_USER```

If you don't pass in any of these environment variables the docker container will switch to a mode where ```BUILD_USER``` is ```builduser```, ```BUILD_USER_HOME``` is ```/workspace``` and ```BUILD_USER_UID``` is determined by the user that is owner of ```/workspace```. 

- ```AUTOINSTALL_PREREQUISITES``` By default Freetz-NG's prerequisites check is run and if there are missing prerequisites they get installed automatically. So even if the image is not uptodate you always should have a properly working build environment with all prerequisites installed. This feature will work only if the current working directory (```-w/--workdir```) contains a checked-out Freetz-NG. If Freetz-NG's script is not found this step is silently skipped as if it had been disabled. If you want to disable this feature in general set the environment variable to ```n```. 
This feature gets available with pfichtner-freetz:0.3.4

In my CI environment ([Jenkins](https://www.jenkins.io/)) I use the following: 

```docker run --rm -i -e BUILD_USER=builduser -e BUILD_USER_UID=$(id -u) -e BUILD_USER_HOME=/home/builduser -w /home/builduser -v $WORKSPACE:/home/builduser -v /var/lib/jenkins/download_cache:/home/builduser/dl pfichtner/freetz```

## Screencast
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

## Known problems
If you encounter a problem when unpacking the image this could be caused by a prlimit for the docker container of maximum number of open files. Please add then ```--ulimit=...```, e.g. ```docker run --rm -it --ulimit nofile=262144:262144 -v $PWD:/workspace pfichtner/freetz```. You can verify the NOFILE limits by calling ```prlimit```on the host and inside the docker container. (see https://github.com/pfichtner/pfichtner-freetz/issues/37 for details)

## Some hints if you're new to docker
- You can use docker on most linux/unix systems (and many other systems like Windows, too)
- Docker should be installable via the package manager of your distribution (dkpg/apt, rpm, yum, ...)
- When installing docker initially on your machine, the user you want to use docker for has to be member of the docker group ("docker" on ubuntu, could differ in other distros), so add the user to the "docker" group
- If you start an image (better said container) for the first time, the image is pulled from the remote docker repository ("dockerhub"). This could take a while but after that the image is cached on you machine and has not to be downloaded again
- If you want to update an image that already was downloaded you can use `docker pull pfichtner/freetz` to check for a newer image and update it
- When running on on a mac with arm cpu (M1/M2) pass ```--platform linux/amd64``` as additional argument to use x86 image

## Alternative to docker (podman)
pfichtner/freetz also runs using podman (which has advantages due to being daemenless so you don't have to add users to any groups)
```
podman run --userns keep-id --rm -it -v $PWD:/workspace docker.io/pfichtner/freetz
```
