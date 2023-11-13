# recompile_fmu

## When to use this script?

You have a [Functional Mockup Unit (FMU) 2.x](https://fmi-standard.org) that is missing binaries for you target system

## Precondition

Your FMU carries sources

## Limitations

In this first version, the sources must not use any third shared libraries

## How to use

### Linux

Simply run the following command:

```shell
./recompile.sh -f ./path/to/your/model.fmu -h ./path/to/fmi2headers_folder

# creates new FMU ./path/to/your/model_recompiled.fmu
```

Flags:


`-f` / `--fmu`: The absolute or relative path to your FMU you want to recompile

`-h` / `--headers`: The absolute or relative path to the folder that contains the FMI2 

### Windows

follows soon