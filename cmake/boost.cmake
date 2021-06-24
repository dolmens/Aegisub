include(ExternalProject)

if(NOT WITH_LOCAL_BOOST)
    find_package(Boost 1.50.0 COMPONENTS chrono filesystem thread locale regex)
endif()

if(NOT Boost_FOUND)
    if(ICU_FOUND AND ICU_ROOT)
        set(ICU_PATH_PARAM -sICU_PATH=${ICU_ROOT})
    else()
        set(ICU_PATH_PARAM -sICU_PATH=${ICU_INSTALL_DIR})
    endif()
    ExternalProject_Add(boost
        URL https://boostorg.jfrog.io/artifactory/main/release/1.76.0/source/boost_1_76_0.tar.gz
        URL_HASH MD5=e425bf1f1d8c36a3cd464884e74f007a
        BUILD_IN_SOURCE 1
        CONFIGURE_COMMAND ./bootstrap.sh
        BUILD_COMMAND ./b2 stage cxxflags=-std=c++11 threading=multi ${ICU_PATH_PARAM} --with-chrono --with-filesystem --with-thread --with-locale --with-regex
        UPDATE_COMMAND ""
        INSTALL_COMMAND ""
        LOG_CONFIGURE 1
        LOG_BUILD 1
        LOG_INSTALL 1
        )

    ExternalProject_Get_Property(boost SOURCE_DIR)
    set(BOOST_INCLUDE_DIR ${SOURCE_DIR})
    set(BOOST_LIBRARY_DIR ${SOURCE_DIR}/stage/lib)

    add_library(Boost::chrono STATIC IMPORTED)
    set_target_properties(Boost::chrono PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES ${BOOST_INCLUDE_DIR}
        IMPORTED_LOCATION ${BOOST_LIBRARY_DIR}/libboost_chrono.dylib
        )
    add_dependencies(Boost::chrono boost)

    add_library(Boost::filesystem STATIC IMPORTED)
    set_target_properties(Boost::filesystem PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES ${BOOST_INCLUDE_DIR}
        IMPORTED_LOCATION ${BOOST_LIBRARY_DIR}/libboost_filesystem.dylib
        )
    add_dependencies(Boost::filesystem boost)

    add_library(Boost::thread STATIC IMPORTED)
    set_target_properties(Boost::thread PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES ${BOOST_INCLUDE_DIR}
        IMPORTED_LOCATION ${BOOST_LIBRARY_DIR}/libboost_thread.dylib
        )
    add_dependencies(Boost::thread boost)

    add_library(Boost::locale STATIC IMPORTED)
    set_target_properties(Boost::locale PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES ${BOOST_INCLUDE_DIR}
        IMPORTED_LOCATION ${BOOST_LIBRARY_DIR}/libboost_locale.dylib
        )
    add_dependencies(Boost::locale boost)

    add_library(Boost::regex STATIC IMPORTED)
    set_target_properties(Boost::regex PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES ${BOOST_INCLUDE_DIR}
        IMPORTED_LOCATION ${BOOST_LIBRARY_DIR}/libboost_regex.dylib
        )
    add_dependencies(Boost::regex boost)

endif()
