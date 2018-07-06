# Debian Docker image

Small script to build Docker images of *legacy* Debian releases.

## Introduction

### Motivation

Running legacy software is often an issue and raises security concerns. Especially when this requires the use of an outdated operating system. Containerization might be an appropriate answer to such situations, in order to reduce the exposed surface of software that reached their end-of-life.

### Inspiration

This script is inspired on the [nice script](https://gist.github.com/lpenz/8d2555bca4fc20ba0118) written by [Leandro Lisboa Penz](https://gist.github.com/lpenz). 

My script has mainly two advantages:
- it generates smaller (i.e. 65.2MB instead 148MB for Debian Etch, 56% smaller!).
- itcan be used on any platform that has *sh* and *Docker* (no need to install debootstrap to use it).


### Implementation

Sadely building Debian images directly with a Dockerfile using debootstrap isn't possible. Docker build cannot be done in *privileged mode* [[1]](https://unix.stackexchange.com/questions/305430/build-docker-image-in-privileged-mode).
Due to that this repo doesn't contain any `Dockerfile`, but a simple shell script named `debian-docker-image.sh`.

This script might be run on any machine that has an *sh-compatible* shell and Docker installed.


## Pull an image

To get *Debian Etch*:

    docker pull feverch/debian:4

To get *Debian Lenny*:

    docker pull feverch/debian:5

## Build an image

To build a *Debian Etch* image:

    ./debian-docker-image.sh etch feverch/debian:4

To build a *Debian Lenny* image:

    ./debian-docker-image.sh lenny feverch/debian:5

## Improvements

I'm pretty sure that this script can be improved, pull-requests are welcome.

## License
 
This software is licensed under the Apache 2 license, quoted below.

Copyright 2018 Raphaël P. Barazzutti

Licensed under the Apache License, Version 2.0 (the "License"); you may not
use this file except in compliance with the License. You may obtain a copy of
the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
License for the specific language governing permissions and limitations under
the License.