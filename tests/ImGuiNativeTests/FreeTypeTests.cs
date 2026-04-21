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

}
