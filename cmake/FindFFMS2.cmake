find_path(FFMS2_INCLUDE_DIR NAMES ffms.h HINTS ${FFMS2_ROOT} PATH_SUFFIXES include)
find_library(FFMS2_LIBRARY NAMES ffms2 HINTS ${FFMS2_ROOT} PATH_SUFFIXES lib)

if(FFMS2_INCLUDE_DIR)
    file(STRINGS "${FFMS2_INCLUDE_DIR}/ffms.h" ffms2_header_str
        REGEX "^#define[\t ]+FFMS_VERSION[\t ]+\\(\\([0-9]+[\t ]+<<[\t ]+24\\)[\t ]+\\|[\t ]+\\([0-9]+[\t ]+<<[\t ]+16\\)[\t ]+\\|[\t ]+\\([0-9]+[\t ]+<<[\t ]+8\\)[\t ]+\\|[\t ]+[0-9]+\\)")
    string(REGEX REPLACE
        "^#define[\t ]+FFMS_VERSION[\t ]+\\(\\(([0-9]+)[\t ]+<<[\t ]+24\\)[\t ]+\\|[\t ]+\\(([0-9]+)[\t ]+<<[\t ]+16\\)[\t ]+\\|[\t ]+\\(([0-9]+)[\t ]+<<[\t ]+8\\)[\t ]+\\|[\t ]+([0-9]+)\\)"
        "\\1.\\2.\\3.\\4" ffms2_version_string "${ffms2_header_str}"
        )
    set(FFMS2_VERSION "${ffms2_version_string}")
    unset(ffms2_header_str)
    unset(ffms2_version_string)
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(FFMS2
    REQUIRED_VARS FFMS2_LIBRARY FFMS2_INCLUDE_DIR
    VERSION_VAR FFMS2_VERSION
    )

if(FFMS2_FOUND)
    add_library(FFMS2::ffms2 UNKNOWN IMPORTED)
    set_target_properties(FFMS2::ffms2 PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${FFMS2_INCLUDE_DIR}"
        IMPORTED_LOCATION "${FFMS2_LIBRARY}"
        )
endif()
