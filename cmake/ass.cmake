include(ExternalProject)

if(NOT WITH_LOCAL_ASS)
    find_package(ASS 0.9.7)
endif()

if(NOT ASS_FOUND)
    ExternalProject_Add(libass
        GIT_REPOSITORY https://github.com/libass/libass.git
        GIT_TAG        0.15.1
        GIT_SHALLOW    TRUE
        BUILD_IN_SOURCE 1
        CONFIGURE_COMMAND ./autogen.sh COMMAND ./configure --prefix=<INSTALL_DIR>
        BUILD_COMMAND make
        UPDATE_COMMAND ""
        INSTALL_COMMAND make install
        LOG_CONFIGURE 1
        LOG_BUILD 1
        LOG_INSTALL 1
        )
    ExternalProject_Get_Property(libass INSTALL_DIR)
    set(ASS_INCLUDE_DIR ${INSTALL_DIR}/include)
    set(ASS_LIBRARY ${INSTALL_DIR}/lib/libass.dylib)

    file(MAKE_DIRECTORY ${ASS_INCLUDE_DIR})
endif()

add_library(ASS::ASS STATIC IMPORTED)
set_target_properties(ASS::ASS PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${ASS_INCLUDE_DIR}"
    IMPORTED_LOCATION "${ASS_LIBRARY}"
    )

if(TARGET libass)
    add_dependencies(ASS::ASS libass)
endif()
