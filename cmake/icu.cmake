set(wantedComponents data uc i18n)

if(NOT WITH_LOCAL_ICU)
    find_package(ICU 4.8.1.1 COMPONENTS ${wantedComponents})
endif()

if(NOT ICU_FOUND)
    include(ExternalProject)
    ExternalProject_Add(icu
        URL https://github.com/unicode-org/icu/releases/download/release-69-1/icu4c-69_1-src.tgz
        URL_HASH MD5=9403db682507369d0f60a25ea67014c4
        BUILD_IN_SOURCE 1
        CONFIGURE_COMMAND ./source/configure --prefix <INSTALL_DIR> --disable-samples --disable-tests --enable-rpath
        BUILD_COMMAND make
        INSTALL_COMMAND make install
        UPDATE_COMMAND ""
        LOG_CONFIGURE 1
        LOG_BUILD 1
        LOG_INSTALL 1
        )

    ExternalProject_Get_Property(icu INSTALL_DIR)
    set(ICU_INSTALL_DIR ${INSTALL_DIR})
    set(ICU_INCLUDE_DIR ${INSTALL_DIR}/include)
    set(ICU_LIBRARY_DIR ${INSTALL_DIR}/lib)

    file(MAKE_DIRECTORY ${ICU_INCLUDE_DIR})

    foreach(component ${wantedComponents})
        set(componentTarget ICU::${component})
        string(CONCAT componentLibrary
            ${CMAKE_SHARED_LIBRARY_PREFIX}
            icu
            ${component}
            ${CMAKE_SHARED_LIBRARY_SUFFIX}
            )
        add_library(${componentTarget} UNKNOWN IMPORTED)
        set_target_properties(${componentTarget} PROPERTIES
            IMPORTED_LOCATION ${ICU_LIBRARY_DIR}/${componentLibrary}
            INTERFACE_INCLUDE_DIRECTORIES ${ICU_INCLUDE_DIR}
            )
        add_dependencies(${componentTarget} icu)
    endforeach()
endif()
