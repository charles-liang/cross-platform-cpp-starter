cmake_minimum_required(VERSION 3.24)
set(PROJECT_NAME helloworld)
project(${PROJECT_NAME})

include(GNUInstallDirs)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_ANDROID_STL_TYPE "c++_static")

message(STATUS "TARGET_ARCHITECTURE = ${CMAKE_OSX_ARCHITECTURES}")
list(APPEND CMAKE_ARGS " -DCMAKE_OSX_ARCHITECTURES=${CMAKE_OSX_ARCHITECTURES} ")

add_subdirectory(cmake)


set_diagnostic_flags()
hide_symbol()


set(PREFIX_DIR ${CMAKE_CURRENT_SOURCE_DIR}/third-party/build)
set(BINARY_DIR ${PREFIX_DIR}/src/build)
set(INSTALL_DIR ${PREFIX_DIR}/install)

# find_package(SDL2 REQUIRED)
# link_directories(${PREFIX_DIR}/lib)
# find_library(SDL2 )

if(NOT EMSCRIPTEN)
    add_external_project_if_missing(
        "SDL2"
        "https://github.com/libsdl-org/SDL.git"
        "release-2.30.3"
        ${PREFIX_DIR}
        ${BINARY_DIR}/SDL2
        ${INSTALL_DIR}/SDL2
        "-DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>"
    )
endif()

include_directories(${PREFIX_DIR}/include)
find_library(SDL2_LIB NAMES SDL2 SDL2d HINTS ${PREFIX_DIR}/lib NO_DEFAULT_PATH)


if ("${PLATFORM}" STREQUAL "IOS")
    set(SOURCES ${SOURCES} ${PUBLIC_HEADER})

elseif ("${PLATFORM}" STREQUAL "ANDROID")
    set(SOURCES ${SOURCES} src/android_wrapper.cpp)

else ()
    set(SOURCES ${SOURCES} src/main.cpp)

endif ()

add_main_executable(${PROJECT_NAME} PLATFORM ${PLATFORM} PUBLIC_HEADER ${PUBLIC_HEADER} SOURCES ${SOURCES})

target_link_libraries(${PROJECT_NAME} ${SDL2_LIB})
