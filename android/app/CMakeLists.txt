# Copyright 2020 Tejas Mehta <tmthecoder@gmail.com>
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

cmake_minimum_required(VERSION 3.6.0)

# CMake Instructions for Argon2's build for Android's NDK

project(argon2-arm C CXX)
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -Os")

file(GLOB argon2-arm_SOURCES
    ../../submodules/phc-winner-argon2/src/blake2/blake2b.c
    ../../submodules/phc-winner-argon2/src/argon2.c
    ../../submodules/phc-winner-argon2/src/core.c
    ../../submodules/phc-winner-argon2/src/encoding.c
    ../../submodules/phc-winner-argon2/src/ref.c
    ../../submodules/phc-winner-argon2/src/thread.c
)

add_library(argon2-arm SHARED ${argon2-arm_SOURCES})
target_compile_options(argon2-arm PRIVATE)
target_include_directories(argon2-arm PUBLIC ../../submodules/phc-winner-argon2/include/)
