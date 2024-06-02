include(ExternalProject)



# EXTERNALPROJECT_ADD(
#     ffmpeg

#     # DEPENDS nasm zlib openssl opencore-amr fdkaac lame libogg opus speex libvorbis libtheora xvidcore x264 x265 aom libvpx srt freetype libass zimg intel-media-sdk libxcoder
#     GIT_REPOSITORY https://git.ffmpeg.org/ffmpeg.git

#     # URL https://ffmpeg.org/releases/ffmpeg-5.1.2.tar.bz2
#     URL ${CMAKE_SOURCE_DIR}/vendor/ffmpeg-5.1.2.tar.bz2
#     PATCH_COMMAND ${CMAKE_SOURCE_DIR}/patches/patch-manager.sh ffmpeg
#     CONFIGURE_COMMAND PATH=$ENV{PATH} PKG_CONFIG_PATH=$ENV{PKG_CONFIG_PATH} ./configure --prefix=${CMAKE_BINARY_DIR} --datadir=${CMAKE_BINARY_DIR}/etc --pkg-config-flags=--static --disable-shared --enable-static --enable-gpl --enable-version3 --enable-nonfree --enable-runtime-cpudetect --disable-doc --disable-debug --disable-ffplay --disable-indevs --disable-outdevs --extra-cflags=-I${CMAKE_BINARY_DIR}/include\ --static --extra-ldflags=-L${CMAKE_BINARY_DIR}/lib --extra-libs=-lvorbis\ -logg\ -lcrypto\ -lexpat\ -lharfbuzz\ -lfribidi\ -lz\ -ldrm\ -lpthread\ -lstdc++\ -lm\ -ldl\ -lrt --enable-openssl --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libfdk-aac --enable-libmp3lame --enable-libopus --enable-libspeex --enable-libtheora --enable-libvorbis --enable-libxvid --enable-libx264 --enable-libx265 --enable-libaom --enable-libvpx --enable-libsrt --enable-libfontconfig --enable-libfreetype --enable-libass --enable-libzimg --enable-vaapi --enable-libmfx --enable-libxcoder --enable-ni_quadra --disable-filter=hwupload_ni_logan
#     BUILD_COMMAND PATH=$ENV{PATH} make -j${CONCURRENCY}
#     BUILD_IN_SOURCE 1
# )

function(ffmpeg NAME GIT_REPO GIT_TAG VERSION DEPENDS)
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
        BUILD_BYPRODUCTS "${SHARED_SOURCE_DIR}/configure"
    )

    message(STATUS "make: ${MAKE_PATH}")

    set(FFMPEG_CONFIGURE_COMMAND ./configure --prefix=${ARCH_BUILD_DIR} --datadir=${ARCH_BUILD_DIR}/etc --cc=${CC} --cxx=${CXX} --arch=${ARCHS} --target-os=${OS} --enable-cross-compile --pkg-config-flags=--static --disable-shared --enable-static --enable-gpl --enable-version3 --enable-nonfree --enable-runtime-cpudetect --disable-doc --disable-debug --disable-ffplay --disable-indevs --disable-outdevs --extra-cflags=-I${CMAKE_BINARY_DIR}/include\ --static --extra-ldflags=-L${CMAKE_BINARY_DIR}/lib --extra-libs=-lvorbis\ -logg\ -lcrypto\ -lexpat\ -lharfbuzz\ -lfribidi\ -lz\ -ldrm\ -lpthread\ -lstdc++\ -lm\ -ldl\ -lrt --enable-openssl --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libfdk-aac --enable-libmp3lame --enable-libopus --enable-libspeex --enable-libtheora --enable-libvorbis --enable-libxvid --enable-libx264 --enable-libx265 --enable-libaom --enable-libvpx --enable-libsrt --enable-libfontconfig --enable-libfreetype --enable-libass --enable-libzimg --enable-vaapi --enable-libmfx --disable-filter=hwupload_ni_logan
    )

    message(STATUS "FFMPEG_CONFIGURE_COMMAND: ${FFMPEG_CONFIGURE_COMMAND}")
    ExternalProject_Add(
        ${TRIPLE_NAME}
        SOURCE_DIR ${SHARED_SOURCE_DIR}
        BINARY_DIR ${SHARED_SOURCE_DIR}

        CONFIGURE_COMMAND ${FFMPEG_CONFIGURE_COMMAND}
        BUILD_COMMAND make -j${CONCURRENCY}
        INSTALL_COMMAND make install
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

ffmpeg(
    "ffmpeg"
    "https://git.ffmpeg.org/ffmpeg.git"
    "n7.0.1"
    "7.0.1"
    "configure"
)