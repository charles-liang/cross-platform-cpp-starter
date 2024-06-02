include(ExternalProject)

function(sdl NAME GIT_REPO GIT_TAG VERSION DEPENDS)
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
        CMAKE_ARGS ${passed_variables}
        DOWNLOAD_COMMAND ""

        CONFIGURE_COMMAND ${CMAKE_COMMAND} "${SHARED_SOURCE_DIR}/CMakeLists.txt" ${CMAKE_CONFIGURATION_ARGS} -DCMAKE_BUILD_Type=Release
        BUILD_COMMAND ${CMAKE_COMMAND} --build ${ARCH_BUILD_DIR} --config Release ${CMAKE_BUILD_ARGS}

        INSTALL_COMMAND ${CMAKE_COMMAND} --install ${ARCH_BUILD_DIR} --prefix ${PREFIX_DIR}/${TRIPLE_NAME} --config Release

        DEPENDS ${NAME}_source
    )
    MESSAGE(STATUS "Add external project: ${NAME} ${OS} ${ARCHS}")

    # Register the include directory and library path
    # ExternalProject_Get_Property(${NAME} PREFIX_DIR)
    set(${NAME}_INCLUDE_DIRS ${PREFIX_DIR}/${TRIPLE_NAME}/include)
    include_directories(${PREFIX_DIR}/${TRIPLE_NAME}/include)
    set(${NAME}_LIBRARY_DIRS ${PREFIX_DIR}/${TRIPLE_NAME}/lib)

    if(APPLE)
        if(IOS)
            # TODO: Fix this
            setup_framework_properties(${TRIPLE_NAME} ${VERSION})
            add_dependencies(${PROJECT_NAME}_lib ${TRIPLE_NAME})
        endif()

        set_xcode_property(${TRIPLE_NAME} CODE_SIGN_IDENTITY "Apple Development" All)
        set_xcode_property(${TRIPLE_NAME} DEVELOPMENT_TEAM ${DEVELOPMENT_TEAM_ID} All)

        set_xcode_property(${TRIPLE_NAME} CODE_SIGN_IDENTITY "Apple Development" All)
        set_xcode_property(${TRIPLE_NAME} DEVELOPMENT_TEAM ${DEVELOPMENT_TEAM_ID} All)

    else()
        add_dependencies(${PROJECT_NAME} ${TRIPLE_NAME})
    endif()

    if(WIN32)
        if("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
            set(${NAME}_LIBRARIES ${PREFIX_DIR}/${TRIPLE_NAME}/lib/${NAME}d.lib)
        else()
            # TODO Fix this
            set(${NAME}_LIBRARIES ${PREFIX_DIR}/${TRIPLE_NAME}/lib/${NAME}-static.lib)
        endif()
    elseif(APPLE)
        if(IOS)
            if("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
                set(${NAME}_LIBRARIES ${PREFIX_DIR}/${TRIPLE_NAME}/lib/lib${NAME}d.a)
            else()
                set(${NAME}_LIBRARIES ${PREFIX_DIR}/${TRIPLE_NAME}/lib/lib${NAME}.a)
            endif()
        else()
            # TODO: Fix this
            # if("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
            # set(${NAME}_LIBRARIES ${PREFIX_DIR}/${TRIPLE_NAME}/lib/lib${NAME}d.dylib)
            # else()
            set(${NAME}_LIBRARIES ${PREFIX_DIR}/${TRIPLE_NAME}/lib/lib${NAME}.dylib)

            # endif()
        endif()
    elseif(${OS} STREQUAL "Android")
        if("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
            set(${NAME}_LIBRARIES ${PREFIX_DIR}/${TRIPLE_NAME}/lib/lib${NAME}d.a)
        else()
            set(${NAME}_LIBRARIES ${PREFIX_DIR}/${TRIPLE_NAME}/lib/lib${NAME}.a)
        endif()
    elseif(EMSCRIPTEN)
        if("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
            set(${NAME}_LIBRARIES ${PREFIX_DIR}/${TRIPLE_NAME}/lib/lib${NAME}d.bc)
        else()
            set(${NAME}_LIBRARIES ${PREFIX_DIR}/${TRIPLE_NAME}/lib/lib${NAME}.bc)
        endif()
    elseif(UNIX)
        if("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
            set(${NAME}_LIBRARIES ${PREFIX_DIR}/${TRIPLE_NAME}/lib/lib${NAME}d.a)
        else()
            set(${NAME}_LIBRARIES ${PREFIX_DIR}/${TRIPLE_NAME}/lib/lib${NAME}.a)
        endif()
    else()
        message(FATAL_ERROR "Unsupported OS")
    endif()

    # Make the include directories and libraries available to the parent scope
    set(${NAME}_INCLUDE_DIRS ${${NAME}_INCLUDE_DIRS} PARENT_SCOPE)
    set(${NAME}_LIBRARY_DIRS ${${NAME}_LIBRARY_DIRS} PARENT_SCOPE)
    set(${NAME}_LIBRARIES ${${NAME}_LIBRARIES} PARENT_SCOPE)
endfunction()

sdl(
    "SDL2"
    "https://github.com/libsdl-org/SDL.git"
    "release-2.30.3"
    "2.30.3"
    "CMakeLists.txt"
)