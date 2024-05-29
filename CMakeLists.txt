cmake_minimum_required(VERSION 3.29.3)
set(PROJECT_NAME helloworld)
set(PROJECT_VERSION 1.0.0)
set(BUNLDE_ID art.hanabit.helloworld)
project(${PROJECT_NAME} VERSION ${PROJECT_VERSION})

include(ProcessorCount)

# Detect the number of CPU cores
ProcessorCount(NPROC)
set(GLOBAL_NPROC "${NPROC}")
message(STATUS "GLOBAL_NPROC: ${GLOBAL_NPROC}")

set(PREFIX_DIR ${CMAKE_CURRENT_SOURCE_DIR}/third-party/build)
set(BINARY_DIR ${PREFIX_DIR}/build)

set(CMAKE_CONFIGURATION_ARGS "")

set(CMAKE_CONFIGURATION_ARGS "${CMAKE_CONFIGURATION_ARGS} -DPREFIX_DIR=${PREFIX_DIR}")
set(CMAKE_BUILD_ARGS "--parallel ${GLOBAL_NPROC}")

if(${APPLE})
    set(CMAKE_CONFIGURATION_ARGS "${CMAKE_CONFIGURATION_ARGS} -DCMAKE_XCODE_ATTRIBUTE_DEVELOPMENT_TEAM='L83UAE6TVJ' -GXcode -DPLATFORM=${PLATFORM} -DOS=${OS} -DARCHS=${ARCHS} -DCMAKE_TOOLCHAIN_FILE:PATH=${CMAKE_CURRENT_SOURCE_DIR}/cmake/utils/ios.toolchain.cmake -DENABLE_BITCODE=${ENABLE_BITCODE} -DENABLE_ARC=${ENABLE_ARC}")
    # set(CMAKE_BUILD_ARGS " ${CMAKE_BUILD_ARGS} "
    if (${OS} STREQUAL "IOS")
        set(IOS 1)
    endif()
endif()

include(GNUInstallDirs)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_ANDROID_STL_TYPE "c++_static")

add_subdirectory(cmake)

# set_diagnostic_flags()

# hide_symbol()
include_directories(${PREFIX_DIR}/include)

set(SRC_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src")

if(${ARCHS} STREQUAL "")
    set(ARCHS "${CMAKE_HOST_SYSTEM_PROCESSOR}")
endif()

MESSAGE(STATUS "ARCHS: ${ARCHS}")

# 搜索通用目录中的.cpp和.h文件
# file(GLOB_RECURSE PUBLIC_HEADERS " ${HEADER_DIR}/*.h ")
# file(GLOB_RECURSE COMMON_SOURCES " ${COMMON_SOURCE_DIR}/*.cpp ")

# 初始化变量
if(NOT DEFINED OS)
    message(FATAL_ERROR "OS variable is not set")
endif()

set(ALL_SOURCES "")
set(ALL_PUBLIC_HEADER "")

set(SHARE_DIR "${SRC_SOURCE_DIR}/share")
message(STATUS "SHARE_DIR: ${SHARE_DIR}")
file(GLOB_RECURSE PUBLIC_HEADERS "${SHARE_DIR}/*.h")
file(GLOB_RECURSE SOURCES "${SHARE_DIR}/*.cpp" "${SHARE_DIR}/*.c")

# PLATFORM CODE
set(PLATFORM_DIR "${SRC_SOURCE_DIR}/src/platform")
string(TOLOWER "${OS}" LOWERCASE_OS)
set(PLATFORM_SOURCE_DIR "${PLATFORM_DIR}/${LOWERCASE_OS}")
set(PLATFORM_SOURCES "")
file(GLOB_RECURSE PLATFORM_SOURCES
    "${PLATFORM_SOURCE_DIR}/*.cpp"
)
file(GLOB_RECURSE PLATFORM_HEADER "${PLATFORM_SOURCE_DIR}/*.h")

# combine
set(ALL_SOURCES ${SOURCES} ${PLATFORM_SOURCES})
set(ALL_PUBLIC_HEADER ${PUBLIC_HEADERS} ${PLATFORM_HEADER})

message(STATUS "ALL_SOURCES: ${ALL_SOURCES}")
message(STATUS "ALL_PUBLIC_HEADER: ${ALL_PUBLIC_HEADER}")

# if(" ${OS}" STREQUAL "IOS ")

# set(SOURCES ${SOURCES} ${PUBLIC_HEADER})

# elseif(" ${OS}" STREQUAL "Android ")
# set(SOURCES ${SOURCES} src/android_wrapper.cpp)

# else()
# set(SOURCES ${SOURCES} src/main.cpp)
# endif()
add_main_executable(${PROJECT_NAME} PLATFORM ${OS} PUBLIC_HEADER ${ALL_PUBLIC_HEADER} SOURCES ${ALL_SOURCES})

if(NOT EMSCRIPTEN)
    add_external_project_if_missing(
        ${PROJECT_NAME}
        "SDL2"
        "https://github.com/libsdl-org/SDL.git"
        "release-2.30.3"
        "2.30.3"
        ${PREFIX_DIR}
        ${BINARY_DIR}/${ARCHS}/SDL2
    )
    string(TOLOWER "${CMAKE_BUILD_TYPE}" CMAKE_BUILD_TYPE_LOWER)
    set(ARCH_BUILD_DIR "${PREFIX_DIR}/build/${ARCHS}/SDL2")

    add_custom_command(
        TARGET SDL2-${OS}-${ARCHS}
        POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy "${ARCH_BUILD_DIR}/include-config-${CMAKE_BUILD_TYPE_LOWER}/SDL2/SDL_config.h" "${PREFIX_DIR}/include/SDL2"
        DEPENDS "${ARCH_BUILD_DIR}/include-config-${CMAKE_BUILD_TYPE_LOWER}/SDL2/SDL_config.h"
    )

    target_link_libraries(${PROJECT_NAME} ${SDL2_LIBRARIES})
endif()
