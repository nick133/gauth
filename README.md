# gauth
Simple Google TOTP Authentificator CLI witten in pure NIM.

## Configuration
Look at example INI file, it is self explaining.

## Usage
* Run with no args for interactive mode.
  `gauth`

* Run with provider name same as key name in "providers" section in config. Generated code will be printed out without any additional messages. Also partial name could be used and it is case insensitive, i.e. for the name "Binance" use "binance", "bin" or even "b" if no other name exists beginning with "b".
  `gauth bin`

* -h, --help : for help
* -p, --pause : pause before quit in interactive mode

## Build
* For optimized stripped binary build run:
  `nimble release`

* For debug build run:
  `nimble build`

## Requirements
* NIM
* Nimble
* GCC

In Arch Linux just run: `sudo pacman -S nim nimble gcc`

