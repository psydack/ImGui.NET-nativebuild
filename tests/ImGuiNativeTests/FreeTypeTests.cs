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
    public void FontAtlas_BuildWithFreeType_Succeeds()
    {
        // ImGuiIO layout (64-bit, imgui 1.92.x):
        //   ConfigFlags   int    @ 0
        //   BackendFlags  int    @ 4
        //   DisplaySize   float2 @ 8
        //   DeltaTime     float  @ 16
        //   IniSavingRate float  @ 20
        //   IniFilename   ptr    @ 24
        //   LogFilename   ptr    @ 32
        //   UserData      ptr    @ 40
        //   Fonts         ptr    @ 48  ← ImFontAtlas*
        const int fontsOffset = 48;

        IntPtr io = NativeLib.igGetIO();
        Assert.NotEqual(IntPtr.Zero, io);

        IntPtr atlas = Marshal.ReadIntPtr(io, fontsOffset);
        Assert.NotEqual(IntPtr.Zero, atlas);

        IntPtr font = NativeLib.ImFontAtlas_AddFontDefault(atlas, IntPtr.Zero);
        Assert.NotEqual(IntPtr.Zero, font);

        bool built = NativeLib.ImFontAtlas_Build(atlas);
        Assert.True(built);

        NativeLib.ImFontAtlas_GetTexDataAsAlpha8(atlas, out _, out int width, out int height, IntPtr.Zero);
        Assert.True(width > 0, $"Expected atlas width > 0, got {width}");
        Assert.True(height > 0, $"Expected atlas height > 0, got {height}");
    }
}
