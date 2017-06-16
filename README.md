# STVD-SDCC integration suite #
Here you can find a set of command line tools which can be used to add SDCC support to STVD IDE.
These tools are intended to enable STM8 software development with SDCC in STVD.


# Current project status #
This project was an experiment. The toolset now can be used to build a project in STVD with SDCC.

Unfortunately ST-s version of GDB does not support SDCC-s debug info, so debuging is not available :(

More info on this issue is [here](https://github.com/shkolnick-kun/stvd-sdcc/issues/2).

# Dependencies #
Things, needed to build the toolset: 
* [win flex and bison](https://sourceforge.net/projects/winflexbison/) are needed to build.
* Code::Blocks IDE with mingw32.

Things, neede to run the toollset
* STVD
* SDCC with STM8 support.


