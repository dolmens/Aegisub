find_path(ASS_INCLUDE_DIR NAMES ass/ass.h HINTS ${ASS_ROOT} PATH_SUFFIXES include)
find_library(ASS_LIBRARY NAMES ass libass HINTS ${ASS_ROOT} PATH_SUFFIXES lib)

if(ASS_INCLUDE_DIR AND EXISTS "${ASS_INCLUDE_DIR}/ass/ass.h")
    file(STRINGS "${ASS_INCLUDE_DIR}/ass/ass.h" ass_header_str
        REGEX "^#define[\t ]+LIBASS_VERSION[\t ]+0x.+")
    string(REGEX REPLACE
        "^#define[\t ]+LIBASS_VERSION[\t ]+0x([0-9]+)([0-9][0-9])([0-9][0-9])([0-9][0-9][0-9])"
        "\\1.\\2.\\3.\\4" ass_version_string "${ass_header_str}")
    set(ASS_VERSION "${ass_version_string}")
    unset(ass_header_str)
    unset(ass_version_string)
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(ASS
    REQUIRED_VARS ASS_LIBRARY ASS_INCLUDE_DIR
    VERSION_VAR ASS_VERSION
    )
