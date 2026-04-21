using Xunit;

/// <summary>
/// Verifies that cimgui_set_assert_handler and cimgui_trigger_test_assert work
/// correctly from .NET P/Invoke.
/// </summary>
public class AssertHandlerTests : IDisposable
{
    private readonly IntPtr _ctx;
    // Field keeps the delegate alive for the lifetime of the test instance,
    // preventing the GC from collecting it while native code holds a pointer.
    private NativeLib.AssertHandlerDelegate? _handler;

    public AssertHandlerTests()
    {
        _ctx = NativeLib.igCreateContext(IntPtr.Zero);
    }

    public void Dispose()
    {
        NativeLib.cimgui_set_assert_handler(null);
        NativeLib.igDestroyContext(_ctx);
    }

    [Fact]
    public void SetHandler_DoesNotCrash()
    {
        _handler = (expr, file, line) => { };
        NativeLib.cimgui_set_assert_handler(_handler);
    }

    [Fact]
    public void SetHandler_Null_DisablesHandler()
    {
        _handler = (expr, file, line) => { };
        NativeLib.cimgui_set_assert_handler(_handler);
        NativeLib.cimgui_set_assert_handler(null); // must not crash
    }

    [Fact]
    public void Handler_FiresOnExpectedCondition()
    {
        string? capturedExpr = null;
        _handler = (expr, file, line) => capturedExpr = expr;

        NativeLib.cimgui_set_assert_handler(_handler);
        NativeLib.cimgui_trigger_test_assert();
        NativeLib.cimgui_set_assert_handler(null);

        Assert.NotNull(capturedExpr);
        Assert.Contains("false", capturedExpr);
    }
}
