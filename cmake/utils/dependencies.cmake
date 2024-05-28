cmake_minimum_required(VERSION 3.29.3)

include(ExternalProject)
include(ProcessorCount)

# Detect the number of CPU cores
ProcessorCount(NPROC)

message(STATUS "CPU NUM: ${NPROC}")

function(add_external_project_if_missing PROJECT_NAME NAME GIT_REPO GIT_TAG PREFIX_DIR CMAKE_ARGS)
    # Define the shared source directory
    set(SHARED_SOURCE_DIR "${PREFIX_DIR}/src/${NAME}_source")

    # Ensure the source is downloaded only once
    # if(NOT EXISTS ${SHARED_SOURCE_DIR})
    MESSAGE(STATUS "Adding external project: ${NAME}_source")
    ExternalProject_Add(
        ${NAME}_source
        GIT_REPOSITORY ${GIT_REPO}
        GIT_TAG ${GIT_TAG}
        PREFIX ${PREFIX_DIR}
        SOURCE_DIR ${SHARED_SOURCE_DIR}
        CONFIGURE_COMMAND ""
        BUILD_COMMAND ""
        INSTALL_COMMAND ""
        BUILD_BYPRODUCTS "${SHARED_SOURCE_DIR}/CMakeLists.txt"
    )
    ExternalProject_Get_Property(${NAME}_source)

    # endif()

    # # Loop through each specified architecture
    # foreach(ARCH IN LISTS CMAKE_OSX_ARCHITECTURES)
    #     MESSAGE(STATUS "BUILDING ${NAME} ARCH: ${ARCH}")

    #     # Define the architecture-specific install directory
    #     set(ARCH_BUILD_DIR "${PREFIX_DIR}/build/${ARCH}")

    #     # Check if the directory already exists
    #     set(CMAKE_ARCH_ARGS "-DCMAKE_OSX_ARCHITECTURES=${ARCH} ${CMAKE_ARGS}")
    #     message(STATUS "Adding external project: ${ARCH_BUILD_DIR}")

    #     # Add the external project for the current architecture
    #     ExternalProject_Add(
    #         ${NAME}_${ARCH}
    #         PREFIX ${PREFIX_DIR}
    #         SOURCE_DIR ${SHARED_SOURCE_DIR}
    #         BINARY_DIR ${ARCH_BUILD_DIR}
    #         CMAKE_ARGS ${CMAKE_ARCH_ARGS} -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
    #         DOWNLOAD_COMMAND ""
    #         BUILD_COMMAND ${CMAKE_COMMAND} --build ${ARCH_BUILD_DIR} --parallel ${NPROC}
    #         INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory ${ARCH_BUILD_DIR}/${CMAKE_BUILD_TYPE}/ ${PREFIX_DIR}/${ARCH}/lib/ && ${CMAKE_COMMAND} -E copy_directory ${ARCH_BUILD_DIR}/include ${PREFIX_DIR}/${ARCH}/include
    #         DEPENDS ${NAME}_source
    #     )

    #     set(${NAME}_${ARCH}_INCLUDE_DIRS ${PREFIX_DIR}/${ARCH}/include)
    #     set(${NAME}_${ARCH}_LIBRARY_DIRS ${PREFIX_DIR}/${ARCH}/lib/)

    #     if(WIN32)
    #         if("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
    #             set(${NAME}_${ARCH}_LIBRARIES ${PREFIX_DIR}/${ARCH}/lib/lib${NAME}d_${}.lib)
    #         else()
    #             set(${NAME}_${ARCH}_LIBRARIES ${PREFIX_DIR}/${ARCH}/lib/lib${NAME}.lib)
    #         endif()
    #     elseif(APPLE)
    #         if(IOS)
    #             if("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
    #                 set(${NAME}_${ARCH}_LIBRARIES ${PREFIX_DIR}/${ARCH}/lib/lib${NAME}d.a)
    #             else()
    #                 set(${NAME}_${ARCH}_LIBRARIES ${PREFIX_DIR}/${ARCH}/lib/lib${NAME}.a)
    #             endif()
    #         else()
    #             if("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
    #                 set(${NAME}_${ARCH}_LIBRARIES ${PREFIX_DIR}/${ARCH}/lib/lib${NAME}d.a)
    #             else()
    #                 set(${NAME}_${ARCH}_LIBRARIES ${PREFIX_DIR}/${ARCH}/lib/lib${NAME}.a)
    #             endif()
    #         endif()
    #     elseif(ANDROID)
    #         if("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
    #             set(${NAME}_${ARCH}_LIBRARIES ${PREFIX_DIR}/${ARCH}/lib/lib${NAME}d.a)
    #         else()
    #             set(${NAME}_${ARCH}_LIBRARIES ${PREFIX_DIR}/${ARCH}/lib/lib${NAME}.a)
    #         endif()
    #     elseif(EMSCRIPTEN)
    #         if("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
    #             set(${NAME}_${ARCH}_LIBRARIES ${PREFIX_DIR}/${ARCH}/lib/lib${NAME}d.bc)
    #         else()
    #             set(${NAME}_${ARCH}_LIBRARIES ${PREFIX_DIR}/${ARCH}/lib/lib${NAME}.bc)
    #         endif()
    #     elseif(UNIX)
    #         if("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
    #             set(${NAME}_${ARCH}_LIBRARIES ${PREFIX_DIR}/${ARCH}/lib/lib${NAME}d.a)
    #         else()
    #             set(${NAME}_${ARCH}_LIBRARIES ${PREFIX_DIR}/${ARCH}/lib/lib${NAME}.a)
    #         endif()
    #     else()
    #         message(FATAL_ERROR "Unsupported platform")
    #     endif()

    #     # Make the include directories and libraries available to the parent scope
    #     set(${NAME}_${ARCH}_INCLUDE_DIRS ${${NAME}_${ARCH}_INCLUDE_DIRS} PARENT_SCOPE)
    #     set(${NAME}_${ARCH}_LIBRARY_DIRS ${${NAME}_${ARCH}_LIBRARY_DIRS} PARENT_SCOPE)
    #     set(${NAME}_${ARCH}_LIBRARIES ${${NAME}_${ARCH}_LIBRARIES} PARENT_SCOPE)

    #     # copy_directory(${ARCH_BUILD_DIR}/include ${${NAME}_${ARCH}_INCLUDE_DIRS})
    #     # copy_directory(${ARCH_BUILD_DIR}/lib ${${NAME}_${ARCH}_LIBRARY_DIRS})
    #     add_dependencies(${NAME}_${ARCH} ${NAME}_source)
    #     add_dependencies(${PROJECT_NAME} ${NAME}_${ARCH})

    #     # set(${NAME}_${ARCH}_LIBRARIES ${${NAME}_${ARCH}_LIBRARIES} PARENT_SCOPE)
    # endforeach()
endfunction()
