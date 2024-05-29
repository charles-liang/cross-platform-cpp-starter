cmake_minimum_required(VERSION 3.29.3)

include(ExternalProject)

include(ProcessorCount)

# Detect the number of CPU cores
ProcessorCount(NPROC)

message(STATUS "CPU NUM: ${NPROC}")

function(add_external_project_if_missing PROJECT_NAME NAME GIT_REPO GIT_TAG PREFIX_DIR BINARY_DIR CMAKE_ARGS)
    # Check if the directory already exists
    # Add the external project
    MESSAGE(STATUS "Add external project: ${NAME} ${OS} ${ARCHS}")

    set(CMAKE_ARGS "${CMAKE_ARGS} -DOS=${OS}")

    if (APPLE)
        set(CMAKE_ARGS "${CMAKE_ARGS} -DCMAKE_TOOLCHAIN_FILE=${CMAKE_CURRENT_SOURCE_DIR}/cmake/utils/ios.toolchain.cmake -DPREFIX_DIR=${PREFIX_DIR} -DARCHS=${ARCHS} -DOS=${OS} -DENABLE_BITCODE=${ENABLE_BITCODE} -DENABLE_ARC=${ENABLE_ARC}")
    endif()

    message(STATUS "CMAKE_ARGS: ${CMAKE_ARGS}")

    ExternalProject_Add(
        ${NAME}
        GIT_REPOSITORY ${GIT_REPO}
        GIT_TAG ${GIT_TAG}
        PREFIX ${PREFIX_DIR}
        BINARY_DIR ${BINARY_DIR}
        CMAKE_COMMAND ${CMAKE_COMMAND}
        CMAKE_ARGS ${CMAKE_ARGS} -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} 
        UPDATE_DISCONNECTED 1
        BUILD_COMMAND ${CMAKE_COMMAND} --build <BINARY_DIR> --parallel ${NPROC}
        INSTALL_COMMAND ""
        # INSTALL_COMMAND cmake --build <BINARY_DIR> --target install
        COMMAND ${CMAKE_COMMAND} -E copy_directory <BINARY_DIR>/include ${PREFIX_DIR}/include
        COMMAND ${CMAKE_COMMAND} -E copy_directory <BINARY_DIR>/${CMAKE_BUILD_TYPE} ${PREFIX_DIR}/${OS}-${ARCHS}/lib
    )
    add_dependencies(${PROJECT_NAME} ${NAME}-${OS}-${ARCHS})
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
    elseif(APPLE)
        if(IOS)
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
    elseif(ANDROID)
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


    # if (NOT EXISTS "${${NAME}_LIBRARIES}")
    #     file(GLOB LIBRARY_FILES "${PREFIX_DIR}/${OS}-${ARCHS}/lib/lib${NAME}*")
        
    #     # Debug message to show the list of found files
    #     message(STATUS "Found library files: ${LIBRARY_FILES}")

    #     # Check if LIBRARY_FILES is not empty before sorting and getting the first element
    #     if (LIBRARY_FILES)
    #         list(SORT LIBRARY_FILES)
    #         list(GET LIBRARY_FILES 0 FIRST_LIBRARY_FILE)
            
    #         if (FIRST_LIBRARY_FILE)
    #             add_custom_command(TARGET ${NAME} POST_BUILD
    #                 COMMAND ${CMAKE_COMMAND} -E create_symlink ${FIRST_LIBRARY_FILE} ${${NAME}_LIBRARIES}
    #                 COMMENT "Creating symlink for ${${NAME}_LIBRARIES}"
    #             )
    #         else()
    #             message(WARNING "No suitable library file found for ${NAME}")
    #         endif()
    #     else()
    #         message(WARNING "No library files found for ${NAME}")
    #     endif()
    # endif()


    # Make the include directories and libraries available to the parent scope
    set(${NAME}_INCLUDE_DIRS ${${NAME}_INCLUDE_DIRS} PARENT_SCOPE)
    set(${NAME}_LIBRARY_DIRS ${${NAME}_LIBRARY_DIRS} PARENT_SCOPE)
    set(${NAME}_LIBRARIES ${${NAME}_LIBRARIES} PARENT_SCOPE)

endfunction()
