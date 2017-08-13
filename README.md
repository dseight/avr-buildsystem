# avr-buildsystem

Template for AVR Makefile-based build system.
Most of the code is taken from the QEMU build system.

## Usage

First of all you need to change `config.mak` to meet your requirements:
- specify device (you can get list of supported devices by using `avr-gcc --target-help`)
- configure device clock
- set avrdude's programmer type to use `make flash` command

Then just add all files that you want to compile to the `obj-y` variable.

*That's all!*

If you want to have some special compiler flags on one or a few files
(i.e. you do not want to have this flags on the whole project), then
you can specify them using the following pattern:

    filename.o-cflags = your_flags

## Example

E.g. you have the following project structure:

    project/
    ├── Makefile
    ├── config.mak
    ├── main.c
    ├── i2c/
    │   ├── i2c.c
    │   └── i2c.h
    └── spi/
        ├── spi.c
        └── spi.h

To compile this, your Makefile should contain following lines:

    obj-y += i2c/i2c.o
    obj-y += spi/spi.o
    obj-y += main.o

If you want add some special flags to i2c.o (e.g. disable missing prototypes
warnings), you should add following line to your Makefile:

    i2c/i2c.o-cflags = -Wno-missing-prototypes
