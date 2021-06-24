include(ExternalProject)

if(NOT WITH_LOCAL_ICONV)
    find_package(Iconv)
endif()

if(NOT Iconv_FOUND)
    ExternalProject_Add(Iconv
        URL https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.16.tar.gz
        URL_HASH MD5=7d2a800b952942bb2880efb00cfd524c
        BUILD_IN_SOURCE 1
        CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR>
        BUILD_COMMAND make
        INSTALL_COMMAND make install
        UPDATE_COMMAND ""
        BUILD_IN_SOURCE TRUE
        LOG_CONFIGURE 1
        LOG_BUILD 1
        LOG_INSTALL 1
        )
    ExternalProject_Get_Property(Iconv INSTALL_DIR)
    set(Iconv_INCLUDE_DIR ${INSTALL_DIR}/include)
    string(CONCAT Iconv_LIBRARY_FILENAME
        ${CMAKE_SHARED_LIBRARY_PREFIX}
        iconv
        ${CMAKE_SHARED_LIBRARY_SUFFIX}
        )
    set(Iconv_LIBRARY ${INSTALL_DIR}/lib/${Iconv_LIBRARY_FILENAME})
    set(Iconv_INCLUDE_DIRS "${Iconv_INCLUDE_DIR}")
    set(Iconv_LIBRARIES "${Iconv_LIBRARY}")

    add_library(Iconv::Iconv INTERFACE IMPORTED)
    set_target_properties(Iconv::Iconv PROPERTIES
        PROPERTY INTERFACE_INCLUDE_DIRECTORIES "${Iconv_INCLUDE_DIRS}"
        PROPERTY INTERFACE_LINK_LIBRARIES "${Iconv_LIBRARIES}"
        )
    add_dependencies(Iconv::Iconv Iconv)

endif()
