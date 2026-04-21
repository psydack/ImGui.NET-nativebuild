using System.Runtime.InteropServices;

/// <summary>
/// P/Invoke declarations for cimgui.dll.
/// The static constructor wires up a DLL resolver so CIMGUI_NATIVE_PATH can
/// point to the freshly-built library (used by CI). Falls back to the default
/// DLL search path for local development.
/// </summary>
internal static class NativeLib
{
    static NativeLib()
    {
        NativeLibrary.SetDllImportResolver(typeof(NativeLib).Assembly, (name, _, _) =>
        {
            if (name != "cimgui") return IntPtr.Zero;
            var envPath = Environment.GetEnvironmentVariable("CIMGUI_NATIVE_PATH");
            if (!string.IsNullOrEmpty(envPath) && File.Exists(envPath))
                return NativeLibrary.Load(envPath);
            return IntPtr.Zero; // fall back to default search (cimgui.dll alongside the test binary)
        });
    }

    // ── Core context ────────────────────────────────────────────────────────

    [DllImport("cimgui", CallingConvention = CallingConvention.Cdecl)]
    public static extern IntPtr igCreateContext(IntPtr sharedFontAtlas);

    [DllImport("cimgui", CallingConvention = CallingConvention.Cdecl)]
    public static extern void igDestroyContext(IntPtr ctx);

    [DllImport("cimgui", EntryPoint = "igGetIO_Nil", CallingConvention = CallingConvention.Cdecl)]
    public static extern IntPtr igGetIO();

    // ── Font atlas ───────────────────────────────────────────────────────────

    // ── FreeType ─────────────────────────────────────────────────────────────

    [DllImport("cimgui", CallingConvention = CallingConvention.Cdecl)]
    public static extern IntPtr ImGuiFreeType_GetFontLoader();

    // ── Custom assert handler ────────────────────────────────────────────────

    [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
    public delegate void AssertHandlerDelegate(
        [MarshalAs(UnmanagedType.LPStr)] string expr,
        [MarshalAs(UnmanagedType.LPStr)] string file,
        int line);

    [DllImport("cimgui", CallingConvention = CallingConvention.Cdecl)]
    public static extern void cimgui_set_assert_handler(AssertHandlerDelegate? handler);

    /// <summary>Fires IM_ASSERT(false) — for testing the assert handler only.</summary>
    [DllImport("cimgui", CallingConvention = CallingConvention.Cdecl)]
    public static extern void cimgui_trigger_test_assert();
}
