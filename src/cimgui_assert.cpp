#include "cimgui_config.h"

ImGuiAssertHandlerFn GImGuiAssertHandler = nullptr;

#ifdef _WIN32
#  define ASSERT_EXPORT extern "C" __declspec(dllexport)
#else
#  define ASSERT_EXPORT extern "C" __attribute__((visibility("default")))
#endif

// Called from .NET to register a callback that receives failed IM_ASSERT events.
// Pass nullptr to disable (asserts become silent no-ops).
ASSERT_EXPORT void cimgui_set_assert_handler(ImGuiAssertHandlerFn handler)
{
    GImGuiAssertHandler = handler;
}
