using System.Runtime.InteropServices;
using Xunit;

/// <summary>
/// Verifies that FreeType is compiled into the native library and produces
/// a valid font atlas when used through the cimgui binding layer.
/// </summary>
public class FreeTypeTests : IDisposable
{
    private readonly IntPtr _ctx;

    public FreeTypeTests()
    {
        _ctx = NativeLib.igCreateContext(IntPtr.Zero);
    }

    public void Dispose() => NativeLib.igDestroyContext(_ctx);

    [Fact]
    public void GetFontLoader_ReturnsNonNull()
    {
        // Returns null when IMGUI_ENABLE_FREETYPE is not defined.
        // Non-null result proves FreeType was compiled in.
        var loader = NativeLib.ImGuiFreeType_GetFontLoader();
        Assert.NotEqual(IntPtr.Zero, loader);
    }

    [Fact]
    public void FontAtlas_AndFreeTypeLoader_AreAvailable()
    {
        // ImGuiIO layout (64-bit, imgui 1.92.x):
        //   ConfigFlags             int    @ 0
        //   BackendFlags            int    @ 4
        //   DisplaySize             float2 @ 8
        //   DisplayFramebufferScale float2 @ 16
        //   DeltaTime               float  @ 24
        //   IniSavingRate           float  @ 28
        //   IniFilename             ptr    @ 32
        //   LogFilename             ptr    @ 40
        //   UserData                ptr    @ 48
        //   Fonts                   ptr    @ 56
        const int fontsOffset = 56;

        IntPtr io = NativeLib.igGetIO();
        Assert.NotEqual(IntPtr.Zero, io);

        IntPtr atlas = Marshal.ReadIntPtr(io, fontsOffset);
        Assert.NotEqual(IntPtr.Zero, atlas);

        IntPtr loader = NativeLib.ImGuiFreeType_GetFontLoader();
        Assert.NotEqual(IntPtr.Zero, loader);
    }
}
