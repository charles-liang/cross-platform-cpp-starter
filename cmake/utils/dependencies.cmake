cmake_minimum_required(VERSION 3.24)

include(ExternalProject)

function(add_external_project_if_missing NAME GIT_REPO GIT_TAG PREFIX_DIR BINARY_DIR INSTALL_DIR CMAKE_ARGS)
    # Check if the directory already exists
    if(NOT EXISTS ${INSTALL_DIR})
        MESSAGE(STATUS " ${INSTALL_DIR} does not exist, adding ExternalProject_Add ")


        message(STATUS "NAME: ${NAME}")
        message(STATUS "GIT_REPO: ${GIT_REPO}")
        message(STATUS "GIT_TAG: ${GIT_TAG}")
        message(STATUS "PREFIX_DIR: ${PREFIX_DIR}")
        message(STATUS "BINARY_DIR: ${BINARY_DIR}")
        message(STATUS "INSTALL_DIR: ${INSTALL_DIR}")
        message(STATUS "CMAKE_ARGS: ${CMAKE_ARGS}")

        # Add the external project
        ExternalProject_Add(
            ${NAME}
            GIT_REPOSITORY ${GIT_REPO}
            GIT_TAG ${GIT_TAG}
            PREFIX ${PREFIX_DIR}
            BINARY_DIR ${BINARY_DIR}
            CMAKE_COMMAND ${CMAKE_COMMAND}
            CMAKE_ARGS ${CMAKE_ARGS}
            BUILD_COMMAND cmake --build <BINARY_DIR> -- VERBOSE=1
            INSTALL_COMMAND cmake --build <BINARY_DIR> --target install -- VERBOSE=1
        )

        # Register the include directory and library path
        ExternalProject_Get_Property(${NAME} install_dir)
        set(${NAME}_INCLUDE_DIRS ${install_dir}/include)
        set(${NAME}_LIBRARY_DIRS ${install_dir}/lib)
        set(${NAME}_LIBRARIES ${install_dir}/lib/${NAME}.a)

        # Make the include directories and libraries available to the parent scope
        set(${NAME}_INCLUDE_DIRS ${${NAME}_INCLUDE_DIRS} PARENT_SCOPE)
        set(${NAME}_LIBRARY_DIRS ${${NAME}_LIBRARY_DIRS} PARENT_SCOPE)
        set(${NAME}_LIBRARIES ${${NAME}_LIBRARIES} PARENT_SCOPE)
    else()
        message(STATUS " ${NAME} already exists, skipping ExternalProject_Add ")
    endif()
endfunction()
