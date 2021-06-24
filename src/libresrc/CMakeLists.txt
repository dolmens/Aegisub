set(RESPACK ${CMAKE_SOURCE_DIR}/tools/respack.py)
set(BITMAP_MANIFEST ${CMAKE_CURRENT_SOURCE_DIR}/../bitmaps/manifest.respack)
SET(MANIFEST_OSX ${CMAKE_CURRENT_SOURCE_DIR}/manifest_osx.respack)

configure_file(default_config_platform.json.in default_config_platform.json)

add_custom_command(OUTPUT bitmap.cpp bitmap.h
    COMMAND ${RESPACK} ${BITMAP_MANIFEST} bitmap.cpp bitmap.h
    DEPENDS ${RESPACK} ${BITMAP_MANIFEST}
    WORKING_DIRECTORY .
    )

add_custom_command(OUTPUT default_config.cpp default_config.h
    COMMAND ${RESPACK} ${MANIFEST_OSX} default_config.cpp default_config.h
    DEPENDS ${RESPACK} ${MANIFEST_OSX}
    WORKING_DIRECTORY .
    )

add_library(resrc STATIC
    libresrc.cpp
    bitmap.cpp
    default_config.cpp
    )

target_compile_definitions(resrc
    PRIVATE
    ${wxWidgets_DEFINITIONS}
    )

target_include_directories(resrc
    PRIVATE
    ${wxWidgets_INCLUDE_DIRS}
    PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
    )
