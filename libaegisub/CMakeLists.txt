add_library(libaegisub STATIC
    ass/dialogue_parser.cpp
    ass/time.cpp
    ass/uuencode.cpp

    audio/provider_convert.cpp
    audio/provider.cpp
    audio/provider_dummy.cpp
    audio/provider_hd.cpp
    audio/provider_lock.cpp
    audio/provider_pcm.cpp
    audio/provider_ram.cpp

    common/calltip_provider.cpp
    common/character_count.cpp
    common/charset_6937.cpp
    common/charset_conv.cpp
    common/charset.cpp
    common/color.cpp
    common/file_mapping.cpp
    common/format.cpp
    common/fs.cpp
    common/hotkey.cpp
    common/io.cpp
    common/json.cpp
    common/kana_table.cpp
    common/karaoke_matcher.cpp
    common/keyframe.cpp
    common/line_iterator.cpp
    common/log.cpp
    common/mru.cpp
    common/option.cpp
    common/option_value.cpp
    common/parser.cpp
    common/path.cpp
    common/thesaurus.cpp
    common/util.cpp
    common/vfr.cpp
    common/ycbcr_conv.cpp
    common/cajun/elements.cpp
    common/cajun/reader.cpp
    common/cajun/writer.cpp

    lua/modules.cpp
    lua/script_reader.cpp
    lua/utils.cpp
    lua/modules/lfs.cpp
    lua/modules/re.cpp
    lua/modules/unicode.cpp
    lua/modules/lpeg.c
    )

if(APPLE)
    target_sources(libaegisub
        PRIVATE
        osx/dispatch.mm
        osx/spellchecker.mm
        osx/util.mm
        )
endif()

if(WIN32)
else()
    target_sources(libaegisub
        PRIVATE
        unix/access.cpp
        unix/fs.cpp
        unix/log.cpp
        unix/path.cpp
        unix/util.cpp
        )
endif()

target_precompile_headers(libaegisub
    PRIVATE
    "$<$<COMPILE_LANGUAGE:CXX>:${CMAKE_CURRENT_SOURCE_DIR}/lagi_pre.h>"
    )

target_include_directories(libaegisub
    PRIVATE
    ${CMAKE_BINARY_DIR}
    PUBLIC
    include
    )

target_link_libraries(libaegisub
    PUBLIC
    ICU::i18n
    ICU::uc
    Boost::boost
    LuaJIT::luajit
    )

set_target_properties(libaegisub
    PROPERTIES OUTPUT_NAME aegisub
    )
