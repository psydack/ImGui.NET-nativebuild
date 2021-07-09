cmake_minimum_required(VERSION 3.1)

project(cimgui)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED True)
set(IMGUI_LIBRARIES )

# find freetype
FIND_PACKAGE(freetype REQUIRED PATHS ${FREETYPE_PATH})
list(APPEND IMGUI_LIBRARIES freetype)
list(APPEND IMGUI_LIBRARIES imm32)

# CIMGUI
add_library(cimgui SHARED
    cimgui/cimgui.cpp
    cimgui/imgui/imgui.cpp
    cimgui/imgui/imgui_draw.cpp
    cimgui/imgui/imgui_demo.cpp
    cimgui/imgui/imgui_widgets.cpp
	cimgui/imgui/imgui_tables.cpp
	cimgui/imgui/misc/freetype/imgui_freetype.cpp)

add_definitions("-DCIMGUI_FREETYPE=1")
target_compile_definitions(cimgui PUBLIC IMGUI_IMPL_API=extern\t\"C\"\t__declspec\(dllexport\))
target_link_libraries(cimgui ${IMGUI_LIBRARIES})
target_include_directories(cimgui PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/cimgui/imgui)

target_compile_definitions(cimgui PUBLIC IMGUI_DISABLE_OBSOLETE_FUNCTIONS=1 IMGUI_USE_WCHAR32=1 IMGUI_ENABLE_FREETYPE=1)
set_target_properties(cimgui PROPERTIES PREFIX "")

# CIMPLOT
add_library(cimplot SHARED
    cimgui/imgui/imgui.cpp
    cimgui/imgui/imgui_draw.cpp
    cimgui/imgui/imgui_demo.cpp
    cimgui/imgui/imgui_widgets.cpp
	cimgui/imgui/imgui_tables.cpp
    cimplot/cimplot.cpp
    cimplot/implot/implot.cpp
    cimplot/implot/implot_demo.cpp
    cimplot/implot/implot_items.cpp
	cimgui/imgui/misc/freetype/imgui_freetype.cpp)

target_link_libraries(cimplot ${IMGUI_LIBRARIES})

target_include_directories(cimplot PUBLIC cimgui/imgui)
set_target_properties(cimplot PROPERTIES PREFIX "")

# CIMNODES
add_library(cimnodes SHARED
    cimgui/imgui/imgui.cpp
    cimgui/imgui/imgui_draw.cpp
    cimgui/imgui/imgui_demo.cpp
    cimgui/imgui/imgui_widgets.cpp
	cimgui/imgui/imgui_tables.cpp
    cimnodes/cimnodes.cpp
    cimnodes/imnodes/imnodes.cpp
	cimgui/imgui/misc/freetype/imgui_freetype.cpp)

target_link_libraries(cimnodes ${IMGUI_LIBRARIES})

target_include_directories(cimnodes PUBLIC cimgui/imgui cimnodes/imnodes)
set_target_properties(cimnodes PROPERTIES PREFIX "")

# CIMGUIZMOS
add_library(cimguizmo SHARED
    cimgui/imgui/imgui.cpp
    cimgui/imgui/imgui_draw.cpp
    cimgui/imgui/imgui_demo.cpp
    cimgui/imgui/imgui_widgets.cpp
	cimgui/imgui/imgui_tables.cpp
    cimguizmo/cimguizmo.cpp
    cimguizmo/ImGuizmo/ImGuizmo.cpp
	cimgui/imgui/misc/freetype/imgui_freetype.cpp)

target_link_libraries(cimguizmo ${IMGUI_LIBRARIES})

target_include_directories(cimguizmo PUBLIC cimgui/imgui)
set_target_properties(cimguizmo PROPERTIES PREFIX "")