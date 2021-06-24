include(ExternalProject)

if(NOT WITH_LOCAL_LUAJIT)
    find_package(LuaJIT 2.0)
    if(LUAJIT_FOUND)
        try_run(RUN_RESULT_VAR COMPILE_RESULT_VAR
            ${CMAKE_BINARY_DIR} ${CMAKE_SOURCE_DIR}/cmake/LuaJITCheck52.cc
            COMPILE_DEFINITIONS -I${LUAJIT_INCLUDE_DIR}
            LINK_LIBRARIES ${LUAJIT_LIBRARY}
            COMPILE_OUTPUT_VARIABLE compile_LuaJITCheck52
            RUN_OUTPUT_VARIABLE run_LuaJITCheck52
            )
        if(NOT RUN_RESULT_VAR EQUAL 0)
            unset(LUAJIT_FOUND)
        endif()
    endif()
endif()

if(NOT LUAJIT_FOUND)
    ExternalProject_Add(LuaJIT
        GIT_REPOSITORY https://github.com/LuaJIT/LuaJIT.git
        GIT_TAG v2.1
        CONFIGURE_COMMAND ""
        BUILD_COMMAND make MACOSX_DEPLOYMENT_TARGET=11.0 XCFLAGS+=-DLUAJIT_ENABLE_LUA52COMPAT
        INSTALL_COMMAND ""
        UPDATE_COMMAND ""
        BUILD_IN_SOURCE TRUE
        LOG_BUILD 1
        )
    ExternalProject_Get_Property(LuaJIT SOURCE_DIR)
    set(LUAJIT_INCLUDE_DIR ${SOURCE_DIR}/src)
    set(LUAJIT_LIBRARY ${SOURCE_DIR}/src/libluajit.a)

    # imported target include directories need exist in configuration
    file(MAKE_DIRECTORY ${LUAJIT_INCLUDE_DIR})
endif()

add_library(LuaJIT::luajit STATIC IMPORTED)
set_target_properties(LuaJIT::luajit PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES ${LUAJIT_INCLUDE_DIR}
    IMPORTED_LOCATION ${LUAJIT_LIBRARY}
    )
add_dependencies(LuaJIT::luajit LuaJIT)
