cmake_minimum_required(VERSION 3.30)

# This is a custom build of OGDF v1.2.0
project(OGDF-TMAP-PROJECT VERSION 1.2.0 LANGUAGES CXX)

# Ensure the OGDF library and its dependencies are built as shared libraries.
# This is so we don't suffer from LGPL of OGDF.
# This globally switches from static to shared libraries
set(BUILD_SHARED_LIBS ON CACHE BOOL "Build using shared libraries by default")

set(module_dir "${PROJECT_SOURCE_DIR}/cmake")
list(INSERT CMAKE_MODULE_PATH 0 "${module_dir}")

# Define a common directory for all distributable artefacts
set(OUTPUT_DIR "${CMAKE_BINARY_DIR}/dist")

# Set the output directory for shared libraries (.so, .dylib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${OUTPUT_DIR}/lib")

# Set the output directory for static libraries (.a, .lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${OUTPUT_DIR}/lib")

# Optional: Set for different configurations (e.g., Debug, Release)
foreach(CONFIG_TYPE Debug Release)
  set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_${CONFIG_TYPE} "${OUTPUT_DIR}/lib/${CONFIG_TYPE}")
  set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_${CONFIG_TYPE} "${OUTPUT_DIR}/lib/${CONFIG_TYPE}")
endforeach()

if(DEFINED ENV{ARCHFLAGS})
  # Parse the cibuildwheel ARCHFLAGS env variable as something we can understand on
  #  OSX, initially.
  string(REPLACE "-arch " "" NEW_ARCHFLAGS $ENV{ARCHFLAGS})
  string(REPLACE " " ";" NEW_ARCHFLAGS "${NEW_ARCHFLAGS}")

  # The following, CMAKE_OSX_ARCHITECTURES, is ignored on non-osx platforms
  set(CMAKE_OSX_ARCHITECTURES "${NEW_ARCHFLAGS}")
endif(DEFINED ENV{ARCHFLAGS})

# build type configuration
set(BUILD_TYPES Debug Release)
if(CMAKE_CONFIGURATION_TYPES)
  set(MULTICONFIG_BUILD 1)
  set(CMAKE_CONFIGURATION_TYPES ${BUILD_TYPES} CACHE STRING "" FORCE)
else()
  set(MULTICONFIG_BUILD 0)
  if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Type of build to be created." FORCE)
  endif()
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS ${BUILD_TYPES})
endif()

# Check if the platform is macOS, and try and optimise the github build.
if (CMAKE_SYSTEM_NAME STREQUAL "Darwin")
  # Check if the architecture is arm64 (Apple Silicon) or amd64 (Intel)
  if (CMAKE_SYSTEM_PROCESSOR STREQUAL "arm64")
    set(CMAKE_LINKER "/opt/homebrew/opt/llvm/bin/ld.lld")
  else()
    set(CMAKE_LINKER "/usr/local/opt/llvm/bin/ld.lld")
  endif()

  # Use lld linker for faster builds on macOS
  set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -fuse-ld=lld")
  set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -fuse-ld=lld")
endif()

# C++ standard and position-independent code (for dynamic libraries)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)  # Ensure PIC for shared libs

# Include necessary modules
include(compiler-specifics)
include(group-files)
include(coin)
include(ogdf)

include(make-user-target)
include(tests)
include(examples)

include(doc)

add_custom_target(build-all DEPENDS OGDF tests examples)

# Set install prefix to build directory to pwd (assuming `mkdir -p build/; cd build; cmake ../`
# pattern).
set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}" CACHE PATH "Install path prefix, prepended onto install directories.")

# Create autogen header
file(MAKE_DIRECTORY "${PROJECT_BINARY_DIR}/ogdf/basic/internal")
configure_file("${module_dir}/config_autogen.h.in" "${PROJECT_BINARY_DIR}/include/ogdf/basic/internal/config_autogen.h")

# Target documentation
message(STATUS "The default target builds OGDF (and dependencies like COIN).")
if(DOXYGEN_FOUND AND DOC_INSTALL)
  message(STATUS "Because DOC_INSTALL is set, it also generates the OGDF documentation (in-source).")
endif()
message(STATUS "")
message(STATUS "Other important targets:")
if(DOXYGEN_FOUND)
  if (DOC_INSTALL)
    message(STATUS "        OGDF: build OGDF library only")
  endif()
  message(STATUS "         doc: build doxygen documentation (in-source)")
endif()
message(STATUS "       tests: build tests")
message(STATUS "    examples: build examples")
message(STATUS "   build-all: build OGDF, tests, examples")
