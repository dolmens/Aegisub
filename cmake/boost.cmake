set(wantedComponents chrono filesystem thread locale regex)

if(NOT WITH_LOCAL_BOOST)
    find_package(Boost 1.50.0 COMPONENTS ${wantedComponents})
endif()

if(NOT Boost_FOUND)
    if(ICU_FOUND AND ICU_ROOT)
        set(ICU_PATH_PARAM -sICU_PATH=${ICU_ROOT})
    elseif(ICU_INSTALL_DIR)
        set(ICU_PATH_PARAM -sICU_PATH=${ICU_INSTALL_DIR})
    endif()
    set(withParams)
    foreach(component ${wantedComponents})
        list(APPEND withParams --with-${component})
    endforeach()
    include(ExternalProject)
    ExternalProject_Add(boost
        URL https://boostorg.jfrog.io/artifactory/main/release/1.76.0/source/boost_1_76_0.tar.gz
        URL_HASH MD5=e425bf1f1d8c36a3cd464884e74f007a
        BUILD_IN_SOURCE 1
        CONFIGURE_COMMAND ./bootstrap.sh
        BUILD_COMMAND ./b2 stage cxxflags=-std=c++11 threading=multi ${ICU_PATH_PARAM} ${withParams}
        UPDATE_COMMAND ""
        INSTALL_COMMAND ""
        LOG_CONFIGURE 1
        LOG_BUILD 1
        LOG_INSTALL 1
        )

    ExternalProject_Get_Property(boost SOURCE_DIR)
    set(BOOST_INCLUDE_DIR ${SOURCE_DIR})
    set(BOOST_LIBRARY_DIR ${SOURCE_DIR}/stage/lib)

    foreach(component ${wantedComponents})
        set(componentTarget Boost::${component})
        string(CONCAT componentLibrary
            ${CMAKE_SHARED_LIBRARY_PREFIX}
            boost_
            ${component}
            ${CMAKE_SHARED_LIBRARY_SUFFIX}
            )
        add_library(${componentTarget} UNKNOWN IMPORTED)
        set_target_properties(${componentTarget} PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES ${BOOST_INCLUDE_DIR}
            IMPORTED_LOCATION ${BOOST_LIBRARY_DIR}/${componentLibrary}
            )
        add_dependencies(${componentTarget} boost)
    endforeach()
endif()
