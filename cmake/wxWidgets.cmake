include(FetchContent)

if(NOT WITH_LOCAL_WXWIDGETS)
    if(WX_CONFIG)
        set(ENV{WX_CONFIG} ${WX_CONFIG})
    endif()
    find_package(wxWidgets 3.1 COMPONENTS
        core base gl stc xrc net html xml qa)
endif()

if(wxWidgets_FOUND)
    add_library(wxWidgets INTERFACE)
    target_include_directories(wxWidgets
        INTERFACE
        ${wxWidgets_INCLUDE_DIRS}
        )
    target_link_libraries(wxWidgets
        INTERFACE
        ${wxWidgets_LIBRARIES}
        )
else()
    message(STATUS "Download and build wxWidgets...")
    FetchContent_Declare(wxWidgetsExternal
        GIT_REPOSITORY https://github.com/wxWidgets/wxWidgets.git
        GIT_TAG        v3.1.5
        GIT_SHALLOW    TRUE
        )
    FetchContent_MakeAvailable(wxWidgetsExternal)
    add_library(wxWidgets INTERFACE)
    target_link_libraries(wxWidgets
        INTERFACE
        wxcore wxbase wxgl wxstc wxxrc wxnet wxhtml wxxml wxqa
        )
endif()
