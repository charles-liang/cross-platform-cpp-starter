cmake_minimum_required(VERSION 3.29.3)
set(PROJECT_NAME helloworld)
project(${PROJECT_NAME})

include(GNUInstallDirs)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_ANDROID_STL_TYPE "c++_static")

add_subdirectory(cmake)


set_diagnostic_flags()
hide_symbol()

set(PREFIX_DIR ${CMAKE_CURRENT_SOURCE_DIR}/third-party/build)
set(BINARY_DIR ${PREFIX_DIR}/build)

include_directories(${PREFIX_DIR}/include)

if("${PLATFORM}" STREQUAL "IOS")
    set(SOURCES ${SOURCES} ${PUBLIC_HEADER})

elseif("${PLATFORM}" STREQUAL "ANDROID")
    set(SOURCES ${SOURCES} src/android_wrapper.cpp)

else()
    set(SOURCES ${SOURCES} src/main.cpp)
endif()

if(${ARCHS} STREQUAL "")
    set(ARCHS "${CMAKE_HOST_SYSTEM_PROCESSOR}")
endif()

MESSAGE(STATUS "ARCHS: ${ARCHS}")

add_main_executable(${PROJECT_NAME} PLATFORM ${PLATFORM} PUBLIC_HEADER ${PUBLIC_HEADER} SOURCES ${SOURCES})

if(NOT EMSCRIPTEN)
    add_external_project_if_missing(
        ${PROJECT_NAME}
        "SDL2"
        "https://github.com/libsdl-org/SDL.git"
        "release-2.30.3"
        ${PREFIX_DIR}
        ${BINARY_DIR}/${ARCHS}/SDL2
        "-DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>"
    )
    string(TOLOWER "${CMAKE_BUILD_TYPE}" CMAKE_BUILD_TYPE_LOWER)
    set(ARCH_BUILD_DIR "${PREFIX_DIR}/build/${ARCHS}/SDL2")

    add_custom_command(
        TARGET SDL2
        POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy "${ARCH_BUILD_DIR}/include-config-${CMAKE_BUILD_TYPE_LOWER}/SDL2/SDL_config.h" "${PREFIX_DIR}/include/SDL2"
    )

    target_link_libraries(${PROJECT_NAME} ${SDL2_LIBRARIES})
endif()


