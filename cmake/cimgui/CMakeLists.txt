cmake_minimum_required(VERSION 3.15)
cmake_policy(SET CMP0091 NEW)
project(cimgui)

set(CMAKE_CXX_STANDARD 11)

if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/imgui/imgui_tables.cpp)
    set(TABLES_SOURCE "imgui/imgui_tables.cpp")
else()
    set(TABLES_SOURCE "")
endif()

file(GLOB IMGUI_SOURCES
    cimgui.cpp
    imgui/imgui.cpp
    imgui/imgui_draw.cpp
    imgui/imgui_demo.cpp
    imgui/imgui_widgets.cpp
    ${TABLES_SOURCE}
)

set(IMGUI_STATIC "no" CACHE STRING "Build as a static library")
set(IMGUI_FREETYPE "yes" CACHE STRING "Build with freetype library")
set(IMGUI_LIBRARIES)

if(IMGUI_FREETYPE)
    message(STATUS "Building with freetype")
    if(WIN32)
        if(NOT DEFINED VCPKG_TARGET_TRIPLET OR "${VCPKG_TARGET_TRIPLET}" STREQUAL "")
            if(CMAKE_GENERATOR_PLATFORM STREQUAL "Win32")
                set(VCPKG_TARGET_TRIPLET "x86-windows-static")
            elseif(CMAKE_GENERATOR_PLATFORM STREQUAL "ARM64")
                set(VCPKG_TARGET_TRIPLET "arm64-windows-static")
            elseif(CMAKE_GENERATOR_PLATFORM STREQUAL "ARM")
                set(VCPKG_TARGET_TRIPLET "arm-windows-static")
            else()
                set(VCPKG_TARGET_TRIPLET "x64-windows-static")
            endif()
        endif()

        if(DEFINED VCPKG_INSTALLED_DIR AND DEFINED VCPKG_TARGET_TRIPLET)
            set(_vcpkg_pkg_dir "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}")
        elseif(DEFINED CMAKE_TOOLCHAIN_FILE AND DEFINED VCPKG_TARGET_TRIPLET)
            get_filename_component(_vcpkg_buildsystems_dir "${CMAKE_TOOLCHAIN_FILE}" DIRECTORY)
            get_filename_component(_vcpkg_root "${_vcpkg_buildsystems_dir}/../.." ABSOLUTE)
            set(_vcpkg_pkg_dir "${_vcpkg_root}/installed/${VCPKG_TARGET_TRIPLET}")
        else()
            message(FATAL_ERROR "Windows FreeType build requires VCPKG_TARGET_TRIPLET and the vcpkg toolchain.")
        endif()

        find_path(FREETYPE_INCLUDE_DIR_ft2build ft2build.h
            PATHS "${_vcpkg_pkg_dir}/include"
            NO_DEFAULT_PATH)
        find_path(FREETYPE_INCLUDE_DIR_freetype2 freetype/config/ftheader.h
            PATHS "${_vcpkg_pkg_dir}/include/freetype2"
            NO_DEFAULT_PATH)
        find_library(FREETYPE_LIBRARY_RELEASE freetype
            PATHS "${_vcpkg_pkg_dir}/lib"
            NO_DEFAULT_PATH)
        find_library(FREETYPE_LIBRARY_DEBUG freetyped
            PATHS "${_vcpkg_pkg_dir}/debug/lib"
            NO_DEFAULT_PATH)

        if(NOT FREETYPE_INCLUDE_DIR_ft2build OR NOT FREETYPE_INCLUDE_DIR_freetype2 OR NOT FREETYPE_LIBRARY_RELEASE)
            message(FATAL_ERROR "Could not resolve FreeType from vcpkg triplet ${VCPKG_TARGET_TRIPLET} in ${_vcpkg_pkg_dir}.")
        endif()

        set(FREETYPE_INCLUDE_DIRS "${FREETYPE_INCLUDE_DIR_ft2build};${FREETYPE_INCLUDE_DIR_freetype2}")
        if(FREETYPE_LIBRARY_DEBUG)
            set(FREETYPE_LIBRARIES optimized ${FREETYPE_LIBRARY_RELEASE} debug ${FREETYPE_LIBRARY_DEBUG})
        else()
            set(FREETYPE_LIBRARIES ${FREETYPE_LIBRARY_RELEASE})
        endif()
    else()
        find_package(Freetype REQUIRED)
    endif()
    list(APPEND IMGUI_SOURCES imgui/misc/freetype/imgui_freetype.cpp)
endif()

# Assert handler defined outside the submodule
list(APPEND IMGUI_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/../src/cimgui_assert.cpp)

if(IMGUI_STATIC)
    add_library(cimgui STATIC ${IMGUI_SOURCES})
else()
    add_library(cimgui SHARED ${IMGUI_SOURCES})
endif()

if(IMGUI_FREETYPE)
    target_compile_definitions(cimgui PUBLIC IMGUI_ENABLE_FREETYPE)
    target_compile_definitions(cimgui PUBLIC IMGUI_ENABLE_STB_TRUETYPE)
endif()

if(IMGUI_WCHAR32)
    target_compile_definitions(cimgui PUBLIC IMGUI_USE_WCHAR32)
endif()

if(CIMGUI_VARGS0)
    target_compile_definitions(cimgui PUBLIC CIMGUI_VARGS0)
endif()

# Point IMGUI_USER_CONFIG to our override (repo root), found via include path
target_include_directories(cimgui PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/..)
target_compile_definitions(cimgui PUBLIC IMGUI_USER_CONFIG="cimgui_config.h")

target_compile_definitions(cimgui PUBLIC IMGUI_DISABLE_OBSOLETE_FUNCTIONS=1)
if(WIN32)
    target_compile_definitions(cimgui PUBLIC IMGUI_IMPL_API=extern\t\"C\"\t__declspec\(dllexport\))
    list(APPEND IMGUI_LIBRARIES imm32)
else()
    target_compile_definitions(cimgui PUBLIC IMGUI_IMPL_API=extern\t\"C\"\t)
endif()

target_include_directories(cimgui PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
target_include_directories(cimgui PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/imgui)
if(IMGUI_FREETYPE)
    if(TARGET Freetype::Freetype)
        list(APPEND IMGUI_LIBRARIES Freetype::Freetype)
    else()
        target_include_directories(cimgui PUBLIC ${FREETYPE_INCLUDE_DIRS})
        list(APPEND IMGUI_LIBRARIES ${FREETYPE_LIBRARIES})
    endif()
endif()
set_target_properties(cimgui PROPERTIES PREFIX "")
target_link_libraries(cimgui ${IMGUI_LIBRARIES})

install(TARGETS cimgui
    RUNTIME DESTINATION .
    LIBRARY DESTINATION .
    ARCHIVE DESTINATION .
)

set(CIMGUI_TEST "no" CACHE STRING "Enable compilation of a test unit based on imgui null")
if(CIMGUI_TEST)
    add_subdirectory(test)
endif()
