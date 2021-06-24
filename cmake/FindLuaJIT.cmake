find_path(LUAJIT_INCLUDE_DIR NAMES luajit.h
    HINTS ${LUAJIT_ROOT}
    PATH_SUFFIXES include include/luajit include/luajit-2.1 src
    )
find_library(LUAJIT_LIBRARY NAMES libluajit.a
    HINTS ${LUAJIT_ROOT}
    PATH_SUFFIXES lib src)

if(LUAJIT_INCLUDE_DIR)
    file(STRINGS "${LUAJIT_INCLUDE_DIR}/luajit.h" luajit_header_str
        REGEX "^#define[\t ]+LUAJIT_VERSION_NUM[\t ]+.+")
    string(REGEX REPLACE
        "^#define[\t ]+LUAJIT_VERSION_NUM[\t ]+([0-9]+)([0-9][0-9])([0-9][0-9]).*"
        "\\1.\\2.\\3" luajit_version_string "${luajit_header_str}")
    set(LUAJIT_VERSION "${luajit_version_string}")
    unset(luajit_header_str)
    unset(luajit_version_string)
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(LuaJIT
    REQUIRED_VARS LUAJIT_LIBRARY LUAJIT_INCLUDE_DIR
    VERSION_VAR LUAJIT_VERSION
    )
