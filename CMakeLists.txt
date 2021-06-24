cmake_minimum_required(VERSION 3.20)

project(Aegisub LANGUAGES C CXX)

if(APPLE)
    enable_language(OBJCXX)
endif()

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake ${CMAKE_MODULE_PATH})

include(cmake/wxWidgets.cmake)
include(cmake/icu.cmake)
include(cmake/boost.cmake)
include(cmake/luajit.cmake)
include(cmake/iconv.cmake)
include(cmake/ass.cmake)

find_package(Uchardet)
if(UCHARDET_FOUND)
    set(WITH_UCHARDET 1)
endif()

find_package(Hunspell)
if(HUNSPELL_FOUND)
    set(WITH_HUNSPELL 1)
endif()

find_package(FFMS2 2.16)
if(FFMS2_FOUND)
    set(WITH_FFMS2 1)
endif()

find_package(FFTW)
if(FFTW_FOUND)
    set(WITH_FFTW3 1)
endif()

if(NOT APPLE)
    find_package(Fontconfig 2.4)
endif()
find_package(Freetype 2.10)

if(APPLE)
    set(HAVE_OPENGL_GL_H 1)
endif()

find_package(OpenAL)
if(OPENAL_FOUND)
    if(NOT TARGET OpenAL::OpenAL)
        add_library(OpenAL::OpenAL INTERFACE IMPORTED)
        set_target_properties(OpenAL::OpenAL PROPERTIES
            PROPERTY INTERFACE_INCLUDE_DIRECTORIES "${OPENAL_INCLUDE_DIR}"
            PROPERTY INTERFACE_LINK_LIBRARIES "${OPENAL_LIBRARY}"
            )
    endif()
    set(WITH_OPENAL 1)
endif()

if(APPLE AND WITH_OPENAL)
    set(DEFAULT_PLAYER_AUDIO OpenAL)
elseif(LINUX AND WITH_ALSA)
    set(DEFAULT_PLAYER_AUDIO ALSA)
elseif(WITH_PORTAUDIO)
    set(DEFAULT_PLAYER_AUDIO PortAudio)
elseif(WITH_OSS)
    set(DEFAULT_PLAYER_AUDIO OSS)
elseif(WITH_ALSA)
    set(DEFAULT_PLAYER_AUDIO ALSA)
elseif(WITH_OPENAL)
    set(DEFAULT_PLAYER_AUDIO OpenAL)
elseif(WITH_PULSEAUDIO)
    set(DEFAULT_PLAYER_AUDIO PulseAudio)
endif()

find_package(ZLIB REQUIRED)

set(VERSION_SH ${CMAKE_SOURCE_DIR}/tools/version.sh)
add_custom_target(gen_version
    COMMAND ${VERSION_SH} ${CMAKE_BINARY_DIR} ${CMAKE_SOURCE_DIR}
    )

configure_file(acconf.h.in acconf.h)

add_subdirectory(vendor/luabins)

add_subdirectory(libaegisub)
add_subdirectory(src)
