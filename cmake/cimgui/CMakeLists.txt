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
        find_package(freetype CONFIG REQUIRED)
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
    if(WIN32)
        if(TARGET freetype)
            list(APPEND IMGUI_LIBRARIES freetype)
        elseif(TARGET freetype::freetype)
            list(APPEND IMGUI_LIBRARIES freetype::freetype)
        endif()
    else()
        target_include_directories(cimgui PUBLIC ${FREETYPE_INCLUDE_DIRS})
        if(TARGET Freetype::Freetype)
            list(APPEND IMGUI_LIBRARIES Freetype::Freetype)
        else()
            list(APPEND IMGUI_LIBRARIES ${FREETYPE_LIBRARIES})
        endif()
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
