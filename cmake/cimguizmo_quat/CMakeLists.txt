cmake_minimum_required(VERSION 3.5)

project(cimguizmo_quat)

file(GLOB IMGUI_SOURCES
    ../cimgui/cimgui.cpp
    ../cimgui/imgui/imgui.cpp
    ../cimgui/imgui/imgui_draw.cpp
    ../cimgui/imgui/imgui_demo.cpp
    ../cimgui/imgui/imgui_widgets.cpp
    ../cimgui/imgui/imgui_tables.cpp
    cimguizmo_quat.cpp
    imGuIZMO.quat/imguizmo_quat/imGuIZMOquat.cpp
)

set(IMGUI_STATIC "no" CACHE STRING "Build as a static library")
set(CMAKE_CXX_STANDARD 11)

if (IMGUI_STATIC)
    add_library(cimguizmo_quat STATIC ${IMGUI_SOURCES})
else (IMGUI_STATIC)
    add_library(cimguizmo_quat SHARED ${IMGUI_SOURCES})
endif (IMGUI_STATIC)

add_definitions("-DIMGUI_USER_CONFIG=\"../cimconfig.h\"")
target_compile_definitions(cimguizmo_quat PUBLIC IMGUI_DISABLE_OBSOLETE_FUNCTIONS=1)

target_include_directories(cimguizmo_quat PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/imGuIZMO.quat/imguizmo_quat)
target_include_directories(cimguizmo_quat PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/../cimgui/imgui)
target_include_directories(cimguizmo_quat PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/../cimgui)
set_target_properties(cimguizmo_quat PROPERTIES PREFIX "")

install(TARGETS cimguizmo_quat
    RUNTIME DESTINATION  .
    LIBRARY DESTINATION  .
    ARCHIVE DESTINATION  .
)
