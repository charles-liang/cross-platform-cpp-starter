cmake_minimum_required(VERSION 3.29.3)
set(PROJECT_NAME helloworld)
project(${PROJECT_NAME})

include(GNUInstallDirs)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_ANDROID_STL_TYPE "c++_static")

message(STATUS "TARGET_ARCHITECTURE = ${CMAKE_OSX_ARCHITECTURES}")

# Check if the directory already exists
if(APPLE AND NOT "${CMAKE_OSX_ARCHITECTURES}" STREQUAL "")
    Message(STATUS "CMAKE_OSX_ARCHITECTURES = ${CMAKE_OSX_ARCHITECTURES}")
    list(APPEND ${CMAKE_ARGS} " -DCMAKE_OSX_ARCHITECTURES=${CMAKE_OSX_ARCHITECTURES} ")
endif()
message(STATUS "CM")
message(STATUS "CMAKE_ARGS: ${CMAKE_ARGS}")

add_subdirectory(cmake)

set_diagnostic_flags()
hide_symbol()

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Release")
endif()

set(PREFIX_DIR ${CMAKE_CURRENT_SOURCE_DIR}/third-party/build)
set(BINARY_DIR ${PREFIX_DIR}/build)
set(INSTALL_DIR ${PREFIX_DIR}/install)

if("${PLATFORM}" STREQUAL "IOS")
    set(SOURCES ${SOURCES} ${PUBLIC_HEADER})

elseif("${PLATFORM}" STREQUAL "ANDROID")
    set(SOURCES ${SOURCES} src/android_wrapper.cpp)

else()
    set(SOURCES ${SOURCES} src/main.cpp)
endif()

foreach(ARCH IN LISTS CMAKE_OSX_ARCHITECTURES)
    include_directories(${PREFIX_DIR}/${ARCH}/include)
    link_directories(${PREFIX_DIR}/${ARCH}/lib)
endforeach()

add_main_executable(${PROJECT_NAME} PLATFORM ${PLATFORM})

foreach(ARCH IN LISTS CMAKE_OSX_ARCHITECTURES)
    add_main_executable(${PROJECT_NAME}_${ARCH} PLATFORM ${PLATFORM} PUBLIC_HEADER ${PUBLIC_HEADER} SOURCES ${SOURCES})
    add_dependencies(${PROJECT_NAME} ${PROJECT_NAME}_${ARCH})
endforeach()

# target_link_libraries(${PROJECT_NAME})
if(NOT EMSCRIPTEN)
    add_external_project_if_missing(
        ${PROJECT_NAME}
        "SDL2"
        "https://github.com/libsdl-org/SDL.git"
        "release-2.30.3"
        ${PREFIX_DIR}
        "-DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>"
    )
    add_custom_command(
        TARGET ${PROJECT_NAME}
        POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory "${ARCH_BUILD_DIR}/include-config-${CMAKE_BUILD_TYPE_LOWER}/SDL2/SDL_config.h" "${PREFIX_DIR}/${ARCH}/include/SDL2"
    )
endif()


# Link the libraries to the targe
foreach(ARCH IN LISTS CMAKE_OSX_ARCHITECTURES)
    target_link_libraries(${PROJECT_NAME}_${ARCH} "${SDL2_${ARCH}_LIBRARIES}")
endforeach()