cmake_minimum_required(VERSION 3.29)

#  to make swift lsp is working properly, we also need cmake 3.29
if(POLICY CMP0157)
  cmake_policy(SET CMP0157 NEW)
endif()

project(PingPong LANGUAGES C CXX Swift)

# compile commands
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

if(NOT "${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang" AND
   NOT "${CMAKE_CXX_COMPILER_ID}" STREQUAL "AppleClang")
  message(FATAL_ERROR "Project requires building with Clang.
  Have ${CMAKE_CXX_COMPILER_ID}")
endif()

# raylib
include(FetchContent)
set(FETCHCONTENT_QUIET FALSE)
set(BUILD_EXAMPLES OFF CACHE BOOL "" FORCE) # don't build the supplied examples
set(BUILD_GAMES    OFF CACHE BOOL "" FORCE) # don't build the supplied example games

# libuv
FetchContent_Declare(
    libuv
    GIT_REPOSITORY "https://github.com/libuv/libuv"
    GIT_TAG "v1.x"
    GIT_PROGRESS TRUE
    # disable tests and examples
    CMAKE_ARGS -DBUILD_TESTING=OFF -DBUILD_EXAMPLES=OFF -DLIBUV_BUILD_SHARED=OFF
)
FetchContent_MakeAvailable(libuv)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules")

# Set up swiftrt.o and runtime library search paths
include(InitializeSwift)
# cmake/modules/AddSwift.cmake provides the function for creating the Swift to
# C++ bridging header
include(AddSwift)

set(PINGPONG_INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/include")

set(CMAKE_OSX_DEPLOYMENT_TARGET 13.0)
set(CMAKE_CXX_STANDARD 17)

include_directories(${PINGPONG_INCLUDE_DIR})

add_library(fibonacci STATIC ./lib/fibonacci.cpp)
add_executable(fibonacci_swift ./src/fibonacci.swift)
# append  -Wno-module-import-in-extern-c to CC and CXX flags
# to suppress warnings about importing Swift modules in C/C++ code
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-module-import-in-extern-c")

target_link_libraries(fibonacci_swift PRIVATE fibonacci uv)
target_compile_options(fibonacci_swift PUBLIC
  "$<$<COMPILE_LANGUAGE:Swift>:-cxx-interoperability-mode=default>")