find_path(FFTW_INCLUDE_DIR NAMES fftw3.h HINTS ${FFTW_ROOT} PATH_SUFFIXES include)
find_library(FFTW_LIBRARY NAMES fftw3 HINTS ${FFTW_ROOT} PATH_SUFFIXES lib)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(FFTW
    REQUIRED_VARS FFTW_LIBRARY FFTW_INCLUDE_DIR
    )

if(FFTW_FOUND)
    add_library(FFTW::fftw UNKNOWN IMPORTED)
    set_target_properties(FFTW::fftw PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${FFTW_INCLUDE_DIR}"
        IMPORTED_LOCATION "${FFTW_LIBRARY}"
        )
endif()
