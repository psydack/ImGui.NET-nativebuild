#pragma once

// Pull in the upstream cimgui user config (#undef NDEBUG)
#include "cimgui/cimconfig.h"

// Custom assert handler — callable from .NET via cimgui_set_assert_handler()
#ifdef __cplusplus
extern "C" {
#endif

typedef void (*ImGuiAssertHandlerFn)(const char* expr, const char* file, int line);
extern ImGuiAssertHandlerFn GImGuiAssertHandler;

#ifdef __cplusplus
}
#endif

#define IM_ASSERT(_EXPR) \
    do { \
        if (!(_EXPR) && GImGuiAssertHandler) \
            GImGuiAssertHandler(#_EXPR, __FILE__, __LINE__); \
    } while(0)
