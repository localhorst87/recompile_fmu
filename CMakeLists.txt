cmake_minimum_required(VERSION 3.5)
project(recompile_fmu)

# Check if FMU name is set
if (NOT MODEL_IDENTIFIER)
    message(FATAL_ERROR "FMU model identifier must be set (to the model identifier FMU). Set -DMODEL_IDENTIFIER=your_model_id to set the model identifier.")
endif()

# Check if install location of the FMU is set 
if(NOT FMU_TARGET_LOCATION)
    set(FMU_TARGET_LOCATION "${CMAKE_CURRENT_SOURCE_DIR}")
    message(NOTICE "FMU target location is not given. FMU will be dropped to the CMake source directory. Set -DFMU_TARGET_LOCATION=/path/to/target/location to set the FMU location manually.")
endif()

# Check if FMI header files location is set
if(NOT FMI_HEADERS_LOCATION)
  message(FATAL_ERROR "No FMI export headers provided. Set -DFMI_HEADERS_LOCATION=/path/to/fmi/headers")
endif()

find_file(FMI2_FUNCTIONS_H "fmi2Functions.h"
          PATHS ${FMI_HEADERS_LOCATION}
          NO_DEFAULT_PATH,
          NO_CMAKE_FIND_ROOT_PATH)

if(NOT FMI2_FUNCTIONS_H)
  message(FATAL_ERROR "Could not find fmi2Functions.h in FMI_INTERFACE_HEADER_FILES_DIRECTORY=${FMI_INTERFACE_HEADER_FILES_DIRECTORY}")
endif()

# Source files
file(GLOB FMU_SOURCES ${CMAKE_CURRENT_BINARY_DIR}/fmu/sources/*.c)

# Set install prefix to FMU target system short and architecture
if(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
  set(FMU_TARGET_SYSTEM_NAME "win")
elseif(${CMAKE_SYSTEM_NAME} STREQUAL "Linux")
  set(FMU_TARGET_SYSTEM_NAME "linux")
elseif(${CMAKE_SYSTEM_NAME} STREQUAL "Darwin")
  set(FMU_TARGET_SYSTEM_NAME "darwin")
else()
  message(FATAL_ERROR "Unknown target system: ${CMAKE_SYSTEM_NAME}")
endif()

if (${CMAKE_SIZEOF_VOID_P} EQUAL 8)
    set(FMU_TARGET_PLATFORM "${FMU_TARGET_SYSTEM_NAME}64")
else()
    set(FMU_TARGET_PLATFORM "${FMU_TARGET_SYSTEM_NAME}32")
endif()

# Target library
add_library(${MODEL_IDENTIFIER} SHARED ${FMU_SOURCES})

# Add include directories
target_include_directories(${MODEL_IDENTIFIER} PUBLIC ${CMAKE_CURRENT_BINARY_DIR}/fmu/sources)
target_include_directories(${MODEL_IDENTIFIER} PRIVATE ${FMI_HEADERS_LOCATION})

# Override FMI2_FUNCTION_PREFIX
target_compile_definitions(${MODEL_IDENTIFIER} PRIVATE FMI2_OVERRIDE_FUNCTION_PREFIX)

# Configure output name of lib
set_target_properties(${MODEL_IDENTIFIER} PROPERTIES PREFIX "")

# Zip the FMU
add_custom_command(TARGET ${MODEL_IDENTIFIER}
	POST_BUILD
	COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_CURRENT_BINARY_DIR}/fmu/binaries/${FMU_TARGET_PLATFORM}"
	COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:${MODEL_IDENTIFIER}> "${CMAKE_CURRENT_BINARY_DIR}/fmu/binaries/${FMU_TARGET_PLATFORM}"
	COMMAND ${CMAKE_COMMAND} -E chdir "${CMAKE_CURRENT_BINARY_DIR}/fmu" ${CMAKE_COMMAND} -E tar "cfv" "${FMU_TARGET_LOCATION}/${MODEL_IDENTIFIER}_recompiled.fmu" --format=zip "${CMAKE_CURRENT_BINARY_DIR}/fmu/modelDescription.xml" "${CMAKE_CURRENT_BINARY_DIR}/fmu/sources" "${CMAKE_CURRENT_BINARY_DIR}/fmu/binaries")