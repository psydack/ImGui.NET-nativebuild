set(UIMGUI_NATIVEBUILD_CMAKE_DIR "${CMAKE_CURRENT_LIST_DIR}")

function(uimgui_harden_windows target_name)
    if(NOT MSVC)
        return()
    endif()

    file(READ "${UIMGUI_NATIVEBUILD_CMAKE_DIR}/../version.json" version_json)
    string(
        REGEX MATCH
        "\"version\"[ \t\r\n]*:[ \t\r\n]*\"([0-9]+)\\.([0-9]+)\\.([0-9]+)\""
        version_match
        "${version_json}"
    )

    if(NOT version_match)
        message(FATAL_ERROR "Could not read the native library version from version.json")
    endif()

    set(UIMGUI_VERSION_MAJOR "${CMAKE_MATCH_1}")
    set(UIMGUI_VERSION_MINOR "${CMAKE_MATCH_2}")
    set(UIMGUI_VERSION_PATCH "${CMAKE_MATCH_3}")
    set(UIMGUI_TARGET_NAME "${target_name}")
    set(UIMGUI_VERSION_STRING
        "${UIMGUI_VERSION_MAJOR}.${UIMGUI_VERSION_MINOR}.${UIMGUI_VERSION_PATCH}.0"
    )

    set(version_resource "${CMAKE_CURRENT_BINARY_DIR}/${target_name}.version.rc")
    configure_file(
        "${UIMGUI_NATIVEBUILD_CMAKE_DIR}/version.rc.in"
        "${version_resource}"
        @ONLY
    )

    target_sources(${target_name} PRIVATE "${version_resource}")
    target_compile_options(${target_name} PRIVATE /guard:cf)
    target_link_options(${target_name} PRIVATE /guard:cf /Brepro)
endfunction()
