cmake_minimum_required(VERSION 3.15)
cmake_policy(SET CMP0091 NEW)

project(cimplot)

file(GLOB IMGUI_SOURCES
    ../cimgui/cimgui.cpp
    ../cimgui/imgui/imgui.cpp
    ../cimgui/imgui/imgui_draw.cpp
    ../cimgui/imgui/imgui_demo.cpp
    ../cimgui/imgui/imgui_widgets.cpp
    ../cimgui/imgui/imgui_tables.cpp
    cimplot.cpp
    implot/implot.cpp
    implot/implot_demo.cpp
    implot/implot_items.cpp
)

set(IMGUI_STATIC "no" CACHE STRING "Build as a static library")
set(CMAKE_CXX_STANDARD 11)

if(IMGUI_STATIC)
    add_library(cimplot STATIC ${IMGUI_SOURCES})
else()
    add_library(cimplot SHARED ${IMGUI_SOURCES})
endif()

include("${CMAKE_CURRENT_SOURCE_DIR}/../cmake/windows-hardening.cmake")
uimgui_harden_windows(cimplot)

add_definitions("-DIMGUI_USER_CONFIG=\"../cimconfig.h\"")
target_compile_definitions(cimplot PUBLIC IMGUI_DISABLE_OBSOLETE_FUNCTIONS=1)

target_include_directories(cimplot PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/implot)
target_include_directories(cimplot PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/../cimgui/imgui)
target_include_directories(cimplot PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/../cimgui)
set_target_properties(cimplot PROPERTIES PREFIX "")

install(TARGETS cimplot
    RUNTIME DESTINATION .
    LIBRARY DESTINATION .
    ARCHIVE DESTINATION .
)
