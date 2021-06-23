add_library(luabins STATIC
    src/fwrite.c
    src/load.c
    src/luabins.c
    src/luainternals.c
    src/savebuffer.c
    src/save.c
    src/write.c
    )

target_include_directories(luabins
    PRIVATE
    ${LUAJIT_INCLUDE_DIR}
    )
