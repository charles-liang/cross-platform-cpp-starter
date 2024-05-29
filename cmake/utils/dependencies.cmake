cmake_minimum_required(VERSION 3.29.3)

include(ExternalProject)

function(add_external_project_if_missing PROJECT_NAME NAME GIT_REPO GIT_TAG VERSION PREFIX_DIR BINARY_DIR)
    # Check if the directory already exists
    # Add the external project
    MESSAGE(STATUS "Add external project: ${NAME} ${OS} ${ARCHS}")

    set(TRIPLE_NAME ${NAME}-${OS}-${ARCHS})

    set(ARCH_BUILD_DIR "${PREFIX_DIR}/build/${TRIPLE_NAME}")

    message(STATUS "CMAKE_COMMAND: ${CMAKE_COMMAND}")

    set(SHARED_SOURCE_DIR "${PREFIX_DIR}/src/${NAME}_source")

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

    ExternalProject_Add(
        ${TRIPLE_NAME}
        PREFIX ${PREFIX_DIR}
        SOURCE_DIR ${SHARED_SOURCE_DIR}
        BINARY_DIR ${ARCH_BUILD_DIR}
        CMAKE_COMMAND ${CMAKE_COMMAND}
        CMAKE_ARGS ""
        DOWNLOAD_COMMAND ""

        CONFIGURE_COMMAND ${CMAKE_COMMAND} "${SHARED_SOURCE_DIR}/CMakeLists.txt" ${CMAKE_CONFIGURATION_ARGS}
        BUILD_COMMAND ${CMAKE_COMMAND} --build ${ARCH_BUILD_DIR} ${CMAKE_BUILD_ARGS}
        COMMAND ${CMAKE_COMMAND} -E copy_directory ${ARCH_BUILD_DIR}/${CMAKE_BUILD_TYPE}/ ${PREFIX_DIR}/${ARCHS}/lib/
        COMMAND ${CMAKE_COMMAND} -E copy_directory ${ARCH_BUILD_DIR}/include ${PREFIX_DIR}/${ARCHS}/include
        DEPENDS ${NAME}_source
    )
    MESSAGE(STATUS "Add external project: ${NAME} ${OS} ${ARCHS}")

    if(${APPLE})
        if("${OS}" STREQUAL "IOS")
            # TODO: Fix this
            setup_framework_properties(${TRIPLE_NAME} ${VERSION})
            add_dependencies(${PROJECT_NAME}_lib ${TRIPLE_NAME})
        endif()
    else()
        add_dependencies(${PROJECT_NAME} ${TRIPLE_NAME})
    endif()

    # Register the include directory and library path
    # ExternalProject_Get_Property(${NAME} PREFIX_DIR)
    set(${NAME}_INCLUDE_DIRS ${PREFIX_DIR}/include)
    set(${NAME}_LIBRARY_DIRS ${PREFIX_DIR}/${OS}-${ARCHS}/lib)

    if(WIN32)
        if("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
            set(${NAME}_LIBRARIES ${PREFIX_DIR}/${OS}-${ARCHS}/lib/lib${NAME}d.lib)
        else()
            set(${NAME}_LIBRARIES ${PREFIX_DIR}/${OS}-${ARCHS}/lib/lib${NAME}.lib)
        endif()
    elseif(${APPLE})
        if(${OS} STREQUAL "IOS")
            if("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
                set(${NAME}_LIBRARIES ${PREFIX_DIR}/${OS}-${ARCHS}/lib/lib${NAME}d.a)
            else()
                set(${NAME}_LIBRARIES ${PREFIX_DIR}/${OS}-${ARCHS}/lib/lib${NAME}.a)
            endif()
        else()
            if("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
                set(${NAME}_LIBRARIES ${PREFIX_DIR}/${OS}-${ARCHS}/lib/lib${NAME}d.dylib)
            else()
                set(${NAME}_LIBRARIES ${PREFIX_DIR}/${OS}-${ARCHS}/lib/lib${NAME}.dylib)
            endif()
        endif()
    elseif(${OS} STREQUAL "Android")
        if("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
            set(${NAME}_LIBRARIES ${PREFIX_DIR}/${OS}-${ARCHS}/lib/lib${NAME}d.a)
        else()
            set(${NAME}_LIBRARIES ${PREFIX_DIR}/${OS}-${ARCHS}/lib/lib${NAME}.a)
        endif()
    elseif(EMSCRIPTEN)
        if("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
            set(${NAME}_LIBRARIES ${PREFIX_DIR}/${OS}-${ARCHS}/lib/lib${NAME}d.bc)
        else()
            set(${NAME}_LIBRARIES ${PREFIX_DIR}/${OS}-${ARCHS}/lib/lib${NAME}.bc)
        endif()
    elseif(UNIX)
        if("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
            set(${NAME}_LIBRARIES ${PREFIX_DIR}/${OS}-${ARCHS}/lib/lib${NAME}d.a)
        else()
            set(${NAME}_LIBRARIES ${PREFIX_DIR}/${OS}-${ARCHS}/lib/lib${NAME}.a)
        endif()
    else()
        message(FATAL_ERROR "Unsupported OS")
    endif()

    if(NOT EXISTS "${${NAME}_LIBRARIES}")
        file(GLOB LIBRARY_FILES "${PREFIX_DIR}/${OS}-${ARCHS}/lib/lib${NAME}*")

        # Debug message to show the list of found files
        message(STATUS "Found library files: ${LIBRARY_FILES}")

        # Check if LIBRARY_FILES is not empty before sorting and getting the first element
        if(LIBRARY_FILES)
            list(SORT LIBRARY_FILES)
            list(GET LIBRARY_FILES 0 FIRST_LIBRARY_FILE)

            if(FIRST_LIBRARY_FILE)
                add_custom_command(TARGET ${NAME} POST_BUILD
                    COMMAND ${CMAKE_COMMAND} -E create_symlink ${FIRST_LIBRARY_FILE} ${${NAME}_LIBRARIES}
                    COMMENT "Creating symlink for ${${NAME}_LIBRARIES}"
                )
            else()
                message(WARNING "No suitable library file found for ${NAME}")
            endif()
        else()
            message(WARNING "No library files found for ${NAME}")
        endif()
    endif()

    # Make the include directories and libraries available to the parent scope
    set(${NAME}_INCLUDE_DIRS ${${NAME}_INCLUDE_DIRS} PARENT_SCOPE)
    set(${NAME}_LIBRARY_DIRS ${${NAME}_LIBRARY_DIRS} PARENT_SCOPE)
    set(${NAME}_LIBRARIES ${${NAME}_LIBRARIES} PARENT_SCOPE)
endfunction()
