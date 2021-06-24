find_path(UCHARDET_INCLUDE_DIR NAMES uchardet.h PATH_SUFFIXES uchardet)
find_library(UCHARDET_LIBRARY NAMES uchardet)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
    Uchardet
    REQUIRED_VARS UCHARDET_LIBRARY UCHARDET_INCLUDE_DIR
    )

if(UCHARDET_FOUND)
    add_library(Uchardet::uchardet UNKNOWN IMPORTED)
    set_target_properties(Uchardet::uchardet PROPERTIES
        IMPORTED_LOCATION "${UCHARDET_LIBRARY}"
        INTERFACE_INCLUDE_DIRECTORIES "${UCHARDET_INCLUDE_DIR}"
        )
endif()
