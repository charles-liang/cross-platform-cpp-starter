cmake_minimum_required(VERSION 3.20.0)
set(PROJECT_NAME helloworld)
set(PROJECT_VERSION 1.0.0)
set(ORGANIZATION art.hanabit)
# set(DEVELOPMENT_TEAM $ENV{DEVELOPMENT_TEAM_ID})
project(${PROJECT_NAME} VERSION ${PROJECT_VERSION})

get_cmake_property(_variableNames VARIABLES)
set(passed_variables "")


include(ProcessorCount)

# Detect the number of CPU cores
ProcessorCount(NPROC)
set(CONCURRENCY "${NPROC}")
message(STATUS "CONCURRENCY: ${CONCURRENCY}")

set(PREFIX_DIR ${CMAKE_CURRENT_SOURCE_DIR}/third-party/build)
set(BINARY_DIR ${PREFIX_DIR}/build)

set(MAKE_CONFIGURE_ARGS "")
set(MAKE_BUILD_ARGS "")
set(MAKE_INSTALL_ARGS "")
set(CMAKE_CONFIGURATION_ARGS "")
set(CMAKE_BUILD_ARGS "")
set(CMAKE_INSTALL_ARGS "")

set(CMAKE_CONFIGURATION_ARGS ${CMAKE_CONFIGURATION_ARGS} -DPREFIX_DIR=${PREFIX_DIR} 
# -DCMAKE_BUILD_Type=$
)
set(CMAKE_BUILD_ARGS --parallel ${CONCURRENCY})
if(${APPLE})
    set(CMAKE_CONFIGURATION_ARGS ${CMAKE_CONFIGURATION_ARGS} -DCMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_ALLOWED=NO -G Xcode -DPLATFORM=${PLATFORM} -DOS=${OS} -DARCHS=${ARCHS} -DCMAKE_TOOLCHAIN_FILE:PATH=${CMAKE_CURRENT_SOURCE_DIR}/cmake/utils/ios.toolchain.cmake -DENABLE_BITCODE=${ENABLE_BITCODE} -DENABLE_ARC=${ENABLE_ARC})
    set(CMAKE_BUILD_ARGS ${CMAKE_BUILD_ARGS} -- -allowProvisioningUpdates)
    set(CC "clang")
    set(CXX "clang++")
endif()
if (WIN32)
    set(CC "msvc")
    set(CXX "msvc")
endif()

include(GNUInstallDirs)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_ANDROID_STL_TYPE "c++_static")

add_subdirectory(cmake)

# set_diagnostic_flags()

# hide_symbol()
include_directories(${PREFIX_DIR}/include)

set(SRC_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src")
message(STATUS "ARCHS: ${ARCHS}")
if("${ARCHS}" STREQUAL "")
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
MESSAGE(STATUS "OS: ${OS}")

set(ALL_SOURCES "")
set(ALL_PUBLIC_HEADER "")

set(SHARE_DIR "${SRC_SOURCE_DIR}/share")
message(STATUS "SHARE_DIR: ${SHARE_DIR}")
message(STATUS "Search Share Source Code ${SHARE_DIR}")
file(GLOB_RECURSE PUBLIC_HEADERS "${SHARE_DIR}/*.h")
file(GLOB_RECURSE SHARE_SOURCES "${SHARE_DIR}/*.cpp" "${SHARE_DIR}/*.c")

# PLATFORM CODE
set(PLATFORM_DIR "${SRC_SOURCE_DIR}/platform")
string(TOLOWER ${OS} LOWERCASE_OS)
set(PLATFORM_SOURCE_DIR "${PLATFORM_DIR}/${LOWERCASE_OS}")
message(STATUS "Search Platform Source Code ${PLATFORM_SOURCE_DIR}")

set(PLATFORM_SOURCES "")
file(GLOB_RECURSE PLATFORM_SOURCES
"${PLATFORM_SOURCE_DIR}/*.cpp"
)
file(GLOB_RECURSE PLATFORM_HEADER "${PLATFORM_SOURCE_DIR}/*.h")

# combine
set(ALL_SOURCES ${PLATFORM_SOURCES} ${SHARE_SOURCES} )
set(ALL_PUBLIC_HEADER ${PUBLIC_HEADERS} ${PLATFORM_HEADER})
message(STATUS "PLATFORM_SOURCES: ${PLATFORM_SOURCES}")
message(STATUS "SHARE_SOURCES: ${SHARE_SOURCES}")
message(STATUS "ALL_SOURCES: ${ALL_SOURCES}")
message(STATUS "ALL_PUBLIC_HEADER: ${ALL_PUBLIC_HEADER}")

# if(" ${OS}" STREQUAL "IOS ")

# set(SOURCES ${SOURCES} ${PUBLIC_HEADER})

# elseif(" ${OS}" STREQUAL "Android ")
# set(SOURCES ${SOURCES} src/android_wrapper.cpp)

# else()
# set(SOURCES ${SOURCES} src/main.cpp)
# endif()
add_main_executable(${PROJECT_NAME} PLATFORM ${OS} PUBLIC_HEADER ${ALL_PUBLIC_HEADER} ALL_SOURCES ${ALL_SOURCES})

if(APPLE)
    set_xcode_property(${PROJECT_NAME} CODE_SIGN_IDENTITY "Apple Development" All)
    set_xcode_property(${PROJECT_NAME}_lib CODE_SIGN_IDENTITY "Apple Development" All)

    #
    set_xcode_property(${PROJECT_NAME} DEVELOPMENT_TEAM ${DEVELOPMENT_TEAM_ID} All)

    # set_xcode_property(${PROJECT_NAME}_lib CODE_SIGN_IDENTITY "Apple Development" All)
    set_xcode_property(${PROJECT_NAME}_lib DEVELOPMENT_TEAM ${DEVELOPMENT_TEAM_ID} All)
endif()

if (MSVC)
    # if ("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
    #     set_target_properties(${PROJECT_NAME} PROPERTIES LINK_FLAGS "/SUBSYSTEM:CONSOLE")
    # else()
        set_target_properties(${PROJECT_NAME} PROPERTIES LINK_FLAGS "/SUBSYSTEM:WINDOWS")
    # endif()
endif()


foreach(_variableName ${_variableNames})
    list(APPEND passed_variables "-D${_variableName}=${${_variableName}}")
endforeach()

# if (APPLE)
# set(passed_variables ${passed_variables}  )
# endif()
message(STATUS "CMAKE_COMMAND: ${${CMAKE_COMMAND}}")
message(STATUS "MACK_COMMAND: ${MACK_COMMAND}")
if(NOT EMSCRIPTEN)
    include(cmake/deps/sdl.cmake)
    include(cmake/deps/ffmpeg.cmake)
endif()
