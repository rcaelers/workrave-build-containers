set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)
set(CMAKE_C_COMPILER aarch64-linux-gnu-gcc)
set(CMAKE_CXX_COMPILER aarch64-linux-gnu-g++)
set(CMAKE_C_COMPILER_TARGET aarch64-linux-gnu)
set(CMAKE_CXX_COMPILER_TARGET aarch64-linux-gnu)
set(CMAKE_STRIP aarch64-linux-gnu-strip)
set(CMAKE_CROSSCOMPILING_EMULATOR /opt/workrave/bin/run-aarch64)

# Ubuntu multiarch installs target libraries beside the native tools; the
# compiler supplies the aarch64 library architecture to CMake. pkg-config
# is separately restricted to target metadata by the image's environment.
set(CMAKE_FIND_ROOT_PATH /usr/aarch64-linux-gnu /)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
list(APPEND CMAKE_IGNORE_PATH /usr/lib/x86_64-linux-gnu /lib/x86_64-linux-gnu)
