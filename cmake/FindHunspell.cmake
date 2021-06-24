find_path(HUNSPELL_INCLUDE_DIR NAMES hunspell/hunspell.hxx
    HINTS ${HUNSPELL_ROOT}
    PATH_SUFFIXES include
    )
find_library(HUNSPELL_LIBRARY NAMES
    hunspell hunspell-1.7 hunspell-1.6 hunspell-1.5 hunspell-1.4 hunspell-1.3 hunspell-1.2
    HINTS ${HUNSPELL_ROOT}
    PATH_SUFFIXES lib
    )

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Hunspell
    REQUIRED_VARS HUNSPELL_LIBRARY HUNSPELL_INCLUDE_DIR
    )

if(HUNSPELL_FOUND)
    add_library(Hunspell::hunspell UNKNOWN IMPORTED)
    set_target_properties(Hunspell::hunspell PROPERTIES
        IMPORTED_LOCATION "${HUNSPELL_LIBRARY}"
        INTERFACE_INCLUDE_DIRECTORIES "${HUNSPELL_INCLUDE_DIR}"
        )
endif()

mark_as_advanced(HUNSPELL_INCLUDE_DIR HUNSPELL_LIBRARY)
