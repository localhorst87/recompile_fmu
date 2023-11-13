#!/bin/bash

POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    -f|--fmu)
      FMU_PATH="$2"
      shift
      shift
      ;;
    -h|--headers)
      FMI_HEADERS="$2"
      shift
      shift
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1")
      shift
      ;;
  esac
done

if [ -z $FMI_HEADERS ]; then echo "Error: Path to the FMI2 Headers folder is missing, use -h or --headers"; exit 1; fi
if [ -z $FMU_PATH ]; then echo "Error: Path to input FMU is missing, use -f or --fmu"; exit 1; fi
if [ ! -e $FMU_PATH ]; then echo "Error: Given FMU does not exist"; exit 1; fi

fmu_file_name=${FMU_PATH##*/}
fmu_folder=${FMU_PATH%/*}

if [[ ! ${fmu_folder: 0:1} = / ]];
  then
    fmu_folder=$(pwd)/$fmu_folder
fi

if [[ ${fmu_folder: -1} = / ]];
  then
    fmu_folder=${fmu_folder: 0:-1}
fi

mkdir recompile_fmu_tmp
unzip -d ./recompile_fmu_tmp/fmu $FMU_PATH

cd recompile_fmu_tmp
cmake -DMODEL_IDENTIFIER=${fmu_file_name: 0:-4} -DFMU_TARGET_LOCATION=$fmu_folder -DFMI_HEADERS_LOCATION=$FMI_HEADERS ..
make

cd ..
rm -rf recompile_fmu_tmp